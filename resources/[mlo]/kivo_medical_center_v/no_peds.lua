-- ============================================
-- Little Seoul Park - NPC Spawn Blocker
-- Integrated into Kivo Medical Center Resource
-- ============================================

-- Zone center coordinates
local zoneCenter = vector3(-932.842, -746.8599, 17.04503)

-- Zone radius (in meters)
local zoneRadius = 80.0

-- Blocking box (built around zoneCenter)
local minX = zoneCenter.x - zoneRadius
local minY = zoneCenter.y - zoneRadius
local minZ = zoneCenter.z - 50.0
local maxX = zoneCenter.x + zoneRadius
local maxY = zoneCenter.y + zoneRadius
local maxZ = zoneCenter.z + 100.0

-- Main spawn-blocking thread (runs every frame while near zone)
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local dist = #(playerCoords - zoneCenter)
        
        if dist < zoneRadius + 100.0 then
            -- Player is near the zone: block every frame
            
            -- Block NPC spawning in this area
            SetPedNonCreationArea(minX, minY, minZ, maxX, maxY, maxZ)
            
            -- Zero out pedestrian density for this frame
            SetPedDensityMultiplierThisFrame(0.0)
            SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
            
            Citizen.Wait(0)
        else
            -- Player is far: clear blocking, save resources
            ClearPedNonCreationArea()
            Citizen.Wait(2000)
        end
    end
end)

-- Cleanup thread (twice per second - removes existing NPCs)
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local dist = #(playerCoords - zoneCenter)
        
        if dist < zoneRadius + 100.0 then
            -- Remove existing NPCs in the zone
            ClearAreaOfPeds(zoneCenter.x, zoneCenter.y, zoneCenter.z, zoneRadius, 1)
            
            Citizen.Wait(500)
        else
            Citizen.Wait(3000)
        end
    end
end)

-- Clear blocking when resource is stopped
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        ClearPedNonCreationArea()
    end
end)
