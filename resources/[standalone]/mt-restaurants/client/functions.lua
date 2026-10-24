---@param coords vector
---@param sprite integer
---@param display integer
---@param scale integer
---@param color integer
---@param label string
---@return integer
createBlip = function(coords, sprite, display, scale, color, label)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, display)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, scale)
    SetBlipColour(blip, color)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(label)
    EndTextCommandSetBlipName(blip)
    return blip
end

---@param model string
loadModel = function(model)
    local time = 1000
    if not HasModelLoaded(model) then
        while not HasModelLoaded(model) do
            if time > 0 then time = time - 1 RequestModel(model) else time = 1000 break end Wait(10)
        end
    end 
end

---@param dict string
loadAnimDict = function(dict)
    if not HasAnimDictLoaded(dict) then
        while not HasAnimDictLoaded(dict) do RequestAnimDict(dict) Wait(5) end
    end
end

---@param coords vector
---@param model string
---@param anim table
---@return integer
createPed = function(coords, model, anim)
    loadModel(model)
    local ped =  CreatePed(4, GetHashKey(model), coords.x, coords.y, coords.z, coords.w, false, true)
    SetEntityHeading(ped, coords.w)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    if anim.scenario then
        TaskStartScenarioInPlace(ped, anim.scenario, 0, true)
    elseif anim.dict and anim.clip then
        loadAnimDict(anim.dict)
        TaskPlayAnim(ped, anim.dict, anim.clip, 8.0, 0.0, -1, 1, 0.0, false, false, false)
    end
    return ped
end

---@param job string
---@param id string | integer
onZoneEnter = function(job, id)
    playerInsideRestaurant = true
    if getPlayerJob() == job then
        if Config.inventory == 'ox_inventory' then lib.callback.await('mt-restaurants:server:setOnlineJobPlayers', false, job, 'add') end
        --if Config.inventory == 'ox_inventory' then TriggerServerEvent('mt-restaurants:server:updateSpawnedShopPeds', id, 'delete') end
        if Config.toggleDutyZones then
            if Config.framework == 'qb' then
                local PlayerData = Config.core.Functions.GetPlayerData()
                if not PlayerData.job.onduty then TriggerServerEvent("QBCore:ToggleDuty") end
            elseif Config.framework == 'qbx' then
                if not QBX.PlayerData.job.onduty then TriggerServerEvent("QBCore:ToggleDuty") end
            end
        end
    end
        Wait(100)
        updateOfflineShop(id, 'spawn')
end

---@param job string
---@param id string | integer
onZoneExit = function(job, id)
    playerInsideRestaurant = false
    if getPlayerJob() == job then
        if Config.inventory == 'ox_inventory' then lib.callback.await('mt-restaurants:server:setOnlineJobPlayers', false, job, 'remove') end
        --if Config.inventory == 'ox_inventory' then TriggerServerEvent('mt-restaurants:server:updateSpawnedShopPeds', id, 'spawn') end
        if Config.toggleDutyZones then
            if Config.framework == 'qb' then
                local PlayerData = Config.core.Functions.GetPlayerData()
                if PlayerData.job.onduty then TriggerServerEvent("QBCore:ToggleDuty") end
            elseif Config.framework == 'qbx' then
                if QBX.PlayerData.job.onduty then TriggerServerEvent("QBCore:ToggleDuty") end
            end
        end
    end
        Wait(100)
        updateOfflineShop(id, 'delete')
end

---@param coords vector
---@param radius number
---@param options table
---@param distance number
---@param name string
---@return unknown
createSphereZoneTarget = function(coords, radius, options, distance, name)
    if Config.target == 'ox_target' then
        return exports.ox_target:addSphereZone({ debug = Config.debug, coords = coords, radius = radius, options = options })
    elseif Config.target == 'interact' then
        return exports.interact:AddInteraction({ coords = vec3(coords.x, coords.y, coords.z), distance = 1.0, interactDst = 1.0, id = name, name = name, options = options })
    else
        -- Here we use Box Zone cause qb-target Sphere Zone does not exists and the Circle Zone is the big shit ever made
        return exports[Config.target]:AddBoxZone(name, coords, radius, radius, { debugPoly = Config.debug, name = name, minZ = coords.z-radius, maxZ = coords.z+radius }, { options = options, distance = distance })
    end
