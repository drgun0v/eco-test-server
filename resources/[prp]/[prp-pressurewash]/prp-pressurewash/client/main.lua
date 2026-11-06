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

-- prp-pressurewash: pressure washer client (player particles, hose ropes, washing loop, decal zones).

playerPed = PlayerPedId()
lib.onCache("ped", function(ped)
    playerPed = ped
end)
LoadedZones = {}
LoadedZonePoints = {}
local pointZones = {}
local travelDistRetries = 0
local ropes = {}
local duiHandle = nil
local duiReady = false
HasPressureWash = false
-- Travel distance via path nodes; retries while the engine returns the 10000.0 placeholder (gives up after 50 calls).
function GetRealTravelDist(from, to)
    travelDistRetries = travelDistRetries + 1
    if travelDistRetries > 50 then
        travelDistRetries = 0
        return 0
    end
    LoadAllPathNodes(true)
    GenerateDirectionsToCoord(from.x, from.y, from.z, 0)
    Citizen.Wait(0)
    GenerateDirectionsToCoord(to.x, to.y, to.z, 0)
    Citizen.Wait(0)
    local distance = CalculateTravelDistanceBetweenPoints(from.x, from.y, from.z, to.x, to.y, to.z)
    if distance == 10000.0 then
        Citizen.Wait(100)
        return GetRealTravelDist(from, to)
    end
    travelDistRetries = 0
    return distance
end
function GetVehFromNetId(netId)
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
    return vehicle
end
function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end
end
lib.onCache("weapon", function(weapon)
    if weapon == -1650982517 then
        DebugPrint("Ensure pressure washer thread")
        EnsurePressureWasherThread()
    else
        HasPressureWash = false
    end
end)
local playerParticles = {}
local localServerId = GetPlayerServerId(PlayerId())
-- Other players spraying: start/stop the water particle on their pressure washer.
AddStateBagChangeHandler("usingPressureWasher", nil, function(bagName, key, value, reserved, replicated)
    local player = GetPlayerFromStateBagName(bagName)
    if player == 0 or player == PlayerId() then
        return
    end
    local serverId = tostring(GetPlayerServerId(player))
    if not value then
        DebugPrint("Stopping particle for player", serverId)
        if playerParticles[serverId] then
            StopParticleFxLooped(playerParticles[serverId], 0)
            playerParticles[serverId] = nil
        end
        return
    end
    DebugPrint("Starting particle for player", serverId)
    if playerParticles[serverId] then
        return
    end
    local targetPed = GetPlayerPed(player)
    DebugPrint("Found target ped", targetPed)
    if not DoesEntityExist(targetPed) then
        return
    end
    local targetCoords = GetEntityCoords(targetPed)
    if #(targetCoords - GetEntityCoords(playerPed)) > 50.0 then
        return
    end
    local weaponObject = GetClosestObjectOfType(targetCoords.x, targetCoords.y, targetCoords.z, 10.0, 650676523, false,
        false, false)
    DebugPrint("Found weapon object", weaponObject)
    while not DoesEntityExist(weaponObject) do
        Citizen.Wait(0)
        local searchCoords = GetEntityCoords(targetPed)
        weaponObject = GetClosestObjectOfType(searchCoords.x, searchCoords.y, searchCoords.z, 10.0, 650676523, false,
            false, false)
    end
    local muzzleBone = GetEntityBoneIndexByName(weaponObject, "Gun_Muzzle")
    DebugPrint("Found muzzle bone", muzzleBone)
    if not HasNamedPtfxAssetLoaded("core") then
        RequestNamedPtfxAsset("core")
        while not HasNamedPtfxAssetLoaded("core") do
            Citizen.Wait(0)
        end
    end
    DebugPrint("Starting water particle - asset loaded")
    UseParticleFxAsset("core")
    playerParticles[serverId] = StartParticleFxLoopedOnEntityBone("water_cannon_jet", weaponObject, 0.0, 0.0, 0.0, 0.0,
        0.0, -90.0, muzzleBone, 1.0, false, false, false)
end)
RegisterNetEvent("onPlayerDropped", function(playerId)
    if playerParticles[tostring(playerId)] then
        StopParticleFxLooped(playerParticles[tostring(playerId)], 0)
        playerParticles[tostring(playerId)] = nil
    end
    if ropes[tostring(playerId)] then
        DeleteRope(ropes[tostring(playerId)].rope)
        ropes[tostring(playerId)] = nil
    end
end)
local washerThreadRunning = nil
local washerObject = nil
local attachedGeneratorId = nil
-- A player (un)attached a generator hose: delete their rope or create a new one.
AddStateBagChangeHandler("attachedPressureWasher", nil, function(bagName, key, value, reserved, replicated)
    local player = GetPlayerFromStateBagName(bagName)
    local serverId = tostring(GetPlayerServerId(player))
    if player == 0 then
        return
    end
    if not value then
        if ropes[serverId] then
            DeleteRope(ropes[serverId].rope)
            ropes[serverId] = nil
        end
        if player == PlayerId() then
            attachedGeneratorId = nil
        end
        if not next(ropes) then
            if duiHandle and IsDuiAvailable(duiHandle) then
                DestroyDui(duiHandle)
                duiHandle = nil
            end
            RemoveReplaceTexture("platform:/textures/rope", "steel_cable")
        end
        return
    end
    if ropes[serverId] then
        return
    end
    if player == PlayerId() then
        attachedGeneratorId = value
    end
    if not pressurewashers[value] then
        return
    end
    local generatorObject = spawnedPressurewashers[value]
    if not generatorObject then
        return
    end
    local attempts = 0
    while not DoesEntityExist(generatorObject) and attempts < 20 do
        attempts = attempts + 1
        Citizen.Wait(0)
    end
    if attempts >= 20 then
        return
    end
    CreateRopeForPlayer(generatorObject, player, serverId, value)
end)
exports("GetAttachedGenerator", function()
    if attachedGeneratorId then
        return pressurewashers[attachedGeneratorId]
    end
    return nil
end)
-- Deletes every rope attached to the generator and resets the local attachment state.
function CleanupGeneratorAttachments(generatorId)
    for serverId, ropeData in pairs(ropes) do
        if ropeData.uuid == generatorId then
            if ropeData.rope then
                DeleteRope(ropeData.rope)
            end
            ropes[serverId] = nil
        end
    end
    if LocalPlayer.state.attachedPressureWasher == generatorId then
        LocalPlayer.state:set("attachedPressureWasher", nil, true)
    end
    if attachedGeneratorId == generatorId then
        attachedGeneratorId = nil
    end
    if not next(ropes) then
        if duiHandle and IsDuiAvailable(duiHandle) then
            DestroyDui(duiHandle)
            duiHandle = nil
        end
        RemoveReplaceTexture("platform:/textures/rope", "steel_cable")
    end
