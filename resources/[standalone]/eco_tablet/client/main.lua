local isTabletOpen = false
local tabletPropEntity = nil

local cachedBuses = {}
local cachedTrains = {}
local nextBusDispatchIn = 0
local nextBusDispatchByRoute = { [1] = 0, [2] = 0 }
local nextTrainDispatchIn = 0

local cachedSavedPlaces = {}
local activeEcoCab = nil -- { status, serviceType, destName, coords, driverName, isAutonomous, estimatedFare, etaMin, distKm, gasStop }

-- Listener telemetri kereta dari eco_subway
RegisterNetEvent('eco_subway:client:syncPIDSData', function(trainsData, nextDispatchIn)
    if type(trainsData) == 'table' then
        cachedTrains = {}
        for _, tr in ipairs(trainsData) do
            table.insert(cachedTrains, {
                netId = tr.netId,
                code = tr.code,
                coords = { x = tr.coords.x, y = tr.coords.y, z = tr.coords.z },
                lastStationIdx = tr.lastStationIdx or 1,
                status = tr.status or "EN_ROUTE",
                elapsedInStatus = tr.elapsedInStatus or 0
            })
        end
        nextTrainDispatchIn = nextDispatchIn or 0
        if isTabletOpen then
            SendLiveUpdateToNUI()
        end
    end
end)

