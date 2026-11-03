local activeRouteBuses = {}
local lastSpawnTimeByRoute = {}

local function GetActiveBusCountForRoute(routeId)
    local count = 0
    for netId, info in pairs(activeRouteBuses) do
        local entity = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(entity) then
            if info.routeId == routeId then
                count = count + 1
            end
        else
            activeRouteBuses[netId] = nil
        end
    end
    return count
end

CreateThread(function()
    while Config == nil or Config.Routes == nil do
        Wait(100)
    end

    local lastGlobalDispatchTime = 0

    while true do
        Wait(5000)
        local currentTime = os.time()
        local routes = Config.Routes or { [1] = { id = 1, name = 'Route 1', stops = Config.RouteLoop } }

        for routeId, routeData in ipairs(routes) do
            local currentActiveCount = GetActiveBusCountForRoute(routeId)
            local maxBuses = routeData.maxBuses or Config.MaxBusesPerRoute or 2
            local headway = routeData.headwaySeconds or Config.HeadwaySeconds or 180
            local lastSpawn = lastSpawnTimeByRoute[routeId] or 0

            if currentActiveCount < maxBuses then
                local shouldSpawn = false
                if lastSpawn == 0 then
                    shouldSpawn = true
                elseif (currentTime - lastSpawn) >= headway then
                    shouldSpawn = true
                end

                if shouldSpawn and (currentTime - lastGlobalDispatchTime) >= 35 then
                    local players = GetPlayers()
                    if #players > 0 then
                        local targetPlayer = tonumber(players[math.random(1, #players)])
                        lastSpawnTimeByRoute[routeId] = currentTime
                        lastGlobalDispatchTime = currentTime
                        print(('[eco_bus] Dispatching bus [Rute #%s: %s] ke Player ID: %s'):format(routeId, routeData.name or routeId, targetPlayer))
                        TriggerClientEvent('eco_bus:client:dispatchNewBus', targetPlayer, routeId, 1)
                        break
                    end
                end
            end
        end
    end
end)

RegisterCommand('testbus', function(source, args)
    local src = source
    local routeId = tonumber(args[1]) or 1
    if not Config.Routes or not Config.Routes[routeId] then
        routeId = 1
    end
    local routeName = (Config.Routes and Config.Routes[routeId] and Config.Routes[routeId].name) or ("Route " .. routeId)

    if src == 0 then
        local players = GetPlayers()
        if #players > 0 then
            TriggerClientEvent('eco_bus:client:dispatchNewBus', tonumber(players[1]), routeId, 1)
            print(('[eco_bus] Bus test [%s] diberangkatkan via konsol server!'):format(routeName))
        end
    else
        TriggerClientEvent('eco_bus:client:dispatchNewBus', src, routeId, 1)
        TriggerClientEvent('esx:showNotification', src, ('~g~[eco_bus] Memerintahkan spawn bus (%s) ke halte 1...~s~'):format(routeName))
    end
end, false)

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

RegisterNetEvent('eco_bus:server:registerScheduledBus', function(netVeh, routeId)
    routeId = routeId or 1
    activeRouteBuses[netVeh] = { routeId = routeId, spawnedAt = os.time() }
    print(('[eco_bus] Bus [Rute #%s] berhasil terdaftar di server. NetID: %s'):format(routeId, netVeh))
    TriggerClientEvent('eco_bus:client:syncScheduledBlip', -1, netVeh, routeId)
end)

RegisterNetEvent('eco_bus:server:removeScheduledBus', function(netVeh)
    if activeRouteBuses[netVeh] then
        activeRouteBuses[netVeh] = nil
        TriggerClientEvent('eco_bus:client:removeScheduledBlip', -1, netVeh)
    end
end)
