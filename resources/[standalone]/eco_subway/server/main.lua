local activeTrains = {}
local lastSpawnTime = 0
local trainCounter = 0

local function GetActiveTrainCount()
    local count = 0
    for netId, _ in pairs(activeTrains) do
        local entity = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(entity) then
            count = count + 1
        else
            activeTrains[netId] = nil
        end
    end
    return count
end

-- Helper menyusun paket telemetri kereta aktif untuk PIDS & Schedule
local function BuildTelemetrySnapshot()
    local now = os.time()
    local validTrains = {}

    for netId, info in pairs(activeTrains) do
        local entity = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(entity) then
            local coords = GetEntityCoords(entity)
            table.insert(validTrains, {
                netId = netId,
                code = info.code,
                coords = vector3(coords.x, coords.y, coords.z),
                lastStationIdx = info.lastStationIdx or 1,
                status = info.status or "EN_ROUTE",
                elapsedInStatus = math.max(0, now - (info.statusUpdatedAt or now))
            })
        else
            activeTrains[netId] = nil
        end
    end

    local nextDispatchIn = 0
    if #validTrains < ((Config and Config.MaxTrainsPerRoute) or 2) then
        local headway = (Config and Config.HeadwaySeconds) or 240
        nextDispatchIn = math.max(0, headway - (now - lastSpawnTime))
    end

    return validTrains, nextDispatchIn
end

-- Thread Penjadwalan Headway Otomatis
CreateThread(function()
    while true do
        Wait(5000)
        local currentTime = os.time()
        local currentCount = GetActiveTrainCount()
        local maxTrains = (Config and Config.MaxTrainsPerRoute) or 2
        local headway = (Config and Config.HeadwaySeconds) or 240

        if currentCount < maxTrains then
            local shouldSpawn = false
            if not lastSpawnTime or lastSpawnTime == 0 then
                shouldSpawn = true
            elseif (currentTime - lastSpawnTime) >= headway then
                shouldSpawn = true
            end

            if shouldSpawn then
                local players = GetPlayers()
                if #players > 0 then
                    local targetPlayer = tonumber(players[math.random(1, #players)])
                    lastSpawnTime = currentTime
                    local startIdx = (currentCount == 0) and 4 or 1
                    print(('[eco_subway] Dispatching Metro Train ke Player ID: %s (Stasiun %s)'):format(targetPlayer, startIdx))
                    TriggerClientEvent('eco_subway:client:dispatchTrain', targetPlayer, startIdx)
                end
            end
        end
    end
end)

-- Thread Sinkronisasi Live Telemetry untuk PIDS Peron Stasiun (Setiap 2 Detik)
CreateThread(function()
    while true do
        Wait(2000)
        local players = GetPlayers()
        if #players > 0 then
            local validTrains, nextDispatchIn = BuildTelemetrySnapshot()
            TriggerClientEvent('eco_subway:client:syncPIDSData', -1, validTrains, nextDispatchIn)
        end
    end
end)

RegisterCommand('testmetro', function(source, args)
    local src = source
    local stationIdx = tonumber(args[1]) or 4
    if stationIdx < 1 or stationIdx > #Config.Stations then stationIdx = 4 end

    if src == 0 then
        local players = GetPlayers()
        if #players > 0 then
            TriggerClientEvent('eco_subway:client:dispatchTrain', tonumber(players[1]), stationIdx)
            print(('[eco_subway] Metro test diberangkatkan di Stasiun #%s'):format(stationIdx))
        end
    else
        TriggerClientEvent('eco_subway:client:dispatchTrain', src, stationIdx)
        TriggerClientEvent('esx:showNotification', src, ('~b~[eco_subway]~s~ Memanggil kereta di stasiun: ~y~%s~s~'):format(Config.Stations[stationIdx].name))
    end
end, false)

RegisterCommand('clearmetro', function(source)
    TriggerClientEvent('eco_subway:client:clearAllTrains', -1)
    activeTrains = {}
    lastSpawnTime = 0
    trainCounter = 0
    if source > 0 then
        TriggerClientEvent('esx:showNotification', source, '~y~[eco_subway] Seluruh rangkaian kereta telah dibersihkan.~s~')
    end
end, false)

RegisterNetEvent('eco_subway:server:payBoarding', function(netTrain, autoWalkIn)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local hasTicket = false
    if Config.TicketRequired then
        if exports.ox_inventory then
            local item = exports.ox_inventory:GetItem(src, Config.TicketItem)
            if item and item.count >= Config.TicketAmount then
                exports.ox_inventory:RemoveItem(src, Config.TicketItem, Config.TicketAmount)
                TriggerClientEvent('esx:showNotification', src, '~g~[LST Metro] Tiket Metro berhasil digunakan.~s~')
                hasTicket = true
            end
        else
            local item = xPlayer.getInventoryItem(Config.TicketItem)
            if item and item.count >= Config.TicketAmount then
                xPlayer.removeInventoryItem(Config.TicketItem, Config.TicketAmount)
                TriggerClientEvent('esx:showNotification', src, '~g~[LST Metro] Tiket Metro berhasil digunakan.~s~')
                hasTicket = true
            end
        end

        if not hasTicket and Config.UseCashIfNoItem then
            if xPlayer.getMoney() >= Config.FarePrice then
                xPlayer.removeMoney(Config.FarePrice)
                TriggerClientEvent('esx:showNotification', src, ('~g~[LST Metro] Ongkos Metro terpotong otomatis: $%s~s~'):format(Config.FarePrice))
                hasTicket = true
            end
        end
    else
        hasTicket = true
    end

    if hasTicket then
        TriggerClientEvent('eco_subway:client:boardConfirmed', src, netTrain, autoWalkIn)
    else
        TriggerClientEvent('esx:showNotification', src, '~r~[LST Metro] Anda tidak memiliki tiket metro atau uang tunai ($' .. Config.FarePrice .. ')!~s~')
        TriggerClientEvent('eco_subway:client:denyBoarding', src, netTrain)
    end
end)

RegisterNetEvent('eco_subway:server:registerTrain', function(netTrain, startStationIdx)
    trainCounter = trainCounter + 1
    local trainCode = ("LST-%02d"):format(trainCounter)
    activeTrains[netTrain] = {
        netId = netTrain,
        code = trainCode,
        spawnedAt = os.time(),
        lastStationIdx = startStationIdx or 4,
        status = "STOPPED",
        statusUpdatedAt = os.time()
    }
    print(('[eco_subway] Rangkaian Metro %s terdaftar. NetID: %s'):format(trainCode, netTrain))
    TriggerClientEvent('eco_subway:client:syncTrainBlip', -1, netTrain, trainCode)
end)

RegisterNetEvent('eco_subway:server:updateTrainStatus', function(netTrain, stationIdx, status)
    if activeTrains[netTrain] then
        activeTrains[netTrain].lastStationIdx = stationIdx
        activeTrains[netTrain].status = status
        activeTrains[netTrain].statusUpdatedAt = os.time()
    end
    TriggerClientEvent('eco_subway:client:stationAnnouncement', -1, netTrain, stationIdx, status)
end)

RegisterNetEvent('eco_subway:server:removeTrain', function(netTrain)
    if activeTrains[netTrain] then
        activeTrains[netTrain] = nil
        TriggerClientEvent('eco_subway:client:removeTrainBlip', -1, netTrain)
    end
end)

RegisterNetEvent('eco_subway:server:requestSchedule', function()
    local src = source
    local validTrains, nextDispatchIn = BuildTelemetrySnapshot()
    TriggerClientEvent('eco_subway:client:receiveSchedule', src, validTrains, nextDispatchIn)
end)