end
function CreateRope(generatorObject, ped)
    RopeLoadTextures()
    local ropeType = 7
    LoadRopeData(ropeType, "ropeFamily3")
    SetRopesCreateNetworkWorldState(false)
    Citizen.Wait(0)
    local handBone = GetPedBoneIndex(ped, 57005)
    local handCoords = GetWorldPositionOfEntityBone(ped, handBone)
    local tankCoords = GetWorldPositionOfEntityBone(generatorObject, GetEntityBoneIndexByName(generatorObject, "Tank"))
    local rope = AddRope(tankCoords.x, tankCoords.y, tankCoords.z, 0.0, 0.0, 0.0, 0.1, ropeType, 1000.0, 0.0, 1.0,
        false, false, false, 1.0, false)
    ActivatePhysics(rope)
    AttachEntitiesToRope(rope, generatorObject, ped, tankCoords.x, tankCoords.y, tankCoords.z, handCoords.x,
        handCoords.y, handCoords.z + 0.1, 1000.0, false, false, nil, handBone)
    if not duiHandle then
        Citizen.CreateThread(function()
            local txd = CreateRuntimeTxd("pressurewash_txd")
            duiHandle = CreateDui("nui://prp-pressurewash/dui/index.html", 128, 128)
            duiReady = false
            while not IsDuiAvailable(duiHandle) do
                Citizen.Wait(0)
            end
            Citizen.Wait(0)
            CreateRuntimeTextureFromDuiHandle(txd, "pressurewash_txn", GetDuiHandle(duiHandle))
            AddReplaceTexture("platform:/textures/rope", "steel_cable", "pressurewash_txd", "pressurewash_txn")
        end)
    end
    return rope
