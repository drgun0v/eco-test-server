-- JG HUD Client Vehicle Controls Script

-- Vehicle control menu state
local isVehicleControlMenuOpen = false

-- Toggle boat anchor
local function ToggleBoatAnchor(vehicle)
    if not vehicle or vehicle == 0 then
        return
    end
    
    -- Only driver can anchor
    if cache.seat ~= -1 then
        return
    end
    
    -- Only works for boats
    if GetVehicleType(vehicle) ~= "sea" then
        return
    end
    
    -- Check if boat is moving too fast (speed * 2.2 converts to km/h)
    local speed = GetEntitySpeed(vehicle) * 2.2
    if speed > 5 then
        return
    end
    
    -- Allow boat to remain anchored while player is driver
    _ENV.SetBoatRemainsAnchoredWhilePlayerIsDriver(vehicle, true)
    
    -- Toggle anchor state
    local isAnchored = IsBoatAnchored(vehicle)
    SetBoatAnchor(vehicle, not isAnchored)
end

-- Toggle vehicle engine
local function ToggleVehicleEngine(vehicle)
    if not vehicle or vehicle == 0 then
        return
    end
    
    -- Only driver can toggle engine
    if cache.seat ~= -1 then
        return
    end
    
    local isEngineRunning = GetIsVehicleEngineRunning(vehicle)
    Framework.Client.ToggleEngine(vehicle, not isEngineRunning)
end

-- Execute vehicle control action
local function ExecuteVehicleControlAction(action, value)
    if not cache.vehicle or cache.vehicle == 0 then
        return
    end
    
    local _, headlights, highBeams = GetVehicleLightsState(cache.vehicle)
    local isPassenger = cache.seat ~= -1
    
    -- Toggle engine (driver only)
    if action == "TOGGLE_ENGINE" and not isPassenger then
        ToggleVehicleEngine(cache.vehicle)
        
    -- Turn signals (driver only)
    elseif action == "INDICATE" and not isPassenger then
        Indicate(value)
        
    -- Toggle seatbelt (all occupants)
    elseif action == "TOGGLE_SEATBELT" then
        ToggleSeatbelt(cache.vehicle, not IsSeatbeltOn)
        
    -- Toggle cruise control (driver only)
    elseif action == "TOGGLE_CRUISE_CONTROL" and not isPassenger then
        ToggleCruiseControl(cache.vehicle, cache.seat)
        
    -- Toggle headlights (driver only)
    elseif action == "TOGGLE_HEADLIGHTS" and not isPassenger then
        if not GetIsVehicleEngineRunning(cache.vehicle) then
            return
        end
        
        -- Toggle between off (4) and on (3)
        local newState = (not headlights and not highBeams) and 3 or 4
        SetVehicleLights(cache.vehicle, newState)
        
    -- Toggle interior light (driver only)
    elseif action == "TOGGLE_INTERIOR_LIGHT" and not isPassenger then
        local isOn = IsVehicleInteriorLightOn(cache.vehicle)
        SetVehicleInteriorlight(cache.vehicle, not isOn)
        
    -- Toggle vehicle door
    elseif action == "TOGGLE_VEHICLE_DOOR" then
        -- Prevent passengers from opening their own door
        if not isPassenger or cache.seat ~= (value - 1) then
            local doorAngle = GetVehicleDoorAngleRatio(cache.vehicle, value)
            local isDoorOpen = doorAngle > 0.01
            
            if isDoorOpen then
                SetVehicleDoorShut(cache.vehicle, value, false)
            else
                SetVehicleDoorOpen(cache.vehicle, value, false, false)
            end
        end
        
    -- Toggle vehicle window
    elseif action == "TOGGLE_VEHICLE_WINDOW" then
        -- Prevent passengers from opening their own window
        if not isPassenger or cache.seat ~= (value - 1) then
            local isWindowIntact = IsVehicleWindowIntact(cache.vehicle, value)
            
            if isWindowIntact then
                RollDownWindow(cache.vehicle, value)
            else
                RollUpWindow(cache.vehicle, value)
            end
        end
        
    -- Change seat
    elseif action == "SET_VEHICLE_SEAT" then
        TaskWarpPedIntoVehicle(cache.ped, cache.vehicle, value)
        
    -- Toggle boat anchor (driver only)
    elseif action == "TOGGLE_ANCHOR" and not isPassenger then
        ToggleBoatAnchor(cache.vehicle)
        
    -- Toggle landing gear (driver only, aircraft)
    elseif action == "TOGGLE_GEAR" and not isPassenger then
        local gearState = GetLandingGearState(cache.vehicle)
        local newState = (gearState == 0) and 1 or 2  -- 0 = down, 1 = raising, 2 = lowering
        ControlLandingGear(cache.vehicle, newState)
        
    -- Toggle convertible roof (driver only)
    elseif action == "TOGGLE_CONVERTIBLE_ROOF" and not isPassenger then
        local roofState = GetConvertibleRoofState(cache.vehicle)
        local isRoofRaised = roofState == 0
        
        if isRoofRaised then
            LowerConvertibleRoof(cache.vehicle, false)
        else
            RaiseConvertibleRoof(cache.vehicle, false)
        end
    end