-- Listener snapshot transit dari server eco_tablet
RegisterNetEvent('eco_tablet:client:syncTelemetry', function(snapshot)
    if not snapshot then return end
    if snapshot.buses then
        cachedBuses = snapshot.buses
    end
    if snapshot.trains and (#snapshot.trains > 0 or #cachedTrains == 0) then
        cachedTrains = snapshot.trains
    end
    if snapshot.nextBusDispatchIn ~= nil then
        nextBusDispatchIn = snapshot.nextBusDispatchIn
    end
    if snapshot.nextBusDispatchByRoute then
        nextBusDispatchByRoute = snapshot.nextBusDispatchByRoute
    end
    if snapshot.nextTrainDispatchIn ~= nil and nextTrainDispatchIn == 0 then
        nextTrainDispatchIn = snapshot.nextTrainDispatchIn
    end
    if isTabletOpen then
        SendLiveUpdateToNUI()
    end
end)

-- Penerima data Alamat Tersimpan dari Database
RegisterNetEvent('eco_tablet:client:receiveSavedPlaces', function(places)
    cachedSavedPlaces = places or {}
    if isTabletOpen then
        SendNUIMessage({
            action = 'updateSavedPlaces',
            savedPlaces = cachedSavedPlaces
        })
    end
end)

-- =========================================================================
-- LISTENER EVENT DARI eco_taxi UNTUK UPDATE STATE UI ECOCAB PADA TABLET
-- =========================================================================
RegisterNetEvent('eco_taxi:client:dispatchSmartTaxi', function(pickupCoords, destCoords, destName, estimatedFare, serviceType, driverName)
    local sType = serviceType or 'ecocab'
    local sCfg = Config.EcoCabServices[sType] or Config.EcoCabServices['ecocab']
    local isAI = sCfg.isAutonomous

    local pCoords = GetEntityCoords(PlayerPedId())
    local distKm = #(pCoords - destCoords) / 1000.0
    local speedMs = (sCfg.speedKmh or 80) / 3.6
    local etaMin = math.max(1, math.ceil((distKm * 1000.0) / speedMs / 60))

    activeEcoCab = {
        status = 'DISPATCHED',
        serviceType = sType,
        serviceName = sCfg.name,
        destName = destName or 'Tujuan Pilihan',
        estimatedFare = estimatedFare or sCfg.minFare,
        coords = destCoords,
        isAutonomous = isAI,
        driverName = isAI and "EcoLuxe Autonomous AI (Driverless)" or (driverName or "Driver EcoCab"),
        distKm = string.format("%.1f", distKm),
        etaMin = etaMin,
        gasStop = false
    }

    if isTabletOpen then
        SendNUIMessage({
            action = 'ecoCabUpdate',
            activeRide = activeEcoCab
        })
    end
end)

-- Notifikasi Event Random Mampir Pom Bensin (EcoRide)
RegisterNetEvent('eco_taxi:client:driverFuelStop', function(gasStationName)
    if activeEcoCab then
        activeEcoCab.gasStop = true
        activeEcoCab.gasStationName = gasStationName or "SPBU Terdekat"
        if isTabletOpen then
            SendNUIMessage({
                action = 'ecoCabUpdate',
                activeRide = activeEcoCab
            })
        end
    end
end)

RegisterNetEvent('eco_taxi:client:cancelCurrentRide', function()
    activeEcoCab = nil
    if isTabletOpen then
        SendNUIMessage({
            action = 'ecoCabUpdate',
            activeRide = nil
        })
    end
end)

-- Selesai Trip: Tampilkan Rating Modal 1-5 Bintang di Tablet!
-- Parameter dari server: finalFare (number), driverName (string), serviceType (string)
RegisterNetEvent('eco_taxi:client:rideCompletedDismissTaxi', function(finalFare, driverName, serviceType)
    local sType = serviceType or (activeEcoCab and activeEcoCab.serviceType) or 'ecocab'
    local sCfg  = Config.EcoCabServices[sType] or Config.EcoCabServices['ecocab']

    local completedInfo = {
        serviceType  = sType,
        serviceName  = sCfg.name,
        driverName   = driverName or (activeEcoCab and activeEcoCab.driverName) or 'Driver EcoCab',
        isAutonomous = sCfg.isAutonomous or false,
        destName     = (activeEcoCab and activeEcoCab.destName) or 'Tujuan Anda',
        finalFare    = tonumber(finalFare) or (activeEcoCab and activeEcoCab.estimatedFare) or 30
    }
    activeEcoCab = nil

    -- Buka tablet dan tampilkan modal rating pasca-trip
    OpenEcoTablet()
    SendNUIMessage({
        action = 'showRatingModal',
        ride   = completedInfo
    })
end)

-- Fungsi Animasi iPad
local function StartTabletAnimation()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        return
    end

    RequestAnimDict(Config.AnimDict)
    local t = 0
    while not HasAnimDictLoaded(Config.AnimDict) and t < 100 do
        Wait(10)
        t = t + 1
    end

    RequestModel(Config.TabletProp)
    t = 0
    while not HasModelLoaded(Config.TabletProp) and t < 100 do
        Wait(10)
        t = t + 1
    end

    if HasModelLoaded(Config.TabletProp) then
        local pCoords = GetEntityCoords(ped)
        tabletPropEntity = CreateObject(Config.TabletProp, pCoords.x, pCoords.y, pCoords.z + 0.2, true, true, true)
        local bone = GetPedBoneIndex(ped, Config.BoneIndex or 28422)
        AttachEntityToEntity(
            tabletPropEntity, ped, bone,
            Config.PropOffset.x, Config.PropOffset.y, Config.PropOffset.z,
            Config.PropRotation.x, Config.PropRotation.y, Config.PropRotation.z,
            true, true, false, true, 1, true
        )
        SetModelAsNoLongerNeeded(Config.TabletProp)
    end

    if HasAnimDictLoaded(Config.AnimDict) then
        TaskPlayAnim(ped, Config.AnimDict, Config.AnimName, 3.0, 3.0, -1, 49, 0, false, false, false)
    end
end

local function StopTabletAnimation()
    local ped = PlayerPedId()
    ClearPedSecondaryTask(ped)
    if tabletPropEntity and DoesEntityExist(tabletPropEntity) then
        DeleteObject(tabletPropEntity)
        tabletPropEntity = nil
    end
end

function SendLiveUpdateToNUI()
    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)

    local busStopsPayload = {}
    for _, s in ipairs(Config.BusStops) do
        table.insert(busStopsPayload, {
            id = s.id,
            code = s.code,
            name = s.name,
            zone = s.zone,
            routes = s.routes,
            routeLabel = s.routeLabel,
            coords = { x = s.coords.x, y = s.coords.y, z = s.coords.z },
            transfer = s.transfer
        })
    end

    local busRoutesPayload = {}
    for rId, rData in pairs(Config.BusRoutes) do
        local nodesList = {}
        for _, nd in ipairs(rData.nodes) do
            table.insert(nodesList, {
                id = nd.id,
                stopId = nd.stopId,
                name = nd.name,
                coords = { x = nd.coords.x, y = nd.coords.y, z = nd.coords.z },
                isWaypoint = nd.isWaypoint == true
            })
        end
        busRoutesPayload[tostring(rId)] = {
            id = rData.id,
            shortName = rData.shortName,
            name = rData.name,
            color = rData.color,
            headwaySeconds = rData.headwaySeconds,
            maxBuses = rData.maxBuses,
            nodes = nodesList
        }
    end

    local metroStationsPayload = {}
    for _, st in ipairs(Config.MetroStations) do
        table.insert(metroStationsPayload, {
            id = st.id,
            code = st.code,
            name = st.name,
            zone = st.zone,
            coords = { x = st.coords.x, y = st.coords.y, z = st.coords.z },
            transfer = st.transfer
        })
    end

    local taxiDestinations = {}
    local okExp, resExp = pcall(function()
        return exports['eco_taxi']:GetQuickDestinations()
    end)
    if okExp and type(resExp) == 'table' then
        for _, qd in ipairs(resExp) do
            table.insert(taxiDestinations, {
                id = qd.id,
                name = qd.name,
                coords = { x = qd.coords.x, y = qd.coords.y, z = qd.coords.z }
            })
        end
    end

    SendNUIMessage({
        action = 'updateTelemetry',
        playerCoords = { x = pCoords.x, y = pCoords.y, z = pCoords.z },
        busTransit = Config.BusTransit,
        busRoutes = busRoutesPayload,
        subwayTransit = Config.SubwayTransit,
        busStops = busStopsPayload,
        metroStations = metroStationsPayload,
        buses = cachedBuses,
        trains = cachedTrains,
        nextBusDispatchIn = nextBusDispatchIn,
        nextBusDispatchByRoute = nextBusDispatchByRoute,
        nextTrainDispatchIn = nextTrainDispatchIn,
        ecoCabDestinations = taxiDestinations,
        savedPlaces = cachedSavedPlaces,
        activeEcoCab = activeEcoCab,
        services = Config.EcoCabServices
    })