end
function BreakRope(rope, ped)
    DetachRopeFromEntity(rope, ped)
    Citizen.Wait(300)
    DeleteRope(rope)
end
function CreateRopeForPlayer(generatorObject, player, serverId, generatorId)
    local targetPed = GetPlayerPed(player)
    local rope = CreateRope(generatorObject, targetPed)
    local anchorCoords = GetRopeVertexCoord(rope, 2)
    local _, anchorGroundZ = GetGroundZFor_3dCoord(anchorCoords.x, anchorCoords.y, anchorCoords.z, false)
    PinRopeVertex(rope, 2, anchorCoords.x, anchorCoords.y, anchorGroundZ + 0.1)
    ropes[serverId] = {
        rope = rope,
        pinnedIndexes = { [2] = true },
        vertexCount = math.floor(GetRopeVertexCount(rope) - 2),
        pinnedCount = 1,
        obj = generatorObject,
        targetPed = targetPed,
        uuid = generatorId,
    }
    EnsureRopeThread()
    return rope
end
local pinSpacing = 0.25
local maxRopeLength = 20.0
local ropeThreadRunning = nil
-- Rope physics thread: pins/unpins vertices along the ground and breaks ropes that stretch too far.
function EnsureRopeThread()
    if ropeThreadRunning then
        return
    end
    ropeThreadRunning = true
    CreateThread(function()
        -- True when the vertex is within 2 indices of a pinned vertex.
        local function isNearPinnedVertex(vertexIndex, pinnedIndexes)
            for pinnedIndex in pairs(pinnedIndexes) do
                if math.abs(pinnedIndex - vertexIndex) < 2 then
                    return true
                end
            end
            return false
        end
        while next(ropes) do
            for serverId, ropeData in pairs(ropes) do
                local targetCoords = GetEntityCoords(ropeData.targetPed)
                local ropeHandle = ropeData.rope
                for vertexIndex = 3, ropeData.vertexCount do
                    local vertexCoords = GetRopeVertexCoord(ropeHandle, vertexIndex)
                    local vertexDist = #(vertexCoords - targetCoords)
                    local previousVertex = GetRopeVertexCoord(ropeHandle, vertexIndex - 1)
                    local direction = (vertexCoords - previousVertex) / #vertexCoords * #previousVertex
                    if vertexDist > 1.5 then
                        if not ropeData.pinnedIndexes[vertexIndex]
                                and not isNearPinnedVertex(vertexIndex, ropeData.pinnedIndexes)
                                and (RopeGetDistanceBetweenEnds(ropeHandle) - 5.0) / pinSpacing > ropeData.pinnedCount
                                and math.deg(math.acos(direction.y)) > 10.0 then
                            ropeData.pinnedCount = ropeData.pinnedCount + 1
                            local _, groundZ = GetGroundZFor_3dCoord(vertexCoords.x, vertexCoords.y,
                                vertexCoords.z + 0.3, false)
                            PinRopeVertex(ropeHandle, vertexIndex, vertexCoords.x, vertexCoords.y,
                                groundZ > vertexCoords.z + 0.3 and vertexCoords.z or groundZ + 0.1)
                            ropeData.pinnedIndexes[vertexIndex] = true
                        end
                    else
                        if vertexDist < 1.5 and ropeData.pinnedIndexes[vertexIndex] then
                            if vertexIndex ~= ropeData.vertexCount then
                                for i = vertexIndex, ropeData.vertexCount do
                                    if ropeData.pinnedIndexes[i] then
                                        UnpinRopeVertex(ropeHandle, i)
                                        ropeData.pinnedIndexes[i] = nil
                                        ropeData.pinnedCount = ropeData.pinnedCount - 1
                                    end
                                end
                            else
                                UnpinRopeVertex(ropeHandle, vertexIndex)
                                ropeData.pinnedIndexes[vertexIndex] = nil
                                ropeData.pinnedCount = ropeData.pinnedCount - 1
                            end
                        end
                    end
                end
                if ropeData.targetPed == playerPed and duiHandle then
                    SendDuiMessage(duiHandle, json.encode({
                        event = "setPercentage",
                        percentage = math.floor(RopeGetDistanceBetweenEnds(ropeHandle) / maxRopeLength * 100),
                    }))
                end
                if maxRopeLength < RopeGetDistanceBetweenEnds(ropeHandle) then
                    BreakRope(ropeData.rope, ropeData.targetPed)
                    if ropeData.uuid == attachedGeneratorId then
                        LocalPlayer.state:set("attachedPressureWasher", nil, true)
                    end
                    ropes[serverId] = nil
                end
                if ropeData.targetPed == playerPed and IsPedRagdoll(playerPed) then
                    BreakRope(ropeData.rope, playerPed)
                    LocalPlayer.state:set("attachedPressureWasher", nil, true)
                    ropes[serverId] = nil
                end
                Citizen.Wait(50)
            end
        end
        ropeThreadRunning = false
    end)