end

-- Get current vehicle control state
local function GetVehicleControlState()
    if not cache.vehicle or cache.vehicle == 0 then
        return false
    end
    
    local _, headlights, highBeams = GetVehicleLightsState(cache.vehicle)
    local doorCount = GetNumberOfVehicleDoors(cache.vehicle)
    local seatCount = GetVehicleModelNumberOfSeats(GetEntityModel(cache.vehicle))
    local isPassenger = cache.seat ~= -1
    
    -- Check door states
    local doors = {}
    local availableDoors = {}
    for i = 0, 6 do
        local doorAngle = GetVehicleDoorAngleRatio(cache.vehicle, i)
        doors[i] = doorAngle > 0.01
        
        -- Door is available if it exists and not the passenger's own door
        local isDoorAvailable = DoesVehicleHaveDoor(cache.vehicle, i)
        if isPassenger and cache.seat == (i - 1) then
            isDoorAvailable = false
        end
        availableDoors[i] = isDoorAvailable
    end
    
    -- Check seat occupancy
    local seats = {}
    for i = -1, seatCount do
        local pedInSeat = GetPedInVehicleSeat(cache.vehicle, i)
        
        if pedInSeat == cache.ped then
            seats[i] = "IN_SEAT"
        elseif not IsVehicleSeatFree(cache.vehicle, i) then
            seats[i] = "OCCUPIED"
        else
            seats[i] = false
        end
    end
    
    -- Check window states
    local windows = {}
    local availableWindows = {}
    for i = 0, seatCount - 1 do
        windows[i] = not IsVehicleWindowIntact(cache.vehicle, i)
        availableWindows[i] = not isPassenger
    end
    
    return {
        -- Engine and lights
        engineStatus = GetIsVehicleEngineRunning(cache.vehicle),
        headlights = headlights,
        highBeams = highBeams,
        interiorLight = IsVehicleInteriorLightOn(cache.vehicle),
        
        -- Turn signals
        indicatingLeft = IsVehicleIndicating(cache.vehicle, "left"),
        indicatingRight = IsVehicleIndicating(cache.vehicle, "right"),
        hazards = IsVehicleIndicating(cache.vehicle, "hazards"),
        
        -- Player state
        isPassenger = isPassenger,
        seatbelt = IsSeatbeltOn,
        cruiseControl = IsCruiseControlEnabled,
        
        -- Doors
        doors = doors,
        availableDoors = availableDoors,
        bonnetOpen = doorCount == 6,
        bootOpen = doorCount == 6,
        
        -- Convertible
        isConvertible = IsVehicleAConvertible(cache.vehicle, false),
        convertibleRoofRaised = GetConvertibleRoofState(cache.vehicle) == 0,
        
        -- Windows
        windows = windows,
        availableWindows = availableWindows,
        
        -- Seats
        seats = seats,
        seatsCount = seatCount,
        
        -- Special features
        anchored = IsBoatAnchored(cache.vehicle),
        gear = GetLandingGearState(cache.vehicle) == 0
    }
end

