--[[
========================================================================================
 ██████╗ ██╗     ███████╗ █████╗ ███╗   ██╗███████╗██████╗ 
██╔════╝ ██║     ██╔════╝██╔══██╗████╗  ██║██╔════╝██╔══██╗
██║      ██║     █████╗  ███████║██╔██╗ ██║█████╗  ██║  ██║
██║      ██║     ██╔══╝  ██╔══██║██║╚██╗██║██╔══╝  ██║  ██║
╚██████╗ ███████╗███████╗██║  ██║██║ ╚████║███████╗██████╔╝
 ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚═════╝ 

                 ██████╗ ██╗   ██╗
                 ██╔══██╗╚██╗ ██╔╝
                 ██████╔╝ ╚████╔╝ 
                 ██╔══██╗  ╚██╔╝  
                 ██████╔╝   ██║   
                 ╚═════╝    ╚═╝   

██╗  ██╗ █████╗ ███████╗██╗███╗   ███╗
██║  ██║██╔══██╗╚══███╔╝██║████╗ ████║
███████║███████║  ███╔╝ ██║██╔████╔██║
██╔══██║██╔══██║ ███╔╝  ██║██║╚██╔╝██║
██║  ██║██║  ██║███████╗██║██║ ╚═╝ ██║
╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝     ╚═╝

██╗  ██╗███████╗██████╗ ██████╗ ███████╗██████╗  █████╗ 
██║  ██║██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗
███████║█████╗  ██████╔╝██████╔╝█████╗  ██████╔╝███████║
██╔══██║██╔══╝  ██╔══██╗██╔══██╗██╔══╝  ██╔══██╗██╔══██║
██║  ██║███████╗██║  ██║██║  ██║███████╗██║  ██║██║  ██║
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝
========================================================================================
--]]

local function GenerateUUID()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return template:gsub("[xy]", function(c)
        local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
        return string.format("%x", v)
    end)
end

lib.callback.register("prp-pressurewash:getZone", function(source, zoneId)
    local zone = PressureWashZones[zoneId]
    return zone
end)

lib.callback.register("prp-pressurewash:getZones", function(source)
    local zones = {}
    for k, v in pairs(PressureWashZones) do
        zones[k] = v.pos
    end
    return zones
end)

RegisterNetEvent("prp-pressurewash:subscribeToZone", function(zoneId)
    local source = source
    local zone = PressureWashZones[zoneId]
    if not zone then return end
    zone.subscribers[tostring(source)] = true
    if zone.active and zone.points then
        local msg = msgpack.pack_args(zoneId, zone.points, zone.active)
        local msgLen = msg:len()
        TriggerClientEventInternal("prp-pressurewash:zoneChanged", source, msg, msgLen)
    end
end)

RegisterNetEvent("prp-pressurewash:unsubscribeFromZone", function(zoneId)
    local zone = PressureWashZones[zoneId]
    if not zone then return end
    zone.subscribers[tostring(source)] = nil
end)

function OnZoneChange(zoneId, source, changedPoints)
    local zone = PressureWashZones[zoneId]
    if not zone then return end
    local msg = msgpack.pack_args(zoneId, changedPoints or zone.points, zone.active, source)
    local msgLen = msg:len()
    for k, v in pairs(zone.subscribers) do
        TriggerClientEventInternal("prp-pressurewash:zoneChanged", tonumber(k), msg, msgLen)
    end
end

Citizen.CreateThread(function()
    for k, v in pairs(PressureWashZones) do
        v.subscribers = {}
    end
end)

local generatorsToUpdate = {}

RegisterNetEvent("prp-pressurewash:updateGenerator", function(uuid, fuel, water)
    if fuel > 100 or water > 100 then return end
    if not generatorsToUpdate[uuid] then
        return
    end
    if fuel < 0 then
        fuel = 0
    end
    if water < 0 then
        water = 0
    end
    generatorsToUpdate[uuid].fuel = fuel
    generatorsToUpdate[uuid].water = water
    TriggerClientEvent("prp-pressurewash:onGeneratorUpdate", -1, uuid, fuel, water)
end)

