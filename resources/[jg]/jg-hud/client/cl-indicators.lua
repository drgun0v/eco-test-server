-- Client-side Vehicle Indicators Script
-- Manages turn signals and hazard lights with state synchronization

-- Get the current indicator state of a vehicle
-- Returns: table with [1] = right indicator, [2] = left indicator
function GetIndicatingState(vehicle)
    if not vehicle or vehicle == 0 then
        return {false, false}
    end
    
    local state = Entity(vehicle).state
    local indicateState = state and state.indicate
    
    if not indicateState then
        return {false, false}
    end
    
    return indicateState
end

-- Check if a vehicle is indicating in a specific direction
-- @param vehicle: The vehicle entity
-- @param direction: "left", "right", or "hazards"
-- Returns: boolean
function IsVehicleIndicating(vehicle, direction)
    if not vehicle or vehicle == 0 then
        return false
    end
    
    local indicateState = Entity(vehicle).state.indicate
    
    if not indicateState then
        return false
    end
    
    local rightIndicator = indicateState[1]
    local leftIndicator = indicateState[2]
    
    -- Check for hazards (both indicators on)
    if rightIndicator and leftIndicator and direction == "hazards" then
        return true
    end
    
    -- Check for right indicator only
    if rightIndicator and not leftIndicator and direction == "right" then
        return true
    end
    
    -- Check for left indicator only
    if not rightIndicator and leftIndicator and direction == "left" then
        return true
    end
    
    return false
end

-- Toggle indicator state for the player's vehicle
-- @param direction: "left", "right", "hazards", or any other value to turn off
function Indicate(direction)
    -- Must be in driver seat of a vehicle
    if not cache.vehicle or cache.seat ~= -1 then
        return false
    end
    
    -- Don't allow while pause menu is open
    if IsPauseMenuActive() then
        return false
    end
    
    local newState = {false, false}
    
    if direction == "left" then
        -- Toggle left indicator
        if not IsVehicleIndicating(cache.vehicle, "left") then
            newState = {false, true}  -- [1] = right, [2] = left
        end
    elseif direction == "right" then
        -- Toggle right indicator
        if not IsVehicleIndicating(cache.vehicle, "right") then
            newState = {true, false}  -- [1] = right, [2] = left
        end
    elseif direction == "hazards" then
        -- Toggle hazards
        if not IsVehicleIndicating(cache.vehicle, "hazards") then
            newState = {true, true}  -- Both on
        end
    else
        -- Turn off all indicators
        newState = {false, false}
    end
    
    -- Update vehicle state (synced across clients)
    Entity(cache.vehicle).state:set("indicate", newState, true)
end

-- State bag change handler - syncs indicator state across all clients
AddStateBagChangeHandler("indicate", "", function(bagName, key, value)
    local vehicle = GetEntityFromStateBagName(bagName)
    
    if vehicle == 0 then
        return
    end
    
    -- Update vehicle indicator lights
    -- value[1] = right indicator, value[2] = left indicator
    for index, isOn in ipairs(value) do
        SetVehicleIndicatorLights(vehicle, index - 1, isOn)
    end
    
    -- Update UI
    SendNUIMessage({
        type = "vehicleStatusUpdate",
        data = {
            indicators = value
        }
    })
end)

-- Register keybinds for indicators

-- Left indicator
if Config.IndicatorLeftKeybind then
    RegisterCommand("indicate_left", function()
        Indicate("left")
    end)
    
    RegisterKeyMapping(
        "indicate_left",
        "Vehicle indicate left",
        "keyboard",
        Config.IndicatorLeftKeybind or "LEFT"
    )
end

-- Right indicator
if Config.IndicatorRightKeybind then
    RegisterCommand("indicate_right", function()
        Indicate("right")
    end)
    
    RegisterKeyMapping(
        "indicate_right",
        "Vehicle indicate right",
        "keyboard",
        Config.IndicatorRightKeybind or "RIGHT"
    )
end

-- Hazard lights
if Config.IndicatorHazardsKeybind then
    RegisterCommand("hazards", function()
        Indicate("hazards")
    end)
    
    RegisterKeyMapping(
        "hazards",
        "Vehicle hazards",
        "keyboard",
        Config.IndicatorHazardsKeybind or "UP"
    )
end