end

---@param entity integer
---@param options table
---@param distance number
---@param name string
---@return unknown
createEntityTarget = function(entity, options, distance, name)
    if Config.target == 'ox_target' then
        return exports.ox_target:addLocalEntity(entity, options)
    elseif Config.target == 'interact' then
        return exports.interact:AddLocalEntityInteraction({ entity = entity, name = name, id = name, distance = 1.0, interactDst = 1.0, options = options })
    else
        return exports[Config.target]:AddTargetEntity(entity, { name = name, options = options, distance = distance })
    end
end

managementMenu = function()
    if Config.framework == 'qb' then
        TriggerEvent('qb-bossmenu:client:OpenMenu')
    elseif Config.framework == 'qbx' then
        exports.qbx_management:OpenBossMenu('job')
    elseif Config.framework == 'esx' then
        TriggerEvent('esx_society:openBossMenu', getPlayerJob(), function(data, menu) 
    if menu then 
        menu.close() 
    end 
end, {wash = false})
    end
end

---@param message string
---@param type string
notify = function(message, type)
    lib.notify({ description = message, type = type })
end

---@param id string | integer
---@param label string
---@param slots integer
---@param weight integer
openStash = function(id, label, slots, weight)
    if Config.inventory == 'ox_inventory' then
        exports.ox_inventory:openInventory('stash', id)
    elseif Config.inventory == 'qb-inventory' then
        lib.callback.await('mt-restaurants:server:openStash', false, id, { maxweight = (weight*1000), slots = slots })
    else
        TriggerEvent("inventory:client:SetCurrentStash", id)
        TriggerServerEvent("inventory:server:OpenInventory", "stash", id, { maxweight = (weight*1000), slots = slots })
    end
end