end

function OpenEcoTablet()
    if isTabletOpen then return end
    isTabletOpen = true

    StartTabletAnimation()
    SetNuiFocus(true, true)

    TriggerServerEvent('eco_tablet:server:requestSnapshot')
    TriggerServerEvent('eco_subway:server:requestSchedule')
    TriggerServerEvent('eco_tablet:server:getSavedPlaces')

    SendNUIMessage({
        action = 'openTablet'
    })
    SendLiveUpdateToNUI()
end

function CloseEcoTablet()
    if not isTabletOpen then return end
    isTabletOpen = false

    SetNuiFocus(false, false)
    StopTabletAnimation()

    SendNUIMessage({
        action = 'closeTablet'
    })
end

exports('OpenEcoTablet', OpenEcoTablet)
exports('CloseEcoTablet', CloseEcoTablet)

RegisterNetEvent('eco_tablet:client:toggleTablet', function()
    if isTabletOpen then
        CloseEcoTablet()
    else
        OpenEcoTablet()
    end
end)

for _, cmd in ipairs(Config.Commands or { 'tablet', 'ecolink', 'ecocab' }) do
    RegisterCommand(cmd, function()
        if isTabletOpen then
            CloseEcoTablet()
        else
            OpenEcoTablet()
        end
    end, false)
end

if Config.DefaultKeybind then
    RegisterKeyMapping('ecolink', 'Buka iPad EcoLink Transit Schedule', 'keyboard', Config.DefaultKeybind)
end

RegisterNUICallback('closeTablet', function(_, cb)
    CloseEcoTablet()
    cb({ ok = true })
end)

RegisterNUICallback('setWaypoint', function(data, cb)
    if data and data.x and data.y then
        SetNewWaypoint(tonumber(data.x) + 0.0, tonumber(data.y) + 0.0)
        local label = data.name or 'Titik Transit'
        if ESX and ESX.ShowNotification then
            ESX.ShowNotification(('~b~[EcoLink iPad]~s~ GPS diarahkan ke: ~y~%s~s~'):format(label))
        end
        cb({ ok = true })
    else
        cb({ ok = false })
    end
end)

-- Ambil Koordinat Waypoint Peta GTA V
RegisterNUICallback('getMapWaypoint', function(_, cb)
    local wpBlip = GetFirstBlipInfoId(8) -- 8 = Waypoint Sprite
    if DoesBlipExist(wpBlip) then
        local wpCoords = GetBlipInfoIdCoord(wpBlip)
        cb({ ok = true, x = wpCoords.x, y = wpCoords.y, z = wpCoords.z })
    else
        cb({ ok = false, error = "Tandai titik Waypoint di Peta (Pause Map) terlebih dahulu!" })
    end
end)

-- Simpan Alamat Baru ke SQL
RegisterNUICallback('saveCustomPlace', function(data, cb)
    if data and data.label and data.coords then
        TriggerServerEvent('eco_tablet:server:savePlace', data)
        cb({ ok = true })
    else
        cb({ ok = false, error = "Data tidak lengkap" })
    end
end)

-- Hapus Alamat Tersimpan dari SQL
RegisterNUICallback('deleteCustomPlace', function(data, cb)
    if data and data.id then
        TriggerServerEvent('eco_tablet:server:deletePlace', data.id)
        cb({ ok = true })
    else
        cb({ ok = false })
    end
end)

-- Submit Rating & Tip Pasca-Trip
RegisterNUICallback('submitRating', function(data, cb)
    if data then
        TriggerServerEvent('eco_tablet:server:submitRating', data)
        cb({ ok = true })
    else
        cb({ ok = false })
    end
end)

