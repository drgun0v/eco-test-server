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

-- Keep the backup's native decal appearance, but retry after map geometry streams in.
DirtRenderer = { zones = {} }

local rendererRunning = false
local rendererStopped = false
local renderDistance = 60.0
local nextBoosterCheck = 0
local nextBoosterWarning = 0

local function ensureDecalRendering(now)
    if GetResourceState("17mov_FpsBooster") ~= "started" then
        nextBoosterCheck = 0
        return
    end
    if now < nextBoosterCheck then return end
    nextBoosterCheck = now + 5000
    -- Its lowTexture option calls SetDisableDecalRenderingThisFrame every frame.
    -- Use the installed booster's compatibility export; leave its other options alone.
    local ok, changed = pcall(function()
        return exports["17mov_FpsBooster"]:prepareHighDetailReload()
    end)
    if ok and changed then
        print("[prp-pressurewash] Disabled FPS booster's Low Textures setting so job dirt can render.")
    elseif not ok and now >= nextBoosterWarning then
        nextBoosterWarning = now + 30000
        print("[prp-pressurewash] FPS booster compatibility unavailable; turn off Low Textures in /fpsMenu if dirt is invisible.")
    end
end

local function removeHandle(patch)
    if patch.handle then
        RemoveDecal(patch.handle)
        patch.handle = nil
    end
end

local function applyCleaning(patch)
    if patch.remaining <= 0 then
        removeHandle(patch)
    elseif patch.handle and patch.appliedRemaining > patch.remaining then
        local pos = patch.point[1]
        WashDecalsInRange(pos.x, pos.y, pos.z, 0.1, patch.appliedRemaining - patch.remaining)
        patch.appliedRemaining = patch.remaining
    end
end

local function createDecal(patch, now, distance)
    local point = patch.point
    local pos, direction, side, color = point[1], point[2], point[3], point[5]
    RequestCollisionAtCoord(pos.x, pos.y, pos.z)
    -- Use the saved projection vectors and all AddDecal parameters from main.lua.bak.
    local handle = AddDecal(point[4], pos.x, pos.y, pos.z,
        direction.x, direction.y, direction.z, side.x, side.y, side.z,
        3.0, 3.0, color[1], color[2], color[3], patch.remaining, -1.0, false, false, true)
    patch.retryAt = now + 1000
    if handle and handle ~= 0 then
        patch.handle = handle
        patch.appliedRemaining = patch.remaining
        patch.createdAt = now
        patch.createdDistance = distance
    end
end

function DirtRenderer.drawFrame()
    if rendererStopped then return end
    local now = GetGameTimer()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local collisionLoaded = HasCollisionLoadedAroundEntity(ped)
    local checkedBooster = false
    for _, patches in pairs(DirtRenderer.zones) do
        for _, patch in pairs(patches) do
            local distance = #(coords - patch.point[1])
            if patch.remaining <= 0 or distance > renderDistance then
                removeHandle(patch)
            else
                if not checkedBooster then
                    ensureDecalRendering(now)
                    checkedBooster = true
                end
                local pos = patch.point[1]
                RequestCollisionAtCoord(pos.x, pos.y, pos.z)
                if not collisionLoaded then
                    -- A live handle may still refer to geometry that has streamed out.
                    removeHandle(patch)
                    patch.retryAt = now
                else
                    if patch.handle and now - patch.createdAt >= 500
                            and (not IsDecalAlive(patch.handle)
                                or (distance < 15.0 and patch.createdDistance > 25.0)) then
                        -- Refresh once on approach, even if an early handle survived without visible geometry.
                        removeHandle(patch)
                        patch.retryAt = now
                    end
                    if not patch.handle and now >= patch.retryAt then
                        createDecal(patch, now, distance)
                    end
                    applyCleaning(patch)
                end
            end
        end
    end
end

function DirtRenderer.setPoint(zoneId, pointId, point)
    if rendererStopped then return end
    local patches = DirtRenderer.zones[zoneId]
    if not patches then
        patches = {}
        DirtRenderer.zones[zoneId] = patches
    end
    local value = math.max(0, math.min(1, point[5][4]))
    local patch = patches[pointId]
    if patch then
        -- Cleaning is monotonic within a zone; a fresh job starts with removeZone.
        patch.remaining = math.min(patch.remaining, value)
        applyCleaning(patch)
    elseif value > 0 then
        patches[pointId] = { point = point, remaining = value, retryAt = 0 }
    end
    if not rendererRunning then
        rendererRunning = true
        Citizen.CreateThread(function()
            local nextErrorReport = 0
            while not rendererStopped and next(DirtRenderer.zones) do
                local ok, err = xpcall(DirtRenderer.drawFrame, debug.traceback)
                if not ok and GetGameTimer() >= nextErrorReport then
                    nextErrorReport = GetGameTimer() + 30000
                    print("[prp-pressurewash] Dirt renderer will retry after an error: " .. tostring(err))
                end
                Citizen.Wait(250)
            end
            rendererRunning = false
        end)
    end
