local trackedBuses = {}
local trackedTrains = {}
local busCounterByRoute = { [1] = 0, [2] = 0 }
local trainCounter = 0
local lastBusSpawnByRoute = { [1] = os.time(), [2] = os.time() }
local lastTrainSpawnTime = os.time()

local function Dist3D(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = (a.z or 0.0) - (b.z or 0.0)
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function FindNearestRouteNodeIdx(routeId, coords)
    local route = Config.BusRoutes[routeId] or Config.BusRoutes[1]
    if not route or not route.nodes then return 1, 999999.0, false end

    local bestIdx = 1
    local bestDist = 999999.0
    local isWp = false

    for idx, node in ipairs(route.nodes) do
        local nc = node.coords
        local d = Dist3D(coords, vector3(nc.x, nc.y, nc.z))
        if d < bestDist then
            bestDist = d
            bestIdx = idx
            isWp = node.isWaypoint == true
        end
    end
    return bestIdx, bestDist, isWp
end

local function FindNearestMetroStationIdx(coords)
    local bestIdx = 1
    local bestDist = 999999.0
    for idx, st in ipairs(Config.MetroStations) do
        local d = Dist3D(coords, st.coords)
        if d < bestDist then
            bestDist = d
            bestIdx = idx
        end
    end
    return bestIdx, bestDist
end

RegisterNetEvent('eco_bus:server:registerScheduledBus', function(netVeh, routeId)
    if not netVeh then return end
    routeId = tonumber(routeId) or 1
    if not Config.BusRoutes[routeId] then routeId = 1 end

    if not trackedBuses[netVeh] then
        busCounterByRoute[routeId] = (busCounterByRoute[routeId] or 0) + 1
        local seq = ((busCounterByRoute[routeId] - 1) % 99) + 1
        local code = ("R%d-B%02d"):format(routeId, seq)
        lastBusSpawnByRoute[routeId] = os.time()

        trackedBuses[netVeh] = {
            netId = netVeh,
            routeId = routeId,
            code = code,
            spawnedAt = os.time(),
            lastNodeIdx = 1,
            lastStopId = 1,
            status = "STOPPED",
            statusUpdatedAt = os.time()
        }
    end
end)

RegisterNetEvent('eco_bus:server:removeScheduledBus', function(netVeh)
    if netVeh and trackedBuses[netVeh] then
        trackedBuses[netVeh] = nil
    end
end)

RegisterNetEvent('eco_subway:server:registerTrain', function(netTrain, startStationIdx)
    if not netTrain then return end
    trainCounter = trainCounter + 1
    local code = ("LST-%02d"):format(((trainCounter - 1) % 99) + 1)
    lastTrainSpawnTime = os.time()
    trackedTrains[netTrain] = {
        netId = netTrain,
        code = code,
        spawnedAt = os.time(),
        lastStationIdx = startStationIdx or 4,
        status = "STOPPED",
        statusUpdatedAt = os.time()
    }
end)

RegisterNetEvent('eco_subway:server:updateTrainStatus', function(netTrain, stationIdx, status)
    if netTrain then
        if not trackedTrains[netTrain] then
            trainCounter = trainCounter + 1
            trackedTrains[netTrain] = {
                netId = netTrain,
                code = ("LST-%02d"):format(((trainCounter - 1) % 99) + 1),
                spawnedAt = os.time(),
                lastStationIdx = stationIdx or 1,
                status = status or "EN_ROUTE",
                statusUpdatedAt = os.time()
            }
        else
            trackedTrains[netTrain].lastStationIdx = stationIdx
            trackedTrains[netTrain].status = status
            trackedTrains[netTrain].statusUpdatedAt = os.time()
        end
    end
end)

RegisterNetEvent('eco_subway:server:removeTrain', function(netTrain)
    if netTrain and trackedTrains[netTrain] then
        trackedTrains[netTrain] = nil
    end
end)

RegisterNetEvent('eco_subway:client:clearAllTrains', function()
    trackedTrains = {}
    trainCounter = 0
end)

local function DiscoverExistingFleetEntities()
    local allVehs = GetAllVehicles()
    for _, veh in ipairs(allVehs) do
        if DoesEntityExist(veh) then
            local okState, isBoarding = pcall(function()
                return Entity(veh).state.isBoardingOpen
            end)
            local okRoute, stateRouteId = pcall(function()
                return Entity(veh).state.busRouteId
            end)

            if (okState and isBoarding ~= nil) or (okRoute and stateRouteId ~= nil) then
                local netId = NetworkGetNetworkIdFromEntity(veh)
                if netId and netId > 0 and not trackedBuses[netId] then
                    local rId = tonumber(stateRouteId) or 1
                    if not Config.BusRoutes[rId] then rId = 1 end

                    busCounterByRoute[rId] = (busCounterByRoute[rId] or 0) + 1
                    local seq = ((busCounterByRoute[rId] - 1) % 99) + 1
                    local c = GetEntityCoords(veh)
                    local nearestNodeIdx = FindNearestRouteNodeIdx(rId, c)
                    local routeNodes = Config.BusRoutes[rId].nodes
                    local stopId = (routeNodes[nearestNodeIdx] and routeNodes[nearestNodeIdx].stopId) or 1

                    trackedBuses[netId] = {
                        netId = netId,
                        routeId = rId,
                        code = ("R%d-B%02d"):format(rId, seq),
                        spawnedAt = os.time(),
                        lastNodeIdx = nearestNodeIdx,
                        lastStopId = stopId,
                        status = isBoarding and "STOPPED" or "EN_ROUTE",
                        statusUpdatedAt = os.time()
                    }
                end
            end
        end
    end
end

local function BuildEcoLinkSnapshot()
    local now = os.time()
    local validBuses = {}
    local validTrains = {}
    local activeCountByRoute = { [1] = 0, [2] = 0 }

    for netId, info in pairs(trackedBuses) do
        local entity = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(entity) then
            local c = GetEntityCoords(entity)
            local speed = GetEntitySpeed(entity)
            local coords = { x = c.x, y = c.y, z = c.z }

            local okR, stateRId = pcall(function()
                return Entity(entity).state.busRouteId
            end)
            if okR and stateRId and Config.BusRoutes[tonumber(stateRId)] then
                info.routeId = tonumber(stateRId)
            end
            local routeId = info.routeId or 1
            activeCountByRoute[routeId] = (activeCountByRoute[routeId] or 0) + 1

            local routeData = Config.BusRoutes[routeId] or Config.BusRoutes[1]
            local nodes = routeData.nodes
            local nearestNodeIdx, nearestDist, nearestIsWp = FindNearestRouteNodeIdx(routeId, coords)

            local isBoarding = false
            local ok, stateVal = pcall(function()
                return Entity(entity).state.isBoardingOpen
            end)
            if ok and stateVal then
                isBoarding = true
            end

            if nearestIsWp and nearestDist <= 18.0 then
                info.lastNodeIdx = nearestNodeIdx
            elseif not nearestIsWp and nearestDist <= 15.0 then
                info.lastNodeIdx = nearestNodeIdx
                if nodes[nearestNodeIdx] and nodes[nearestNodeIdx].stopId then
                    info.lastStopId = nodes[nearestNodeIdx].stopId
                end
            end

            local curNodeIdx = info.lastNodeIdx or 1
            local nextNodeIdx = (curNodeIdx % #nodes) + 1
            local nextNode = nodes[nextNodeIdx]
            local distToNextNode = Dist3D(coords, vector3(nextNode.coords.x, nextNode.coords.y, nextNode.coords.z))

            local newStatus = info.status or "EN_ROUTE"
            if isBoarding or (not nearestIsWp and nearestDist <= 4.5 and speed < 0.4) then
                newStatus = "STOPPED"
                info.lastNodeIdx = nearestNodeIdx
                if nodes[nearestNodeIdx] and nodes[nearestNodeIdx].stopId then
                    info.lastStopId = nodes[nearestNodeIdx].stopId
                end
                if info.status ~= "STOPPED" then
                    info.statusUpdatedAt = now
                end
            elseif not nearestIsWp and nearestDist <= 12.0 and speed < 0.25 then
                newStatus = "QUEUEING"
                if info.status ~= "QUEUEING" then
                    info.statusUpdatedAt = now
                end
            elseif not nextNode.isWaypoint and distToNextNode <= 20.0 then
                newStatus = "APPROACHING"
                if info.status ~= "APPROACHING" then
                    info.statusUpdatedAt = now
                end
            elseif nextNode.isWaypoint or nearestIsWp then
                newStatus = "CORNERING"
                if info.status ~= "CORNERING" then
                    info.statusUpdatedAt = now
                end
            else
                newStatus = "EN_ROUTE"
                if info.status == "STOPPED" then
                    info.statusUpdatedAt = now
                end
            end
            info.status = newStatus

            table.insert(validBuses, {
                netId = netId,
                routeId = routeId,
                code = info.code,
                coords = coords,
                speed = speed,
                lastNodeIdx = info.lastNodeIdx or 1,
                lastStopId = info.lastStopId or 1,
                status = info.status,
                elapsedInStatus = math.max(0, now - (info.statusUpdatedAt or now))
            })
        else
            trackedBuses[netId] = nil
        end
    end

    for netId, info in pairs(trackedTrains) do
        local entity = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(entity) then
            local c = GetEntityCoords(entity)
            local coords = { x = c.x, y = c.y, z = c.z }
            table.insert(validTrains, {
                netId = netId,
                code = info.code,
                coords = coords,
                lastStationIdx = info.lastStationIdx or 1,
                status = info.status or "EN_ROUTE",
                elapsedInStatus = math.max(0, now - (info.statusUpdatedAt or now))
            })
        else
            trackedTrains[netId] = nil
        end
    end

    local nextBusDispatchByRoute = {}
    local minNextBusDispatch = 999999
    for rId, rCfg in pairs(Config.BusRoutes) do
        local activeInR = activeCountByRoute[rId] or 0
        if activeInR < (rCfg.maxBuses or 2) then
            local hw = rCfg.headwaySeconds or 180
            local lastSp = lastBusSpawnByRoute[rId] or now
            local rem = math.max(0, hw - (now - lastSp))
            nextBusDispatchByRoute[rId] = rem
            if rem < minNextBusDispatch then
                minNextBusDispatch = rem
            end
        else
            nextBusDispatchByRoute[rId] = 0
        end
    end
    if minNextBusDispatch == 999999 then minNextBusDispatch = 0 end

    local nextTrainDispatchIn = 0
    if #validTrains < (Config.SubwayTransit.MaxTrainsPerRoute or 2) then
        local headway = Config.SubwayTransit.HeadwaySeconds or 240
        nextTrainDispatchIn = math.max(0, headway - (now - lastTrainSpawnTime))
    end

    return {
        buses = validBuses,
        trains = validTrains,
        nextBusDispatchIn = minNextBusDispatch,
        nextBusDispatchByRoute = nextBusDispatchByRoute,
        nextTrainDispatchIn = nextTrainDispatchIn,
        serverTimestamp = now
    }
end

CreateThread(function()
    Wait(1500)
    DiscoverExistingFleetEntities()
    while true do
        Wait(1000)
        local players = GetPlayers()
        if #players > 0 then
            if next(trackedBuses) == nil then
                DiscoverExistingFleetEntities()
            end
            local snapshot = BuildEcoLinkSnapshot()
            TriggerClientEvent('eco_tablet:client:syncTelemetry', -1, snapshot)
        end
    end
end)

RegisterNetEvent('eco_tablet:server:requestSnapshot', function()
    local src = source
    DiscoverExistingFleetEntities()
    local snapshot = BuildEcoLinkSnapshot()
    TriggerClientEvent('eco_tablet:client:syncTelemetry', src, snapshot)
end)

-- =========================================================================
-- DATABASE HANDLERS (SAVED PLACES & RATINGS OXMYSQL)
-- =========================================================================

-- Inisialisasi Tabel Database
CreateThread(function()
    Wait(500)
    if MySQL then
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `eco_taxi_saved_places` (
              `id` INT AUTO_INCREMENT PRIMARY KEY,
              `identifier` VARCHAR(64) NOT NULL,
              `label` VARCHAR(60) NOT NULL,
              `tag` VARCHAR(25) DEFAULT 'Favorit',
              `coords` LONGTEXT NOT NULL,
              `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
              INDEX (`identifier`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]])

        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `eco_taxi_ratings` (
              `id` INT AUTO_INCREMENT PRIMARY KEY,
              `identifier` VARCHAR(64) NOT NULL,
              `service_type` VARCHAR(25) NOT NULL,
              `driver_name` VARCHAR(80) NOT NULL,
              `rating` INT NOT NULL,
              `tip` INT DEFAULT 0,
              `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
              INDEX (`identifier`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]])
    end
end)

-- Ambil Alamat Tersimpan Pribadi Pemain
RegisterNetEvent('eco_tablet:server:getSavedPlaces', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local identifier = xPlayer.getIdentifier()

    if MySQL then
        MySQL.query('SELECT id, label, tag, coords FROM eco_taxi_saved_places WHERE identifier = ? ORDER BY id DESC', { identifier }, function(results)
            local places = {}
            if results then
                for _, row in ipairs(results) do
                    local ok, c = pcall(json.decode, row.coords)
                    if ok and c then
                        table.insert(places, {
                            id = row.id,
                            label = row.label,
                            tag = row.tag or 'Favorit',
                            coords = c
                        })
                    end
                end
            end
            TriggerClientEvent('eco_tablet:client:receiveSavedPlaces', src, places)
        end)
    else
        TriggerClientEvent('eco_tablet:client:receiveSavedPlaces', src, {})
    end
end)

-- Simpan Alamat Baru Pribadi Pemain
RegisterNetEvent('eco_tablet:server:savePlace', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not data or not data.label or not data.coords then return end
    local identifier = xPlayer.getIdentifier()
    local coordsJson = json.encode({ x = data.coords.x, y = data.coords.y, z = data.coords.z })

    if MySQL then
        MySQL.insert('INSERT INTO eco_taxi_saved_places (identifier, label, tag, coords) VALUES (?, ?, ?, ?)', {
            identifier, data.label, data.tag or 'Favorit', coordsJson
        }, function(insertId)
            if insertId then
                TriggerClientEvent('esx:showNotification', src, ('~g~[EcoCab] Lokasi "%s" berhasil disimpan!~s~'):format(data.label))
                -- Refresh daftar alamat
                TriggerEvent('eco_tablet:server:getSavedPlaces')
            end
        end)
    end
end)

-- Hapus Alamat Tersimpan
RegisterNetEvent('eco_tablet:server:deletePlace', function(placeId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not placeId then return end
    local identifier = xPlayer.getIdentifier()

    if MySQL then
        MySQL.query('DELETE FROM eco_taxi_saved_places WHERE id = ? AND identifier = ?', { placeId, identifier }, function(affected)
            TriggerClientEvent('esx:showNotification', src, '~y~[EcoCab] Lokasi favorit berhasil dihapus.~s~')
        end)
    end
end)

-- Simpan Rating & Tip Perjalanan
RegisterNetEvent('eco_tablet:server:submitRating', function(ratingData)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not ratingData then return end
    local identifier = xPlayer.getIdentifier()

    local stars = tonumber(ratingData.stars) or 5
    local tip = tonumber(ratingData.tip) or 0
    local driverName = tostring(ratingData.driverName or 'Driverless AI')
    local service = tostring(ratingData.serviceType or 'EcoCab')

    if tip > 0 then
        if xPlayer.getMoney() >= tip then
            xPlayer.removeMoney(tip)
            TriggerClientEvent('esx:showNotification', src, ('~g~[EcoCab] Terima kasih telah memberi tip sebesar $%s!~s~'):format(tip))
        else
            tip = 0
        end
    end

    if MySQL then
        MySQL.insert('INSERT INTO eco_taxi_ratings (identifier, service_type, driver_name, rating, tip) VALUES (?, ?, ?, ?, ?)', {
            identifier, service, driverName, stars, tip
        })
    end

    TriggerClientEvent('esx:showNotification', src, ('~b~[EcoCab] Terima kasih atas ulasan %d bintang Anda!~s~'):format(stars))
end)

CreateThread(function()
    Wait(1000)
    if ESX and ESX.RegisterUsableItem then
        ESX.RegisterUsableItem(Config.ItemName or 'eco_tablet', function(source)
            TriggerClientEvent('eco_tablet:client:toggleTablet', source)
        end)
        print('^2[eco_tablet] Item usable `' .. (Config.ItemName or 'eco_tablet') .. '` terdaftar di ESX.^7')
    end
end)

exports('useEcoTablet', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local src = inventory.id
        TriggerClientEvent('eco_tablet:client:toggleTablet', src)
        return false
    end
end)

-- =========================================================================
-- LOGIKA ECOVIP & RIWAYAT PERJALANAN (TRIP HISTORY)
-- =========================================================================

-- Inisialisasi tabel EcoVIP & Trips otomatis saat resource start
CreateThread(function()
    Wait(600)
    if MySQL then
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `eco_taxi_vip` (
              `identifier` VARCHAR(64) PRIMARY KEY,
              `is_active` TINYINT(1) DEFAULT 1,
              `remaining_trips` INT DEFAULT 30,
              `purchased_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
              `expires_at` TIMESTAMP NULL,
              INDEX (`identifier`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]])

        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `eco_taxi_trips` (
              `id` INT AUTO_INCREMENT PRIMARY KEY,
              `identifier` VARCHAR(64) NOT NULL,
              `service_type` VARCHAR(25) NOT NULL,
              `origin_name` VARCHAR(80) DEFAULT 'Lokasi Penjemputan',
              `dest_name` VARCHAR(80) NOT NULL,
              `distance_km` DECIMAL(5,2) NOT NULL,
              `base_fare` INT NOT NULL,
              `final_fare` INT NOT NULL,
              `discount_applied` INT DEFAULT 0,
              `surge_multiplier` DECIMAL(3,2) DEFAULT 1.00,
              `driver_name` VARCHAR(80) NOT NULL,
              `rating` INT DEFAULT NULL,
              `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
              INDEX (`identifier`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]])
    end
end)

-- Ambil Data Status EcoVIP dan 15 Riwayat Trip Terakhir
RegisterNetEvent('eco_tablet:server:getEcoCabUserData', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local identifier = xPlayer.getIdentifier()

    if MySQL then
        MySQL.query([[
            SELECT remaining_trips, expires_at,
                   (expires_at > NOW() AND remaining_trips > 0) AS is_valid,
                   DATEDIFF(expires_at, NOW()) AS days_left
            FROM eco_taxi_vip
            WHERE identifier = ?
        ]], { identifier }, function(vipRes)
            local vipData = {
                active = false,
                remainingTrips = 0,
                daysLeft = 0,
                expired = false,
                expiresAt = nil
            }

            if vipRes and vipRes[1] then
                local row = vipRes[1]
                vipData.remainingTrips = row.remaining_trips or 0
                vipData.expiresAt = row.expires_at

                if row.is_valid == 1 then
                    vipData.active = true
                    vipData.daysLeft = math.max(1, row.days_left or 1)
                else
                    vipData.active = false
                    vipData.expired = true
                    vipData.daysLeft = 0
                end
            end

            MySQL.query([[
                SELECT id, service_type, origin_name, dest_name, distance_km,
                       final_fare, discount_applied, surge_multiplier, driver_name, rating,
                       DATE_FORMAT(created_at, '%d %b %H:%i') AS trip_date
                FROM eco_taxi_trips
                WHERE identifier = ?
                ORDER BY id DESC LIMIT 15
            ]], { identifier }, function(trips)
                TriggerClientEvent('eco_tablet:client:receiveEcoCabUserData', src, vipData, trips or {})
            end)
        end)
    end
end)

-- Pembelian Baru atau Perpanjangan Paket EcoVIP ($350, 10 Hari, 30 Trip)
RegisterNetEvent('eco_tablet:server:buyOrRenewEcoVIP', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local identifier = xPlayer.getIdentifier()

    local price = (Config.EcoVIP and Config.EcoVIP.Price) or 350
    local trips = (Config.EcoVIP and Config.EcoVIP.TripCount) or 30
    local days = (Config.EcoVIP and Config.EcoVIP.DurationDays) or 10

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)

        MySQL.query([[
            INSERT INTO eco_taxi_vip (identifier, is_active, remaining_trips, expires_at)
            VALUES (?, 1, ?, DATE_ADD(NOW(), INTERVAL ? DAY))
            ON DUPLICATE KEY UPDATE
                is_active = 1,
                remaining_trips = IF(expires_at > NOW() AND remaining_trips > 0, remaining_trips + VALUES(remaining_trips), VALUES(remaining_trips)),
                expires_at = IF(expires_at > NOW(), DATE_ADD(expires_at, INTERVAL ? DAY), DATE_ADD(NOW(), INTERVAL ? DAY))
        ]], { identifier, trips, days, days, days }, function()
            TriggerClientEvent('esx:showNotification', src, ('~g~[EcoVIP] Paket aktif! Anda mendapatkan %d voucher trip (Masa aktif %d hari).~s~'):format(trips, days))
            TriggerEvent('eco_tablet:server:getEcoCabUserData')
        end)
    else
        TriggerClientEvent('esx:showNotification', src, ('~r~[EcoVIP] Uang tunai Anda tidak mencukupi ($%d) untuk berlangganan paket.~s~'):format(price))
    end
end)