RegisterNetEvent("prp-pressurewash:refillWater", function(uuid, genData, itemSlot)
    local diff = 100.0 - genData.water
    local itemData = bridge.inv.getItemMetaData(source, itemSlot)
    if not itemData then return end
    if itemData.durability and itemData.durability <= 0 then return end
    if not itemData.durability then
        itemData.durability = 100.0
    end
    local maxWater = itemData.durability
    if diff > maxWater then
        diff = maxWater
    end
    itemData.durability = itemData.durability - diff
    genData.water = genData.water + diff
    if not bridge.inv.setItemMetaData(source, itemSlot, itemData) then return end
    generatorsToUpdate[uuid].fuel = genData.fuel
    generatorsToUpdate[uuid].water = genData.water
    TriggerClientEvent("prp-pressurewash:onGeneratorUpdate", -1, uuid, genData.fuel, genData.water)
end)

RegisterNetEvent("prp-pressurewash:refillFuel", function(uuid, genData, itemSlot)
    local diff = 100.0 - genData.fuel
    local itemData = bridge.inv.getItemMetaData(source, itemSlot)
    if not itemData then return end
    itemData.durability = itemData.durability or 100.0
    if itemData.durability <= 0 then return end
    local maxFuel = itemData.durability
    if diff > maxFuel then
        diff = maxFuel
    end
    itemData.durability = itemData.durability - diff
    genData.fuel = genData.fuel + diff
    if not bridge.inv.setItemMetaData(source, itemSlot, itemData) then return end
    generatorsToUpdate[uuid].fuel = genData.fuel
    generatorsToUpdate[uuid].water = genData.water
    TriggerClientEvent("prp-pressurewash:onGeneratorUpdate", -1, uuid, genData.fuel, genData.water)
end)

RegisterNetEvent("prp-pressurewash:washedVehicles", function(vehicles)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    for k, v in pairs(vehicles) do
        local entity = NetworkGetEntityFromNetworkId(k)
        if not DoesEntityExist(entity) then
            vehicles[k] = nil
            goto continue
        end
        if #(playerCoords - GetEntityCoords(entity)) > 10.0 then
            vehicles[k] = nil
            goto continue
        end
        if NetworkGetEntityOwner(entity) == source then
            vehicles[k] = nil
            goto continue
        end
        TriggerClientEvent("prp-pressurewash:washVehicle", NetworkGetEntityOwner(entity), k, v)
        ::continue::
    end
end)

local function round(value, numDecimalPlaces)
	if numDecimalPlaces then
		local power = 10 ^ numDecimalPlaces
		return math.floor((value * power) + 0.5) / (power)
	else
		return math.floor(value + 0.5)
	end
end

RegisterCommand("press_find_zone", function(src, args)
    if tonumber(src) ~= 0 then return end
    if #args < 3 then print("Not enough arguments") return end

    local x = args[1]:gsub(",", "")
    local y = args[2]:gsub(",", "")
    local z = args[3]:gsub(",", "")

    local coords = vec3(tonumber(x) + 0.0, tonumber(y) + 0.0, tonumber(z) + 0.0)

    local dists = {}

    for i=1, #PressureWashZones do
        dists[#dists+1] = {
            pos = PressureWashZones[i].pos,
            dist = #(PressureWashZones[i].pos - coords)
        }
    end

    table.sort(dists, function(a, b) return a.dist < b.dist end)

    print("Closest zone: dist = " .. tostring(dists[1].dist) .. " pos = " .. tostring(round(dists[1].pos.x, 3)) .. ", " .. tostring(round(dists[1].pos.y, 3)) .. ", " .. tostring(round(dists[1].pos.z, 3)))
end, false)

lib.callback.register("prp-pressurewash:getPressureWashers", function(source)
    return generatorsToUpdate
end)

function PlaceGenerator(playerId, pos, metaData, slotId)
    local success, errMsg = bridge.inv.removeItem(playerId, "pressurewash", 1, metaData, slotId)
    if not success then
        bridge.fw.notify(playerId, "error", locale("FAILED_TO_REMOVE_ITEM"))
        return
    end
    local uuid = GenerateUUID()
    generatorsToUpdate[uuid] = {
        fuel = metaData.fuel or 100.0,
        water = metaData.water or 100.0,
        pos = pos
    }
    TriggerClientEvent("prp-pressurewash:newPressureWasher", -1, uuid, generatorsToUpdate[uuid])
end

RegisterServerEvent("prp-pressurewash:takeGenerator", function(uuid)
    local genData = generatorsToUpdate[uuid]
    if not genData then return end
    local metaData = {
        fuel = genData.fuel,
        water = genData.water,
    }
    bridge.inv.giveItem(source, "pressurewash", 1, metaData, false)
    generatorsToUpdate[uuid] = nil
    TriggerClientEvent("prp-pressurewash:removePressureWasher", -1, uuid)
end)