-- Order Taxi Ride (EcoLuxe / EcoCab / EcoRide)
RegisterNUICallback('requestEcoCabRide', function(data, cb)
    if data and data.x and data.y and data.z and data.name then
        local destVec = vector3(tonumber(data.x) + 0.0, tonumber(data.y) + 0.0, tonumber(data.z) + 0.0)
        local destName = tostring(data.name)
        local serviceType = tostring(data.serviceType or 'ecocab')

        local driverName = nil
        local isAI = (serviceType == 'ecoluxe')
        if not isAI and Config.IndonesianDriverNames and #Config.IndonesianDriverNames > 0 then
            driverName = Config.IndonesianDriverNames[math.random(1, #Config.IndonesianDriverNames)]
        end

        local ok, err = pcall(function()
            exports['eco_taxi']:RequestEcoCabRide(destVec, destName, serviceType, driverName)
        end)

        if ok then
            cb({ ok = true })
        else
            print('^1[eco_tablet] Gagal memanggil export RequestEcoCabRide: ' .. tostring(err) .. '^7')
            cb({ ok = false, error = tostring(err) })
        end
    else
        cb({ ok = false, error = 'Data destinasi tidak lengkap.' })
    end
end)

RegisterNUICallback('cancelEcoCabRide', function(_, cb)
    local ok, err = pcall(function()
        exports['eco_taxi']:CancelEcoCabRide()
    end)
    if ok then
        activeEcoCab = nil
        cb({ ok = true })
    else
        print('^1[eco_tablet] Gagal memanggil export CancelEcoCabRide: ' .. tostring(err) .. '^7')
        cb({ ok = false, error = tostring(err) })
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() and isTabletOpen then
        CloseEcoTablet()
    end
end)

-- =========================================================================
-- LOGIKA CLIENT UNTUK ECOVIP, SURGE PRICING & TRIP HISTORY
-- =========================================================================
local cachedEcoVip = { active = false, remainingTrips = 0, daysLeft = 0 }
local cachedTrips = {}
local isSurgeActive = false
local currentSurgeReason = "Normal"

-- Evaluasi Kondisi Surge Pricing
local function EvaluateSurgePricing()
    if not Config.SurgePricing or not Config.SurgePricing.Enabled then
        return false, "Normal", 1.0
    end

    local hour = GetClockHours()
    local isNight = (hour >= Config.SurgePricing.NightHours.Start or hour < Config.SurgePricing.NightHours.Finish)
    local currentWeatherHash = GetPrevWeatherTypeHashName()
    local weatherReason = Config.SurgePricing.BadWeatherTypes[currentWeatherHash]

    local surgeMult = (cachedEcoVip and cachedEcoVip.active) and (Config.EcoVIP.SurgeMultiplier or 1.05) or Config.SurgePricing.Multiplier

    if weatherReason and isNight then
        return true, ("Cuaca Buruk (%s) & Jam Malam"):format(weatherReason), surgeMult
    elseif weatherReason then
        return true, ("Cuaca Buruk (%s)"):format(weatherReason), surgeMult
    elseif isNight then
        return true, "Tarif Jam Malam (22:00 - 05:00)", surgeMult
    end

    return false, "Normal", 1.0
end

-- Thread Check Surge Otomatis setiap 5 detik
CreateThread(function()
    while true do
        Wait(5000)
        local active, reason, multiplier = EvaluateSurgePricing()
        if active ~= isSurgeActive or reason ~= currentSurgeReason then
            isSurgeActive = active
            currentSurgeReason = reason

            if isTabletOpen then
                SendNUIMessage({
                    action = 'updateSurgePricing',
                    active = isSurgeActive,
                    multiplier = multiplier,
                    reason = currentSurgeReason
                })
            end
        end
    end
end)

-- Penerima Data EcoVIP & Riwayat dari Server
RegisterNetEvent('eco_tablet:client:receiveEcoCabUserData', function(vipData, trips)
    cachedEcoVip = vipData or cachedEcoVip
    cachedTrips = trips or {}

    if isTabletOpen then
        SendNUIMessage({
            action = 'updateEcoCabUserData',
            vip = cachedEcoVip,
            trips = cachedTrips
        })
    end
end)

-- Callback Beli / Perpanjang Paket EcoVIP
RegisterNUICallback('buyEcoVIP', function(_, cb)
    TriggerServerEvent('eco_tablet:server:buyOrRenewEcoVIP')
    cb({ ok = true })
end)

-- Callback Refresh Data EcoCab
RegisterNUICallback('getEcoCabUserData', function(_, cb)
    TriggerServerEvent('eco_tablet:server:getEcoCabUserData')
    cb({ ok = true })
end)