end
local washedVehicles = {}
-- Main loop while a pressure washer is equipped: spray particle, washing of points/vehicles and generator sync.
function EnsurePressureWasherThread()
    if washerThreadRunning then
        return
    end
    HasPressureWash = true
    washerThreadRunning = true
    CreateThread(function()
        local initialCoords = GetEntityCoords(playerPed)
        washerObject = GetClosestObjectOfType(initialCoords.x, initialCoords.y, initialCoords.z, 10.0, 650676523, false,
            false, false)
        while not DoesEntityExist(washerObject) do
            Citizen.Wait(0)
            local searchCoords = GetEntityCoords(playerPed)
            washerObject = GetClosestObjectOfType(searchCoords.x, searchCoords.y, searchCoords.z, 10.0, 650676523,
                false, false, false)
        end
        local muzzleBone = GetEntityBoneIndexByName(washerObject, "Gun_Muzzle")
        local particle = nil
        local playerId = PlayerId()
        local lastStopTime = 0
        local lastWashTick = GetGameTimer()
        local lastGeneratorSync = GetGameTimer()
        local washedPoints = {}
        local generatorChanged = false
        local lastVehicleSync = GetGameTimer()
        local lastDebugPrint = GetGameTimer()
        while HasPressureWash do
            local pedCoords = GetEntityCoords(playerPed)
            if not washerObject or not DoesEntityExist(washerObject) then
                washerObject = GetClosestObjectOfType(pedCoords.x, pedCoords.y, pedCoords.z, 10.0, 650676523, false,
                    false, false)
                muzzleBone = GetEntityBoneIndexByName(washerObject, "Gun_Muzzle")
            end
            if Config.EnableDebug and GetGameTimer() - lastDebugPrint > 250 then
                DebugPrint("Pressure washer thread active. Attached generator:", attachedGeneratorId)
                DebugPrint(IsControlPressed(0, 24), IsDisabledControlPressed(0, 24),
                    GetGameTimer() - lastStopTime > 100, IsPlayerFreeAiming(playerId), attachedGeneratorId,
                    pressurewashers[attachedGeneratorId] and pressurewashers[attachedGeneratorId].water or "N/A",
                    pressurewashers[attachedGeneratorId] and pressurewashers[attachedGeneratorId].fuel or "N/A")
                lastDebugPrint = GetGameTimer()
            end
            local generator = attachedGeneratorId and pressurewashers[attachedGeneratorId]
            if IsDisabledControlJustPressed(0, 24)
                    and GetGameTimer() - lastStopTime > 100
                    and not particle
                    and IsPlayerFreeAiming(playerId)
                    and generator
                    and generator.water > 0
                    and generator.fuel > 0 then
                DebugPrint("Starting water particle")
                if not HasNamedPtfxAssetLoaded("core") then
                    RequestNamedPtfxAsset("core")
                    while not HasNamedPtfxAssetLoaded("core") do
                        Citizen.Wait(0)
                    end
                end
                DebugPrint("Starting water particle - asset loaded")
                lastWashTick = GetGameTimer()
                UseParticleFxAsset("core")
                particle = StartParticleFxLoopedOnEntityBone("water_cannon_jet", washerObject, 0.0, 0.0, 0.0, 0.0, 0.0,
                    -90.0, muzzleBone, 1.0, false, false, false)
                LocalPlayer.state:set("usingPressureWasher", true, true)
            end
            if particle and IsPlayerFreeAiming(playerId) then
                local aimCoords, aimEntity = RaycastFromCamera()
                if currentData and currentData.zone and LoadedZonePoints[currentData.zone] then
                    for pointIndex, point in pairs(LoadedZonePoints[currentData.zone]) do
                        if point[5][4] > -1
                                and (not washedPoints[pointIndex] or washedPoints[pointIndex] < 1.5)
                                and #(aimCoords - point[1]) < 1.0
                                and #(pedCoords - point[1]) < 8.0 then
                            local cleanAmount = GetFrameTime() / Config.Job.PW.cleanTimeModifier
                            WashDecalsInRange(point[1].x, point[1].y, point[1].z, 0.1, cleanAmount)
                            washedPoints[pointIndex] = (washedPoints[pointIndex] or 0.0) + cleanAmount
                            local pointData = point[5]
                            pointData[4] = pointData[4] - cleanAmount
                        end
                        if not LoadedZonePoints[currentData.zone] then
                            break
                        end
                    end
                end
                if aimEntity and IsEntityAVehicle(aimEntity) and GetVehicleDirtLevel(aimEntity) > 0 then
                    WashDecalsFromVehicle(aimEntity, GetFrameTime() / Config.Job.PW.vehicleCleanTimeModifier)
                    local dirtLevel = GetVehicleDirtLevel(aimEntity) - GetFrameTime() / Config.Job.PW.vehicleCleanTimeModifier * 15
                    if dirtLevel < 0 then
                        dirtLevel = 0.0
                    end
                    SetVehicleDirtLevel(aimEntity, dirtLevel)
                    if not NetworkHasControlOfEntity(aimEntity) then
                        washedVehicles[aimEntity] = (washedVehicles[aimEntity] or 0) + GetFrameTime() / Config.Job.PW.vehicleCleanTimeModifier
                    end
                end
            end
            -- Stop spraying when the trigger is released or any spraying condition no longer holds.
            if (IsDisabledControlJustReleased(0, 24)
                    or not (IsDisabledControlPressed(0, 24) and IsPlayerFreeAiming(playerId) and generator
                        and generator.water > 0 and generator.fuel > 0))
                    and particle then
                DebugPrint("Stopping water particle")
                StopParticleFxLooped(particle, 0)
                lastWashTick = GetGameTimer()
                particle = nil
                lastStopTime = GetGameTimer()
                LocalPlayer.state:set("usingPressureWasher", nil, true)
                if next(washedPoints) then
                    for washedIndex, _ in pairs(washedPoints) do
                        if LoadedZonePoints[currentData.zone]
                                and LoadedZonePoints[currentData.zone][washedIndex][5][4] < 0 then
                            for zoneKey, zoneData in pairs(pointZones) do
                                if zoneData.pointId == washedIndex and zoneData.zoneId == currentData.zone then
                                    bridge.target.removeZone(zoneKey, true)
                                    pointZones[zoneKey] = nil
                                end
                            end
                        end
                    end
                    TriggerServerEvent("prp-pressurewash:washedPoints", washedPoints)
                    washedPoints = {}
                end
            end
            if generator and generator.fuel > 0 then
                generator.fuel = generator.fuel - GetFrameTime() / Config.Job.PW.fuelTankTime * 100
                generatorChanged = true
            end
            if particle and generator and generator.water > 0 then
                generator.water = generator.water - GetFrameTime() / Config.Job.PW.waterTankTime * 100
                generatorChanged = true
            end
            if generator and generatorChanged and GetGameTimer() - lastGeneratorSync > 1000 then
                lastGeneratorSync = GetGameTimer()
                generator.fuel = math.max(0, round(generator.fuel, 2))
                generator.water = math.max(0, round(generator.water, 2))
                TriggerServerEvent("prp-pressurewash:updateGenerator", attachedGeneratorId, generator.fuel,
                    generator.water)
                generatorChanged = false
            end
            if particle and GetGameTimer() - lastWashTick > 100 then
                lastWashTick = GetGameTimer()
                for washedIndex, _ in pairs(washedPoints) do
                    if LoadedZonePoints[currentData.zone]
                            and LoadedZonePoints[currentData.zone][washedIndex][5][4] < 0 then
                        for zoneKey, zoneData in pairs(pointZones) do
                            if zoneData.pointId == washedIndex and zoneData.zoneId == currentData.zone then
                                bridge.target.removeZone(zoneKey, true)
                                pointZones[zoneKey] = nil
                            end
                        end
                    end
                end
                if next(washedPoints) then
                    TriggerServerEvent("prp-pressurewash:washedPoints", washedPoints)
                    washedPoints = {}
                end
            end
            if next(washedVehicles) and GetGameTimer() - lastVehicleSync > 300 then
                lastVehicleSync = GetGameTimer()
                local vehiclesByNetId = {}
                for vehicle, washAmount in pairs(washedVehicles) do
                    vehiclesByNetId[NetworkGetNetworkIdFromEntity(vehicle)] = washAmount
                end
                TriggerServerEvent("prp-pressurewash:washedVehicles", vehiclesByNetId)
                washedVehicles = {}
            end
            Citizen.Wait(0)
        end
        if LocalPlayer.state.attachedPressureWasher then
            LocalPlayer.state:set("attachedPressureWasher", nil, true)
        end
        DebugPrint("Exiting pressure washer thread")
        washerThreadRunning = false
    end)