---@param id string | integer
---@param label string
---@param passedItems table
openShop = function(id, label, passedItems)
    if Config.inventory == 'ox_inventory' then
        exports.ox_inventory:openInventory('shop', { type = id })
    elseif Config.inventory == 'qb-inventory' then
        lib.callback.await('mt-restaurants:server:openShop', false, id, label)
    else
        local items = {}
        for k, v in pairs(passedItems) do
            items[#items+1] = { name = v.name, price = tonumber(v.price), amount = tonumber(v.count), info = {}, slot = k }
        end
        local Item = { label = label, slots = #items, items = items }
        TriggerServerEvent("inventory:server:OpenInventory", "shop", id, Item)
    end
end

---@param item string
---@return table
itemData = function(item)
    if Config.inventory == 'ox_inventory' then
        local items = exports.ox_inventory:Items()
        return items[item]
    else
        local items = Config.core.Shared.Items
        return items[item]
    end
end

---@param item string
---@return integer
getItemCount = function(item)
    if Config.inventory == 'ox_inventory' then
        return exports.ox_inventory:GetItemCount(item)
    else
        return lib.callback.await('mt-restaurants:server:GetItemCount', false, item)
    end
end

---@param label string
---@param duration integer
---@param disable table
---@param anim table
---@param prop table
---@return boolean
progressBar = function(label, duration, disable, anim, prop)
	return lib.progressCircle({ label = label, duration = duration, position = Config.progressbarPos, useWhileDead = false, canCancel = true, disable = disable, anim = anim, prop = prop })
end

---@param text string
---@param pos string
showTextUI = function(text, pos)
    lib.showTextUI(text, { position = pos })
end

hideTextUI = function()
    lib.hideTextUI()
end

---@param model any
---@param coords vector
---@return any
spawnVehicle = function(model, coords)
    coords = vec4(coords.x, coords.y, coords.z, coords.w or GetEntityHeading(cache.ped))
    model = type(model) == 'string' and joaat(model) or model
    if not IsModelInCdimage(model) then return end
    loadModel(model)
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, false)
    local netid = NetworkGetNetworkIdFromEntity(veh)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetNetworkIdCanMigrate(netid, true)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetVehRadioStation(veh, 'OFF')
    SetVehicleFuelLevel(veh, 100.0)
    if Config.keys == 'Renewed-Vehiclekeys' then
        exports['Renewed-Vehiclekeys']:addKey(Config.framework == 'qbx' and qbx.getVehiclePlate(veh) or GetVehicleNumberPlateText(veh))
    else
        TriggerEvent("vehiclekeys:client:SetOwner", Config.framework == 'qbx' and qbx.getVehiclePlate(veh) or GetVehicleNumberPlateText(veh))
    end
    SetModelAsNoLongerNeeded(model)
    return veh
end

---@param veh integer
removeVehicleKeys = function(veh)
    if Config.keys == 'Renewed-Vehiclekeys' then
        exports['Renewed-Vehiclekeys']:removeKey(Config.framework == 'qbx' and qbx.getVehiclePlate(veh) or GetVehicleNumberPlateText(veh))
    end
end

---@param type string
---@param percent number
addNeeds = function(type, percent)
    if type == 'food' then
        lib.callback.await('mt-restaurants:server:addNeeds', false, 0, percent)
    else
        lib.callback.await('mt-restaurants:server:addNeeds', false, percent, 0)
    end
end

---@param type string
---@param customBuffs table
giveCustomBuffs = function(type, customBuffs)
    if not customBuffs then return end
    if type == 'drink' then
        if customBuffs.alcohol then
            setAlcoholEffect(customBuffs.alcohol)
        end
    end
    if customBuffs.stress then
        TriggerServerEvent('hud:server:RelieveStress', customBuffs.stress)
    end
    if customBuffs.armour then
        local armour = GetPedArmour(cache.ped)
        SetPedArmour(cache.ped, (armour+customBuffs.armour))
    end
end

local playerAlcohol = 0
---@param value number
setAlcoholEffect = function(value)
    playerAlcohol += value
    if playerAlcohol >= 20 then
        if not HasAnimSetLoaded("MOVE_M@DRUNK@VERYDRUNK") then
            RequestAnimSet("MOVE_M@DRUNK@VERYDRUNK")
            while not HasAnimSetLoaded("MOVE_M@DRUNK@VERYDRUNK") do Citizen.Wait(0) end
        end
        SetPedIsDrunk(cache.ped, true)
        ShakeGameplayCam("DRUNK_SHAKE", 1.0)
        SetPedConfigFlag(cache.ped, 100, true)
        SetPedMovementClipset(cache.ped, "MOVE_M@DRUNK@VERYDRUNK", 1.0)
        Wait(30000)
        SetPedIsDrunk(cache.ped, false)
        ShakeGameplayCam("DRUNK_SHAKE", 0.0)
        SetPedConfigFlag(cache.ped, 100, false)
        ResetPedMovementClipset(cache.ped, 0)
        ClearPedTasks(PlayerPedId())
    end
    CreateThread(function()
        Wait(60000)
        playerAlcohol = 0
    end)
end

---@param coords vector
---@param distance number
---@return table
getPlayersFromCoords = function(coords, distance)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
    local players = lib.getNearbyPlayers(coords, distance or 5, true)
    for i = 1, #players do players[i] = players[i].id end
    return players
end

---@return string
getPlayerJob = function()
    if Config.framework == 'qb' then
        local PlayerData = Config.core.Functions.GetPlayerData()
        return PlayerData.job.name
    elseif Config.framework == 'qbx' then
        return QBX.PlayerData.job.name
    elseif Config.framework == 'esx' then
        return lib.callback.await('mt-restaurants:server:getPlayerJobESX', false)
    end
    return ''
end

---@return boolean
isPlayerJobBoss = function()
    if Config.framework == 'qb' then
        local PlayerData = Config.core.Functions.GetPlayerData()
        return PlayerData.job.isboss
    elseif Config.framework == 'qbx' then
        return QBX.PlayerData.job.isboss
    elseif Config.framework == 'esx' then
        return lib.callback.await('mt-restaurants:server:getPlayerJobIsBossESX', false)
    end
    return false
end

---@param model string
---@param coords vector
---@param heading number
createProp = function(model, coords, heading)
    loadModel(model)
    local prop = CreateObject(GetHashKey(model), coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(prop, heading)
    FreezeEntityPosition(prop, true)
end