-- Pencatatan Trip Selesai & Pemotongan Kuota EcoVIP
RegisterNetEvent('eco_tablet:server:recordCompletedTrip', function(tripData)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not tripData then return end
    local identifier = xPlayer.getIdentifier()

    if MySQL then
        MySQL.insert([[
            INSERT INTO eco_taxi_trips 
            (identifier, service_type, origin_name, dest_name, distance_km, base_fare, final_fare, discount_applied, surge_multiplier, driver_name)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]], {
            identifier,
            tripData.serviceType or 'ecocab',
            tripData.originName or 'Lokasi Penjemputan',
            tripData.destName or 'Tujuan Anda',
            tonumber(tripData.distanceKm) or 1.0,
            tonumber(tripData.baseFare) or 30,
            tonumber(tripData.finalFare) or 30,
            tonumber(tripData.discountApplied) or 0,
            tonumber(tripData.surgeMultiplier) or 1.0,
            tripData.driverName or 'Driver EcoCab'
        })

        if tripData.usedVip then
            MySQL.query([[
                UPDATE eco_taxi_vip 
                SET remaining_trips = GREATEST(0, remaining_trips - 1)
                WHERE identifier = ? AND remaining_trips > 0
            ]], { identifier }, function()
                TriggerEvent('eco_tablet:server:getEcoCabUserData')
            end)
        end
    end
end)