end
function round(value, decimals)
    local power = 10 ^ (decimals or 0)
    return math.floor(value * power + 0.5) / power
end
local cameraCache = {}
local glm = require("glm")
local rad = glm.rad
local quatEulerAngleZYX = glm.quatEulerAngleZYX
local rayPicking = glm.rayPicking
local up = glm.up()
local forward = glm.forward()
-- Gameplay camera position and a ray direction through the screen centre.
function ScreenPositionToCameraRay()
    if not next(cameraCache) then
        cameraCache.ratio = GetAspectRatio(true)
        cameraCache.fov = GetGameplayCamFov()
    end
    local camCoords = GetGameplayCamCoord()
    local camRot = rad(GetGameplayCamRot(2))
    local camQuat = quatEulerAngleZYX(camRot.z, camRot.y, camRot.x)
    return camCoords, rayPicking(camQuat * forward, camQuat * up, rad(cameraCache.fov), cameraCache.ratio, 0.1, 10000.0, 0, 0)
end
-- Returns the hit coords and the entity under the crosshair.
function RaycastFromCamera()
    local rayOrigin, rayDirection = ScreenPositionToCameraRay()
    local rayEnd = rayOrigin + 10000 * rayDirection
    local handle = StartShapeTestLosProbe(rayOrigin.x, rayOrigin.y, rayOrigin.z, rayEnd.x, rayEnd.y, rayEnd.z,
        4294967295, playerPed, 0)
    while true do
        local status, _, endCoords, _, entityHit = GetShapeTestResult(handle)
        if status ~= 1 then
            return endCoords.xyz, entityHit
        end
        Citizen.Wait(0)
    end