end

function DirtRenderer.removeZone(zoneId)
    for _, patch in pairs(DirtRenderer.zones[zoneId] or {}) do
        removeHandle(patch)
    end
    DirtRenderer.zones[zoneId] = nil
    if not next(DirtRenderer.zones) then
        nextBoosterCheck = 0
    end
end

function DirtRenderer.stop()
    rendererStopped = true
    for zoneId in pairs(DirtRenderer.zones) do
        DirtRenderer.removeZone(zoneId)
    end
end

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        DirtRenderer.stop()
    end
end)

-- Run at the affected job site to capture engine state in the local FiveM log.
RegisterCommand("pw_dirt_debug", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    print(("[prp-pressurewash] dirt-diag-2 stage=%s jobZone=%s player=%s collision=%s"):format(
        tostring(currentData and currentData.stage), tostring(currentData and currentData.zone),
        tostring(coords), tostring(HasCollisionLoadedAroundEntity(ped))))
    local nearest, nearestDistance
    local zoneCount = 0
    for zoneId, patches in pairs(DirtRenderer.zones) do
        zoneCount = zoneCount + 1
        local dirty, handles, alive = 0, 0, 0
        for pointId, patch in pairs(patches) do
            if patch.remaining > 0 then dirty = dirty + 1 end
            if patch.handle then
                handles = handles + 1
                if IsDecalAlive(patch.handle) then alive = alive + 1 end
            end
            local distance = #(coords - patch.point[1])
            if patch.remaining > 0 and (not nearestDistance or distance < nearestDistance) then
                nearest, nearestDistance = patch, distance
            end
        end
        print(("[prp-pressurewash] dirt-diag-2 zone=%s dirty=%s handles=%s alive=%s"):format(
            zoneId, dirty, handles, alive))
    end
    if not nearest then
        print(("[prp-pressurewash] dirt-diag-2 no dirty patches; trackedZones=%s loadedJobZone=%s"):format(
            zoneCount, tostring(LoadedZones and currentData and LoadedZones[currentData.zone] ~= nil)))
        return
    end
    local point = nearest.point
    print(("[prp-pressurewash] dirt-diag-2 nearest distance=%.2f pos=%s dir=%s side=%s type=%s rgba=%.2f,%.2f,%.2f,%.2f"):format(
        nearestDistance, tostring(point[1]), tostring(point[2]), tostring(point[3]), point[4],
        point[5][1], point[5][2], point[5][3], nearest.remaining))
    if #point[2] < 0.001 then
        print("[prp-pressurewash] dirt-diag-2 invalid projection direction")
        return
    end
    local direction = point[2] / #point[2]
    local from, to = point[1] - direction * 2.0, point[1] + direction * 2.0
    local probe = StartShapeTestLosProbe(from.x, from.y, from.z, to.x, to.y, to.z, 81, ped, 4)
    local timeout = GetGameTimer() + 1500
    local status, hit, pos, normal
    repeat
        Citizen.Wait(0)
        status, hit, pos, normal = GetShapeTestResult(probe)
    until status ~= 1 or GetGameTimer() >= timeout
    print(("[prp-pressurewash] dirt-diag-2 surface status=%s hit=%s pos=%s normal=%s offset=%s"):format(
        tostring(status), tostring(hit), tostring(pos), tostring(normal),
        pos and tostring(#(pos - point[1])) or "none"))
end, false)

RegisterCommand("pw_dirt_test", function()
    local from = GetGameplayCamCoord()
    local rotation = GetGameplayCamRot(2)
    local pitch, yaw = math.rad(rotation.x), math.rad(rotation.z)
    local forward = vec3(-math.sin(yaw) * math.cos(pitch), math.cos(yaw) * math.cos(pitch), math.sin(pitch))
    local to = from + forward * 20.0
    local _, hit, pos, normal = GetShapeTestResult(StartExpensiveSynchronousShapeTestLosProbe(
        from.x, from.y, from.z, to.x, to.y, to.z, 81, PlayerPedId(), 4))
    if not (hit == true or hit == 1) or #normal < 0.001 then
        print("[prp-pressurewash] dirt-diag-2 test: aim at a nearby wall or the ground")
        return
    end
    local direction = -normal
    local axis = math.abs(direction.z) < 0.9 and vec3(0, 0, 1) or vec3(1, 0, 0)
    local dot = axis.x * direction.x + axis.y * direction.y + axis.z * direction.z
    local side = axis - direction * dot
    side = side / #side
    local handle = AddDecal(1020, pos.x, pos.y, pos.z,
        direction.x, direction.y, direction.z, side.x, side.y, side.z,
        3.0, 3.0, 0.35, 0.2, 0.1, 1.0, 20.0, true, false, true)
    print(("[prp-pressurewash] dirt-diag-2 mud test pos=%s handle=%s; temporary patch lasts 20 seconds"):format(
        tostring(pos), tostring(handle)))
end, false)
