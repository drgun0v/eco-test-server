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

-- prp-pressurewash: zone creator (client).
-- Aim with the camera and press [E] to add points; the finished zone is sent to the server.

local glm = require("glm")
local up = glm.up()
local right = glm.right()
-- Synchronous line-of-sight probe; returns the GetShapeTestResultIncludingMaterial results.
local function raycast(from, to, flags, options)
    return GetShapeTestResultIncludingMaterial(
        StartExpensiveSynchronousShapeTestLosProbe(from.x, from.y, from.z, to.x, to.y, to.z, flags or 511,
            PlayerPedId(), options or 4))
end
local cameraCache = {}
local rad = glm.rad
local quatEulerAngleZYX = glm.quatEulerAngleZYX
local rayPicking = glm.rayPicking
local forward = glm.forward()
local perpendicular = glm.perpendicular
-- Rendering camera position and a ray direction through the screen centre.
function ScreenPositionToCameraRay()
    local cam = GetRenderingCam()
    if not next(cameraCache) then
        cameraCache.ratio = GetAspectRatio(true)
        cameraCache.fov = GetCamFov(cam)
    end
    local camCoords = GetCamCoord(cam)
    local camRot = rad(GetCamRot(cam, 2))
    local camQuat = quatEulerAngleZYX(camRot.z, camRot.y, camRot.x)
    return camCoords, rayPicking(camQuat * forward, camQuat * up, rad(cameraCache.fov), cameraCache.ratio, 0.1, 10000.0, 0, 0)
end
-- Creator session: [E] add point, [X] remove last, [ENTER] save zone, [ESC] cancel.
RegisterNetEvent("prp-pressurewash:client:newCreatorStart", function()
    local blockedControls = { 177, 200, 202, 322 }
    local function disableControls()
        for i = 1, #blockedControls do
            DisableControlAction(0, blockedControls[i], true)
        end
    end
    local zones = lib.callback.await("prp-pressurewash:getZones", false)
    local zoneBlips = {}
    for i = 1, #zones do
        zoneBlips[#zoneBlips + 1] = AddBlipForRadius(zones[i].x, zones[i].y, zones[i].z, 20.0)
    end
    DisplayRadar(true)
    -- point = { coords, -normal, perpendicular, isFlat }
    local points = {}
    bridge.fw.showTextUI([[
[E] - Add Point   
[X] - Remove Last Point   
[ENTER] - Confirm Zone   
[ESC] - Cancel Creator]])
    while true do
        DisableControlAction(0, 38, true)
        DisableControlAction(0, 191, true)
        DisableControlAction(0, 73, true)
        disableControls()
        local rayOrigin, rayDirection = ScreenPositionToCameraRay()
        local _, hit, hitCoords, surfaceNormal = raycast(rayOrigin, rayOrigin + 10000 * rayDirection, 511)
        if hit then
            local foundGround, groundZ = GetGroundZFor_3dCoord(hitCoords.x, hitCoords.y, hitCoords.z, true)
            DrawMarker(28, hitCoords.x, hitCoords.y, hitCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 42,
                foundGround and math.abs(hitCoords.z - groundZ) < 0.1 and 255 or 24, 100, false, false, 0, true, false,
                false, false)
            if IsDisabledControlJustPressed(0, 38) then
                points[#points + 1] = {
                    hitCoords,
                    -surfaceNormal,
                    perpendicular(surfaceNormal, -up, right),
                    foundGround and math.abs(hitCoords.z - groundZ) < 0.1 and true or false,
                }
            end
        end
        if IsDisabledControlJustPressed(0, 73) and #points > 0 then
            table.remove(points, #points)
        end
        -- [ENTER]: split the points into 4 wall groups and 2 flat groups (round-robin) and save the zone.
        if IsDisabledControlJustPressed(0, 191) then
            local wallPoints = {}
            local flatPoints = {}
            local walls = { {}, {}, {}, {} }
            local flats = { {}, {} }
            local sum = vec3(0.0, 0.0, 0.0)
            for i = 1, #points do
                local point = points[i]
                if point[4] then
                    flatPoints[#flatPoints + 1] = point
                    flatPoints[#flatPoints][4] = nil
                else
                    wallPoints[#wallPoints + 1] = point
                    wallPoints[#wallPoints][4] = nil
                    sum = sum + point[1]
                end
            end
            local center = vec3(sum.x / #wallPoints, sum.y / #wallPoints, sum.z / #wallPoints)
            for i = 1, #wallPoints do
                local wallIndex = (i - 1) % 4 + 1
                walls[wallIndex][#walls[wallIndex] + 1] = wallPoints[i]
            end
            for i = 1, #flatPoints do
                local flatIndex = (i - 1) % 2 + 1
                flats[flatIndex][#flats[flatIndex] + 1] = flatPoints[i]
            end
            local zone = GetNameOfZone(center.x, center.y, center.z)
            local zoneScumminess = GetZoneScumminess(GetZoneFromNameId(zone))
            TriggerServerEvent("prp-pressurewash:server:saveZone", center, walls, flats, zone, GetLabelText(zone),
                zoneScumminess)
            break
        end
        if IsDisabledControlJustPressed(0, 200) then
            break
        end
        for i = 1, #points do
            local pointCoords = points[i][1]
            DrawMarker(28, pointCoords.x, pointCoords.y, pointCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2,
                255, 42, points[i][4] and 255 or 24, 100, false, false, 0, true, false, false, false)
        end
        Wait(0)
    end
    bridge.fw.hideTextUI()
    for i = 1, #zoneBlips do
        RemoveBlip(zoneBlips[i])
    end
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
        DisplayRadar(false)
    end
    for i = 1, 30 do
        disableControls()
        Wait(0)
    end
end)