end
-- Draws the decals of every dirty point of a zone and registers the helper targets.
function PrepareZone(zone, zoneId)
    local points = zone.points
    RemoveDecalsInRange(zone.pos.x, zone.pos.y, zone.pos.z, 50.0)
    for i = 1, #points do
        if points[i][5][4] > 0 then
            AddDecal(points[i][4], points[i][1].x, points[i][1].y, points[i][1].z, points[i][2].x, points[i][2].y,
                points[i][2].z, points[i][3].x, points[i][3].y, points[i][3].z, 3.0, 3.0, points[i][5][1],
                points[i][5][2], points[i][5][3], points[i][5][4], -1.0, false, false, true)
            if currentData and currentData.zone == zoneId then
                pointZones[bridge.target.addBoxZone({
                    name = zoneId,
                    coords = points[i][1],
                    size = vec3(3, 3, 3),
                    rotation = 0,
                    drawSprite = true,
                    options = {
                        {
                            name = "box",
                            event = "prp-pressurewash:findHelper",
                            icon = "fa-solid fa-cube",
                            label = locale("FIND_POINT_HELPER"),
                            canInteract = function()
                                return Config.ExpTargetHelper and true or false
                            end,
                        },
                    },
                })] = { zoneId = zoneId, pointId = i }
            end
        end
    end
    LoadedZones[zoneId] = zone
    LoadedZonePoints[zoneId] = points
