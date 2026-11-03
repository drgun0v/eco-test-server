-- Client-side Cruise Control Script
-- Manages vehicle cruise control functionality

IsCruiseControlEnabled = false
local cruiseSpeed = 0.0

-- Check if vehicle is drifting/sliding (angle between forward vector and velocity)
-- Returns: isDrifting (bool), angle (number)
local function IsVehicleDrifting(vehicle, threshold)
    threshold = threshold or 0.01
    
    local forwardVector = GetEntityForwardVector(vehicle)
    local velocity = GetEntityVelocity(vehicle)
    
    -- Calculate speed magnitude
    local speed = math.sqrt(
        velocity.x^2 + 
        velocity.y^2 + 
        velocity.z^2
    )
    
    -- If speed is too low, not drifting
    if speed < 1.0 then
        return false, 0.0
    end
    
    -- Normalize velocity vector
    local normalizedVelocity = {
        x = velocity.x / speed,
        y = velocity.y / speed,
        z = velocity.z / speed
    }
    
    -- Calculate dot product (cosine of angle between vectors)
    local dotProduct = 
        forwardVector.x * normalizedVelocity.x +
        forwardVector.y * normalizedVelocity.y +
        forwardVector.z * normalizedVelocity.z
    
    -- Clamp dot product to [-1, 1] range
    dotProduct = math.max(-1, math.min(1, dotProduct))
    
    -- Calculate angle in radians then convert to degrees
    local angleRadians = math.acos(dotProduct)
    local angleDegrees = math.deg(angleRadians)
    
    -- Check if angle exceeds threshold
    local isDrifting = angleDegrees > (threshold * 180)
    
    return isDrifting, angleDegrees
end

-- Check if player is using steering controls (braking or turning)
local function IsPlayerSteering(vehicle)
    -- Check brake (control 76)
    if IsControlPressed(2, 76) then
        return true
    end
    
    -- Check left turn (control 63)
    if IsControlPressed(2, 63) then
        return true
    end
    
    -- Check right turn (control 64)
    if IsControlPressed(2, 64) then
        return true
    end
    
    return false
end

-- Toggle cruise control on/off
function ToggleCruiseControl(vehicle, seatIndex)
    -- Check if cruise control is enabled in config
    if not Config.EnableCruiseControl then
        return
    end
    
    -- If already enabled, disable it
    if IsCruiseControlEnabled then
        IsCruiseControlEnabled = false
        return
    end
    
    -- Validate vehicle and seat (must be driver seat)
    if not vehicle or seatIndex ~= -1 then
        return
    end
    
    -- Only works for land vehicles
    local vehicleType = GetVehicleType(vehicle)
    if vehicleType ~= "land" then
        return
    end
    
    -- Must be moving
    local currentSpeed = GetEntitySpeed(vehicle)
    if currentSpeed < 1.0 then
        return
    end
    
    -- Engine must be running
    if not GetIsVehicleEngineRunning(vehicle) then
        return
    end
    
    -- Don't enable if vehicle is drifting
    if IsVehicleDrifting(vehicle) then
        return
    end
    
    -- Don't enable if player is actively steering
    if IsPlayerSteering(vehicle) then
        return
    end
    
    -- Enable cruise control
    IsCruiseControlEnabled = true
    cruiseSpeed = GetEntitySpeed(vehicle)
    
    -- Start cruise control thread
    CreateThread(function()
        while true do
            -- Exit conditions
            if not cache.vehicle then break end
            if not IsCruiseControlEnabled then break end
            if not IsHudRunning then break end
            
            local engineRunning = GetIsVehicleEngineRunning(vehicle)
            local currentSpeed = GetEntitySpeed(cache.vehicle)
            local isSteering = IsPlayerSteering(vehicle)
            
            -- Disable cruise if engine stops, steering, or speed drops too much
            if not engineRunning or isSteering or currentSpeed < (cruiseSpeed - 1.5) then
                IsCruiseControlEnabled = false
                Wait(500)
                break
            end
            
            -- Maintain cruise speed if not steering and on ground
            if not isSteering then
                if IsVehicleOnAllWheels(cache.vehicle) then
                    if currentSpeed < cruiseSpeed then
                        SetVehicleForwardSpeed(cache.vehicle, cruiseSpeed)
                    end
                end
            end
            
            -- Update cruise speed with Y key (control 246)
            if IsControlJustPressed(1, 246) then
                cruiseSpeed = GetEntitySpeed(cache.vehicle)
            end
            
            -- Cancel cruise control with up arrow (control 72)
            if IsControlJustPressed(2, 72) then
                IsCruiseControlEnabled = false
                Wait(500)
                break
            end
            
            Wait(50)
        end
    end)
end

-- Register cruise control keybind if enabled
if Config.EnableCruiseControl and Config.CruiseControlKeybind then
    RegisterCommand("toggle_cruise", function()
        ToggleCruiseControl(cache.vehicle, cache.seat)
    end, false)
    
    RegisterKeyMapping(
        "toggle_cruise",
        "Toggle cruise control",
        "keyboard",
        Config.CruiseControlKeybind or "J"
    )
end