-- Get control menu update interval based on performance mode
local function GetControlMenuUpdateInterval()
    local perfMode = UserSettingsData and UserSettingsData.performanceMode
    
    if perfMode == "ultra" then
        return 50
    elseif perfMode == "performance" then
        return 100
    elseif perfMode == "lowResmon" then
        return 500
    end
    
    return 200  -- Default
end

-- Start vehicle control menu threads
local function StartVehicleControlThreads()
    if isVehicleControlMenuOpen then
        return
    end
    
    if not cache.vehicle then
        return
    end
    
    isVehicleControlMenuOpen = true
    local updateInterval = GetControlMenuUpdateInterval()
    
    -- Thread to disable camera controls while menu is open
    CreateThread(function()
        while isVehicleControlMenuOpen do
            DisableControlAction(0, 1, true)   -- Camera pan left/right
            DisableControlAction(0, 2, true)   -- Camera pan up/down
            DisableControlAction(1, 199, true) -- Mouse wheel up
            DisableControlAction(1, 200, true) -- Mouse wheel down
            Wait(0)
        end
    end)
    
    -- Thread to update vehicle control state
    CreateThread(function()
        Wait(1)
        
        while isVehicleControlMenuOpen do
            local controlState = GetVehicleControlState()
            
            if not controlState then
                -- No longer in vehicle, close menu
                ToggleVehicleControl(false)
                SendNUIMessage({
                    type = "closeVehicleControls"
                })
                break
            end
            
            SendNUIMessage({
                type = "vehicleControlsStateData",
                data = controlState
            })
            
            Wait(updateInterval)
        end
    end)
end

-- Toggle vehicle control menu
function ToggleVehicleControl(show)
    if not show then
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        isVehicleControlMenuOpen = false
        return
    end
    
    -- Prevent opening if already open
    if isVehicleControlMenuOpen then
        return
    end
    
    -- Don't open in pause menu
    if IsPauseMenuActive() then
        return
    end
    
    -- Must be in a vehicle
    if not cache.vehicle then
        return
    end
    
    -- Check if passenger and if passengers are allowed
    if cache.seat ~= -1 then
        if not Config.AllowPassengersToUseVehicleControl then
            return
        end
    end
    
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)
    
    SendNUIMessage({
        type = "showVehicleControls"
    })
    
    StartVehicleControlThreads()
end

-- NUI Callback: Execute vehicle control action
RegisterNUICallback("vehicleControlAction", function(data, cb)
    if not data or not data.action then
        return cb({ error = true })
    end
    
    if not cache.vehicle or cache.vehicle == 0 then
        return cb({ error = true })
    end
    
    ExecuteVehicleControlAction(data.action, data.value)
    cb(true)
end)

-- NUI Callback: Close vehicle controls
RegisterNUICallback("closeVehicleControls", function(data, cb)
    ToggleVehicleControl(false)
    cb(true)
end)

-- Keybind: Open vehicle control menu
if Config.VehicleControlKeybind then
    RegisterCommand("open_vehicle_controls", function()
        ToggleVehicleControl(true)
    end)
    
    RegisterKeyMapping(
        "open_vehicle_controls",
        "Open vehicle control menu",
        "keyboard",
        Config.VehicleControlKeybind or "F6"
    )
end

-- Keybind: Boat anchor
if Config.BoatAnchorKeybind then
    RegisterCommand("anchor_boat", function()
        ToggleBoatAnchor(cache.vehicle)
    end)
    
    RegisterKeyMapping(
        "anchor_boat",
        "Anchor boat",
        "keyboard",
        Config.BoatAnchorKeybind or "J"
    )
end

-- Keybind: Engine toggle
if Config.EngineToggleKeybind then
    RegisterCommand("toggle_engine", function()
        ToggleVehicleEngine(cache.vehicle)
    end)
    
    RegisterKeyMapping(
        "toggle_engine",
        "Toggle vehicle engine",
        "keyboard",
        Config.EngineToggleKeybind or "G"
    )
end

-- Export: Toggle vehicle control menu
exports("toggleVehicleControl", function(show)
    ToggleVehicleControl(show)
end)

-- Network event: Toggle vehicle control menu
RegisterNetEvent("jg-hud:client:toggle-vehicle-control", function(show)
    ToggleVehicleControl(show)
end)