end
MinZones = {}
Citizen.CreateThread(function()
    -- Subscribe to the closest zone within maxDistance and unsubscribe from the previous one.
    Citizen.Wait(3000)
    local zones = lib.callback.await("prp-pressurewash:getZones")
    MinZones = zones
    local currentZone = nil
    local maxDistance = 150.0
    while true do
        local checkCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.0, 0.0)
        local closest = nil
        for zoneId, zoneCoords in pairs(zones) do
            local distance = #(checkCoords - zoneCoords)
            if maxDistance > distance and (not closest or distance < closest.dist) then
                closest = { pos = zoneCoords, dist = distance, id = zoneId }
            end
        end
        if closest then
            if maxDistance > closest.dist and currentZone ~= closest.id then
                if currentZone then
                    TriggerServerEvent("prp-pressurewash:unsubscribeFromZone", currentZone)
                    if LoadedZones[currentZone] then
                        RemoveZone(currentZone)
                    end
                end
                TriggerServerEvent("prp-pressurewash:subscribeToZone", closest.id)
                currentZone = closest.id
            end
        else
            if currentZone then
                TriggerServerEvent("prp-pressurewash:unsubscribeFromZone", currentZone)
                if LoadedZones[currentZone] then
                    RemoveZone(currentZone)
                end
                currentZone = nil
            end
        end
        Citizen.Wait(1000)
    end
end)
function RemoveZone(zoneId)
    RemoveDecalsInRange(LoadedZones[zoneId].pos.x, LoadedZones[zoneId].pos.y, LoadedZones[zoneId].pos.z, 50.0)
    LoadedZones[zoneId] = nil
    LoadedZonePoints[zoneId] = nil
    for key, zoneData in pairs(pointZones) do
        if zoneData.zoneId == zoneId then
            bridge.target.removeZone(key, true)
            pointZones[key] = nil
        end
    end
end
-- Zone updates pushed by the server (points cleaned by other players, zone removed).
RegisterNetEvent("prp-pressurewash:zoneChanged", function(zoneId, points, active, updatedBy)
    if not active then
        if LoadedZones[zoneId] then
            RemoveZone(zoneId)
        end
        return
    end
    if updatedBy == localServerId then
        return
    end
    if not LoadedZones[zoneId] then
        PrepareZone({ pos = MinZones[zoneId], points = points, active = active }, zoneId)
        return
    end
    for pointIndex, newPoint in pairs(points) do
        if LoadedZonePoints[zoneId][pointIndex] and LoadedZonePoints[zoneId][pointIndex][5][4] ~= newPoint[5][4] then
            if newPoint[5][4] <= 0 then
                RemoveDecalsInRange(LoadedZonePoints[zoneId][pointIndex][1].x,
                    LoadedZonePoints[zoneId][pointIndex][1].y, LoadedZonePoints[zoneId][pointIndex][1].z, 0.1)
                for key, zoneData in pairs(pointZones) do
                    if zoneData.pointId == pointIndex and zoneData.zoneId == zoneId then
                        bridge.target.removeZone(key, true)
                        pointZones[key] = nil
                    end
                end
            else
                WashDecalsInRange(newPoint[1].x, newPoint[1].y, newPoint[1].z, 0.1,
                    LoadedZonePoints[zoneId][pointIndex][5][4] - newPoint[5][4])
            end
            LoadedZonePoints[zoneId][pointIndex][5][4] = newPoint[5][4]
        end
    end
end)
function IsAnyoneAttachedToGenerator(generatorId)
    for _, ropeData in pairs(ropes) do
        if ropeData.uuid == generatorId then
            return true
        end
    end
    return false
end
RegisterNUICallback("prp-pressurewash:duiLoaded", function(data, cb)
    duiReady = true
    cb({})
end)
RegisterNetEvent("prp-pressurewash:washVehicle", function(netId, amount)
    local vehicle = GetVehFromNetId(netId)
    if not DoesEntityExist(vehicle) then
        return
    end
    if amount then
        WashDecalsFromVehicle(vehicle, amount)
        local dirtLevel = GetVehicleDirtLevel(vehicle) - amount * 15
        if dirtLevel < 0 then
            dirtLevel = 0.0
        end
        SetVehicleDirtLevel(vehicle, dirtLevel)
    end
end)
-- NOTE: the decompile only passed the first vararg to print(); restored as print(...) so every argument is shown.
function DebugPrint(...)
    if Config.EnableDebug then
        print(...)
    end
end
