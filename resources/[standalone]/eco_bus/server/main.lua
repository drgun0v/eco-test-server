local activeRouteBuses = {}
local lastSpawnTime = 0

local function GetActiveBusCount()
    local count = 0
    for netId, _ in pairs(activeRouteBuses) do
        local entity = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(entity) then
            count = count + 1
        else
            activeRouteBuses[netId] = nil
        end
    end
    return count
end

-- Thread Otomatis Headway
CreateThread(function()
    while true do
        Wait(5000)
        local currentTime = os.time()
        local currentActiveCount = GetActiveBusCount()
        local maxBuses = (Config and Config.MaxBusesPerRoute) or 3
        local headway = (Config and Config.HeadwaySeconds) or 180

        if currentActiveCount < maxBuses then
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
                    print(('[eco_bus] Dispatching bus rute ke Player ID: %s'):format(targetPlayer))
                    TriggerClientEvent('eco_bus:client:dispatchNewBus', targetPlayer, 1)
                end
            end
        end
    end
end)

-- Command Test Langsung: Ketik /testbus di chat atau F8
RegisterCommand('testbus', function(source)
    local src = source
    if src == 0 then
        local players = GetPlayers()
        if #players > 0 then
            TriggerClientEvent('eco_bus:client:dispatchNewBus', tonumber(players[1]), 1)
            print('[eco_bus] Bus test diberangkatkan via konsol server!')
        end
    else
        TriggerClientEvent('eco_bus:client:dispatchNewBus', src, 1)
        TriggerClientEvent('esx:showNotification', src, '~g~[eco_bus] Memerintahkan spawn bus ke halte 1...~s~')
    end
end, false)

-- Validasi Ongkos
RegisterNetEvent('eco_bus:server:payBoarding', function(netVeh)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local hasTicket = false
    if Config.TicketRequired then
        if exports.ox_inventory then
            local item = exports.ox_inventory:GetItem(src, Config.TicketItem)
            if item and item.count >= Config.TicketAmount then
                exports.ox_inventory:RemoveItem(src, Config.TicketItem, Config.TicketAmount)
                hasTicket = true
            end
        else
            local item = xPlayer.getInventoryItem(Config.TicketItem)
            if item and item.count >= Config.TicketAmount then
                xPlayer.removeInventoryItem(Config.TicketItem, Config.TicketAmount)
                hasTicket = true
            end
        end

        if not hasTicket and Config.UseCashIfNoItem then
            if xPlayer.getMoney() >= Config.FarePrice then
                xPlayer.removeMoney(Config.FarePrice)
                TriggerClientEvent('esx:showNotification', src, ('~g~Berhasil membayar tiket bus: $%s~s~'):format(Config.FarePrice))
                hasTicket = true
            end
        end
    else
        hasTicket = true
    end

    if hasTicket then
        TriggerClientEvent('eco_bus:client:boardConfirmed', src, netVeh)
    else
        TriggerClientEvent('esx:showNotification', src, '~r~Anda tidak punya tiket bus atau uang yang cukup!~s~')
    end
end)

RegisterNetEvent('eco_bus:server:registerScheduledBus', function(netVeh)
    activeRouteBuses[netVeh] = { spawnedAt = os.time() }
    print(('[eco_bus] Bus berhasil terdaftar di server. NetID: %s'):format(netVeh))
    TriggerClientEvent('eco_bus:client:syncScheduledBlip', -1, netVeh)
end)

RegisterNetEvent('eco_bus:server:removeScheduledBus', function(netVeh)
    if activeRouteBuses[netVeh] then
        activeRouteBuses[netVeh] = nil
        TriggerClientEvent('eco_bus:client:removeScheduledBlip', -1, netVeh)
    end
end)
