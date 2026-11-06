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

-- prp-pressurewash: job depots, peds, blips, vehicle helpers and generator (pressure washer) props.

currentData = {}
local targetRegistry = {}
local blips = {}
pressurewashers = {}
spawnedPressurewashers = {}
local jobPeds = {}
-- Spawns a frozen, invincible job ped and registers its target options.
function SpawnJobPed(pedId, model, coords, data)
    local existing = jobPeds[pedId]
    if existing then
        if DoesEntityExist(existing.ped) then
            return
        end
        -- The old ped was removed by the game; clear its target options before reusing the id.
        DeleteJobPed(pedId)
    end
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Citizen.Wait(0)
    end
    if not HasModelLoaded(model) then
        return
    end
    local ped = CreatePed(4, model, coords.x, coords.y, coords.z, coords.w, false, true)
    if not DoesEntityExist(ped) then
        SetModelAsNoLongerNeeded(model)
        return
    end
    SetEntityAsMissionEntity(ped, true, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetPedCanRagdoll(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedSeeingRange(ped, 0.0)
    if data and data.scenario then
        TaskStartScenarioInPlace(ped, data.scenario, 0, false)
    end
    jobPeds[pedId] = { ped = ped, options = data and data.options }
    if data and data.options then
        bridge.target.addLocalEntity(ped, data.options)
    end
    SetModelAsNoLongerNeeded(model)
end
function DeleteJobPed(pedId)
    local pedData = jobPeds[pedId]
    if not pedData then
        return
    end
    jobPeds[pedId] = nil
    -- Remove the target options before the ped is deleted so ox_target never keeps stale entries.
    if pedData.options then
        local optionNames = {}
        for _, option in pairs(pedData.options) do
            if option.name then
                optionNames[#optionNames + 1] = option.name
            end
        end
        if #optionNames > 0 then
            bridge.target.removeLocalEntity(pedData.ped, optionNames)
        end
    end
    if DoesEntityExist(pedData.ped) then
        SetEntityAsMissionEntity(pedData.ped, true, true)
        DeleteEntity(pedData.ped)
    end
end
-- Creates a proximity point per depot that spawns the depot ped and its target options.
local function setupDepots()
    for depotId, depot in pairs(Config.Job.PW.depots) do
        local point = lib.points.new({ coords = depot.pedCoords.xyz, distance = 25.0, id = depotId })
        point.onEnter = function()
            -- Only show the options that apply to the current job stage. currentData is a shared
            -- table (never nil), so checking `currentData ~= nil` would leave every option visible.
            local options = {}
            if Config.StartByNPC then
                options[#options + 1] = {
                    name = "pw_start_job",
                    icon = "fa-solid fa-helmet-safety",
                    label = locale("START_PRESSURE_WASH_JOB"),
                    onSelect = function()
                        TriggerServerEvent("prp-pressurewash:startJob", depotId)
                    end,
                    canInteract = function()
                        return not (currentData and currentData.stage)
                    end,
                }
            end
            options[#options + 1] = {
                name = "pw_retrieve_vehicle",
                icon = "fa-solid fa-clipboard-check",
                label = locale("RETRIEVE_VEHICLE"),
                data = {},
                onSelect = function()
                    TriggerServerEvent("prp-pressurewash:getVan")
                end,
                canInteract = function()
                    return currentData and currentData.stage == 1
                end,
            }
            options[#options + 1] = {
                name = "pw_return_vehicle",
                icon = "fa-solid fa-clipboard",
                label = locale("RETURN_VEH"),
                onSelect = function()
                    TriggerServerEvent("prp-pressurewash:returnVan")
                end,
                canInteract = function()
                    return currentData and currentData.stage == 3
                end,
            }
            options[#options + 1] = {
                name = "pw_buy_equipment",
                icon = "fa-solid fa-clipboard",
                label = locale("BUY_EQUIPMENT"),
                onSelect = function()
                    OpenJobShop()
                end,
            }
            if Config.StartByNPC then
                options[#options + 1] = {
                    name = "pw_stop_job",
                    icon = "fa-solid fa-helmet-safety",
                    label = locale("END_PRESSURE_WASH_JOB"),
                    onSelect = function()
                        TriggerServerEvent("prp-pressurewash:endJob")
                    end,
                    canInteract = function()
                        return currentData and currentData.stage ~= nil
                    end,
                }
            end
            SpawnJobPed("PressureWash_DepotPed_" .. depotId, depot.pedModel, depot.pedCoords,
                { options = options, icon = "fa-solid fa-user-helmet-safety", scenario = "WORLD_HUMAN_SMOKING" })
        end
        point.onExit = function()
            DeleteJobPed("PressureWash_DepotPed_" .. depotId)
        end
        -- Spawn the ped now so it is present when the resource restarts while a player is
        -- already standing inside the point (the points loop will not fire onEnter again).
        point:onEnter()
    end
end
-- Removes all blips and job targets and clears the job state.
local function cleanupJob()
    for blipId, _ in pairs(blips) do
        DeleteBlip(blipId)
    end
    for key, target in pairs(targetRegistry) do
        if string.find(key, "zone") then
            bridge.target.removeZone(target)
        else
            if string.find(key, "pw_entity_veh_") then
                local entity = tonumber(string.sub(key, 15))
                if entity then
                    bridge.target.removeEntity(entity, { "pw_entity_veh" })
                end
            end
        end
        targetRegistry[key] = nil
    end
    currentData = {}
end
-- Applies the server job data and shows the depot (stage 1/3) or cleaning zone (stage 2) blip.
local function syncJobState(data)
    currentData = data
    if currentData.stage == 1 or currentData.stage == 3 then
        local blip = CreateBlip("PW_START", locale("PRESSURE_WASHER_DEPOT_BLIP_LABEL"),
            Config.Job.PW.depots[currentData.depot].pedCoords.xyz, 616, 69, 1.0, 4)
        SetBlipRouteColour(blip, 38)
        SetBlipRoute(blip, true)
    else
        DeleteBlip("PW_START")
    end
    if currentData.stage == 2 then
        local blip = CreateBlip("PW_ZONE", locale("CLEANING_AREA_BLIP_LABEL"), MinZones[currentData.zone], 570, 69, 1.0,
            4)
        SetBlipRouteColour(blip, 38)
        SetBlipRoute(blip, true)
    else
        DeleteBlip("PW_ZONE")
    end
end
RegisterNetEvent("prp-pressurewash:syncData", function(data)
    if not data then
        cleanupJob()
        return
    end
    syncJobState(data)
end)
lib.callback.register("prp-pressurewash:getFreeSpot", function(depotId)
    for spotIndex, spot in pairs(Config.Job.PW.depots[depotId].vehSpawns) do
        if GetVehicleAtCoords(spot.xyz, 3.0) == nil then
            return spotIndex
        end
    end
end)
-- Returns the first vehicle within `radius` of `coords`, or nil.
function GetVehicleAtCoords(coords, radius)
    local vehicles = GetGamePool("CVehicle")
    for i = 1, #vehicles do
        if radius >= #(GetEntityCoords(vehicles[i]) - vector3(coords.x, coords.y, coords.z)) then
            return vehicles[i]
        end
    end
    return nil
end
-- Sum of travel distances: from the depot for the first and last delivery, from the previous delivery otherwise.
function CalculateTotalDistance(depotId, deliveryIds)
    local depotCoords = Config.Job.GoPostal.depots[depotId].pedCoords.xyz
    local total = 0
    for i = 1, #deliveryIds do
        local deliveryCoords = Config.Job.GoPostal.deliverLocations[deliveryIds[i]].coords
        if i == 1 or i == #deliveryIds then
            total = total + GetRealTravelDist(depotCoords, deliveryCoords)
        else
            total = total + GetRealTravelDist(Config.Job.GoPostal.deliverLocations[deliveryIds[i - 1]].coords, deliveryCoords)
        end
    end
    return total
end
RegisterNetEvent("prp-pressurewash:setVehMod", function(netId, modType, modValue)
    local attempts = 0
    while not NetworkDoesNetworkIdExist(netId) do
        Citizen.Wait(0)
        attempts = attempts + 1
        if attempts > 250 then
            break
        end
    end
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    NetworkRequestControlOfEntity(vehicle)
    Citizen.Wait(50)
    SetVehicleModKit(vehicle, 0)
    if modType == "livery" then
        SetVehicleLivery(vehicle, modValue)
        return
    end
    SetVehicleMod(vehicle, modType, modValue, false)
end)
-- Takes control of the vehicle (up to 15 tries), then toggles the door.
function ToggleDoor(vehicle, doorIndex)
    local attempts = 0
    while not NetworkHasControlOfEntity(vehicle) and attempts < 15 do
        NetworkRequestControlOfEntity(vehicle)
        Citizen.Wait(50)
        attempts = attempts + 1
    end
    if attempts >= 15 then
        return
    end
    if GetVehicleDoorLockStatus(vehicle) ~= 2 then
        if GetVehicleDoorAngleRatio(vehicle, doorIndex) > 0.0 then
            SetVehicleDoorShut(vehicle, doorIndex, false)
        else
            SetVehicleDoorOpen(vehicle, doorIndex, false, false)
        end
    end
end
function CreateBlip(id, label, coords, sprite, colour, scale, display)
    if blips[id] then
        DeleteBlip(id)
    end
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, display)
    SetBlipScale(blip, scale)
    SetBlipColour(blip, colour)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(label)
    EndTextCommandSetBlipName(blip)
    blips[id] = blip
    return blip
end
function DeleteBlip(id)
    if not blips[id] then
        return
    end
    RemoveBlip(blips[id])
    blips[id] = nil
end
Citizen.CreateThread(function()
    bridge.inv.registerDisplayMetaData({ water = locale("WATER_META_DATA_LABEL"), fuel = locale("FUEL_META_DATA_LABEL") })
    setupDepots()
    pressurewashers = lib.callback.await("prp-pressurewash:getPressureWashers", false) or {}
    for id, washer in pairs(pressurewashers) do
        local point = lib.points.new({ coords = washer.pos, distance = 25.0 })
        washer.point = point
        washer.point.onEnter = function()
            RequestModel(-1573693164)
            while not HasModelLoaded(-1573693164) do
                Citizen.Wait(0)
            end
            local object = CreateObject(-1573693164, washer.pos.x, washer.pos.y, washer.pos.z, false, false, false)
            SetEntityHeading(object, washer.pos.w)
            FreezeEntityPosition(object, true)
            PlaceObjectOnGroundProperly(object)
            spawnedPressurewashers[id] = object
            CreatePressureWasherTarget(id, object)
        end
        washer.point.onExit = function()
            if spawnedPressurewashers[id] then
                DeleteEntity(spawnedPressurewashers[id])
                spawnedPressurewashers[id] = nil
            end
        end
    end
end)
-- Placement preview for a new generator; returns the confirmed vector4, or nil when cancelled.
lib.callback.register("prp-pressurewash:placeGenerator", function(data)
    RequestModel(-1573693164)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(-1573693164) do
        if not (timeout > GetGameTimer()) then
            break
        end
        Citizen.Wait(0)
    end
    if not HasModelLoaded(-1573693164) then
        return
    end
    local playerCoords = GetEntityCoords(PlayerPedId())
    local preview = CreateObject(-1573693164, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false)
    SetEntityAlpha(preview, 150, false)
    SetEntityCollision(preview, false, false)
    FreezeEntityPosition(preview, true)
    local placing = true
    local placedCoords = nil
    local placedHeading = nil
    Citizen.CreateThread(function()
        while placing do
            if IsControlJustPressed(0, 73) then
                placing = false
            end
            if IsControlJustPressed(0, 18) then
                placedCoords = GetEntityCoords(preview)
                placedHeading = GetEntityHeading(preview)
                placing = false
            end
            Citizen.Wait(0)
        end
    end)
    while placing do
        local hit, entityHit, hitCoords = lib.raycast.fromCamera(25, 4, 10, preview)
        if hit and hit > 0 and entityHit ~= PlayerPedId() then
            SetEntityCoordsNoOffset(preview, hitCoords.x, hitCoords.y, hitCoords.z, false, false, false)
            PlaceObjectOnGroundProperly(preview)
        end
        Citizen.Wait(0)
    end
    DeleteEntity(preview)
    if not placedCoords or not placedHeading then
        return
    end
    return vector4(placedCoords.x, placedCoords.y, placedCoords.z, placedHeading)
end)
RegisterNetEvent("prp-pressurewash:newPressureWasher", function(id, washer)
    pressurewashers[id] = washer
    local point = lib.points.new({ coords = washer.pos, distance = 25.0 })
    point.onEnter = function()
        RequestModel(-1573693164)
        while not HasModelLoaded(-1573693164) do
            Citizen.Wait(0)
        end
        local object = CreateObject(-1573693164, washer.pos.x, washer.pos.y, washer.pos.z, false, false, false)
        SetEntityHeading(object, washer.pos.w)
        FreezeEntityPosition(object, true)
        PlaceObjectOnGroundProperly(object)
        spawnedPressurewashers[id] = object
        CreatePressureWasherTarget(id, object)
    end
    point.onExit = function()
        if spawnedPressurewashers[id] then
            bridge.target.removeLocalEntity(spawnedPressurewashers[id], {
                "connect_pressure_washer",
                "disconnect_pressure_washer",
                "refuel_generator",
                "refill_water",
                "check_generator_status",
                "take_generator",
            })
            DeleteEntity(spawnedPressurewashers[id])
            spawnedPressurewashers[id] = nil
        end
    end
    pressurewashers[id].point = point
end)
RegisterNetEvent("prp-pressurewash:removePressureWasher", function(id)
    CleanupGeneratorAttachments(id)
    if spawnedPressurewashers[id] then
        bridge.target.removeLocalEntity(spawnedPressurewashers[id], {
            "connect_pressure_washer",
            "disconnect_pressure_washer",
            "refuel_generator",
            "refill_water",
            "check_generator_status",
            "take_generator",
        })
        DeleteEntity(spawnedPressurewashers[id])
        spawnedPressurewashers[id] = nil
    end
    if pressurewashers[id] then
        if pressurewashers[id].point then
            pressurewashers[id].point:remove()
        end
        pressurewashers[id] = nil
    end
end)
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    for id, object in pairs(spawnedPressurewashers) do
        pressurewashers[id].point:remove()
        bridge.target.removeLocalEntity(object, {
            "connect_pressure_washer",
            "disconnect_pressure_washer",
            "refuel_generator",
            "refill_water",
            "check_generator_status",
            "take_generator",
        })
        DeleteEntity(object)
    end
end)
RegisterNetEvent("prp-pressurewash:updatePressureWasher", function(id, washer)
    if pressurewashers[id] then
        pressurewashers[id] = washer
    end
end)
RegisterNetEvent("prp-pressurewash:onGeneratorUpdate", function(id, fuel, water)
    if pressurewashers[id] then
        pressurewashers[id].fuel = fuel
        pressurewashers[id].water = water
    end
end)
-- Target options (connect / disconnect / refuel / refill / status / take) of a spawned generator.
function CreatePressureWasherTarget(id, object)
    local washer = pressurewashers[id]
    bridge.target.addLocalEntity(object, {
        {
            name = "connect_pressure_washer",
            label = locale("CONNECT_PRESSURE_WASHER"),
            icon = "fas fa-hand",
            onSelect = function()
                if LocalPlayer.state.attachedPressureWasher or IsAnyoneAttachedToGenerator(id) then
                    return
                end
                LocalPlayer.state:set("attachedPressureWasher", id, true)
            end,
            canInteract = function()
                return GetSelectedPedWeapon(playerPed) == -1650982517
                        and not LocalPlayer.state.attachedPressureWasher
                        and not IsAnyoneAttachedToGenerator(id)
            end,
        },
        {
            name = "disconnect_pressure_washer",
            label = locale("DISCONNECT_PRESSURE_WASHER"),
            icon = "fas fa-hand",
            onSelect = function()
                if not LocalPlayer.state.attachedPressureWasher then
                    return
                end
                LocalPlayer.state:set("attachedPressureWasher", nil, true)
            end,
            canInteract = function()
                return GetSelectedPedWeapon(playerPed) == -1650982517 and LocalPlayer.state.attachedPressureWasher
            end,
        },
        {
            name = "refuel_generator",
            icon = "fas fa-gas-pump",
            onSelect = function()
                if washer.fuel >= 100 then
                    bridge.fw.notify("error", locale("FUEL_TANK_FULL"))
                    return
                end
                local slot = bridge.inv.findItemSlot("petrolcan", 1)
                if not slot then
                    bridge.fw.notify("error", locale("NEED_TO_HAVE_PETROL_CAN"))
                    return
                end
                if IsAnyoneAttachedToGenerator(id) then
                    bridge.fw.notify("error", locale("SOMEONE_USING_GENERATOR"))
                    return
                end
                RefuellingProgress(id, washer, slot)
            end,
            label = locale("REFUEL_GENERATOR"),
        },
        {
            name = "refill_water",
            icon = "fas fa-tint",
            onSelect = function()
                if washer.water >= 100 then
                    bridge.fw.notify("error", locale("WATER_TANK_FULL"))
                    return
                end
                local slot = bridge.inv.findItemSlot("watercanister", 1)
                if not slot then
                    bridge.fw.notify("error", locale("NEED_A_WATER_CAN"))
                    return
                end
                if IsAnyoneAttachedToGenerator(id) then
                    bridge.fw.notify("error", locale("SOMEONE_USING_GENERATOR"))
                    return
                end
                RefillWaterProgress(id, washer, slot)
            end,
            label = locale("REFILL_WATER"),
        },
        {
            name = "check_generator_status",
            label = locale("CHECK_STATUS2"),
            icon = "fas fa-info-circle",
            onSelect = function()
                bridge.fw.notify("inform",
                    locale("GENERATOR_STATUS_INFO", math.floor(washer.fuel), math.floor(washer.water)))
            end,
        },
        {
            name = "take_generator",
            label = locale("TAKE_GENERATOR"),
            icon = "fas fa-info-circle",
            onSelect = function()
                if LocalPlayer.state.attachedPressureWasher == id then
                    LocalPlayer.state:set("attachedPressureWasher", nil, true)
                else
                    if IsAnyoneAttachedToGenerator(id) then
                        bridge.fw.notify("error", locale("SOMEONE_USING_GENERATOR"))
                        return
                    end
                end
                TriggerServerEvent("prp-pressurewash:takeGenerator", id)
            end,
        },
    })
end
