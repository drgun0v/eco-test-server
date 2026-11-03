-- JG HUD Client Vehicle Script

-- Native function references for better performance
local GetIsVehicleEngineRunning = GetIsVehicleEngineRunning
local GetEntitySpeed = GetEntitySpeed
local GetVehicleCurrentGear = GetVehicleCurrentGear
local GetEntityVelocity = GetEntityVelocity
local GetEntityForwardVector = GetEntityForwardVector
local GetVehicleCurrentRpm = GetVehicleCurrentRpm
local GetEntityCoords = GetEntityCoords
local GetEntityRotation = GetEntityRotation
local GetVehicleLightsState = GetVehicleLightsState
local GetVehicleEngineHealth = GetVehicleEngineHealth
local GetLandingGearState = GetLandingGearState
local GetTrainDoorCount = GetTrainDoorCount
local GetTrainDoorOpenRatio = GetTrainDoorOpenRatio
local IsBoatAnchored = IsBoatAnchored
local GetEntityModel = GetEntityModel

-- Handle entering vehicle
local function OnEnteredVehicle(vehicle)
    SendNUIMessage({
        type = "enteredVehicle",
        vehicleType = GetVehicleType(vehicle)
    })
    
    -- Show minimap if not set to show on foot
    if not (Config.ShowMinimapOnFoot and UserSettingsData and UserSettingsData.showMinimapOnFoot) then
        DisplayRadar(true)
    end
end

-- Handle exiting vehicle
local function OnExitedVehicle()
    SendNUIMessage({
        type = "exitedVehicle"
    })
    
    -- Hide minimap if not set to show on foot
    if not (Config.ShowMinimapOnFoot and UserSettingsData and UserSettingsData.showMinimapOnFoot) then
        DisplayRadar(false)
    end
end

-- Get vehicle telemetry update interval based on performance mode
local function GetTelemetryUpdateInterval()
    local perfMode = UserSettingsData and UserSettingsData.performanceMode
    
    if perfMode == "ultra" then
        return 50
    elseif perfMode == "performance" then
        return 75
    elseif perfMode == "lowResmon" then
        return 150
    end
    
    return 100  -- Default
end

-- Vehicle telemetry thread state
local isTelemetryThreadRunning = false

-- Create vehicle telemetry thread (speed, RPM, gear, etc.)
local function CreateVehicleTelemetryThread(vehicle)
    local vehicleType = GetVehicleType(vehicle)
    local isElectric = vehicleType == "land" and IsVehicleElectric(vehicle)
    local updateInterval = GetTelemetryUpdateInterval()
    
    CreateThread(function()
        if isTelemetryThreadRunning then
            return
        end
        
        isTelemetryThreadRunning = true
        
        while cache.vehicle and IsHudRunning do
            local engineOn = GetIsVehicleEngineRunning(cache.vehicle)
            local speed = GetEntitySpeed(cache.vehicle)
            
            local telemetryData = {
                speed = Framework.Client.ConvertSpeed(
                    speed, 
                    UserSettingsData and UserSettingsData.speedMeasurement
                ),
                isElectric = isElectric
            }
            
            -- Land vehicle specific data (cars, trucks, bikes)
            if vehicleType == "land" then
                local gear = GetVehicleCurrentGear(cache.vehicle)
                local velocity = GetEntityVelocity(cache.vehicle)
                local forwardVector = GetEntityForwardVector(cache.vehicle)
                
                -- Calculate if moving forward or backward (dot product)
                local dotProduct = (velocity.x * forwardVector.x) + (velocity.y * forwardVector.y)
                
                -- Determine gear display
                local gearDisplay
                if gear == 0 then
                    gearDisplay = "N"  -- Neutral
                elseif isElectric then
                    gearDisplay = "D"  -- Drive (electric)
                end
                
                if dotProduct < 0 then
                    gearDisplay = "R"  -- Reverse
                end
                
                -- Check if braking (electric vehicles only)
                local isBraking = false
                if isElectric and dotProduct > 0 then
                    isBraking = IsControlPressed(0, 72)  -- Brake control
                end
                
                -- RPM data
                local rpmData = {
                    currentRpm = 0,
                    redline = 6000,
                    maxRpm = 8000
                }
                
                if engineOn then
                    rpmData.currentRpm = math.floor(math.min(1.0, GetVehicleCurrentRpm(cache.vehicle) - 0.05) * 8500)
                end
                
                telemetryData.rpm = rpmData
                telemetryData.gear = gearDisplay
                telemetryData.isBraking = isBraking
                
            -- Bicycle specific data
            elseif vehicleType == "bicycle" then
                local x, y, z = table.unpack(GetEntityCoords(cache.vehicle))
                local altitude = Framework.Client.ConvertDistance(
                    z,
                    UserSettingsData and UserSettingsData.distanceMeasurement
                )
                
                local rpmData = {
                    currentRpm = math.floor(math.min(1.0, GetVehicleCurrentRpm(cache.vehicle)) * 10000),
                    redline = 0,
                    maxRpm = 0
                }
                
                telemetryData.rpm = rpmData
                telemetryData.altitude = altitude
                
            -- Boat specific data
            elseif vehicleType == "sea" then
                local gear = GetVehicleCurrentGear(cache.vehicle)
                local velocity = GetEntityVelocity(cache.vehicle)
                local forwardVector = GetEntityForwardVector(cache.vehicle)
                
                local dotProduct = (velocity.x * forwardVector.x) + (velocity.y * forwardVector.y)
                
                local gearDisplay
                if gear == 0 then
                    gearDisplay = "N"
                else
                    gearDisplay = "D"
                end
                
                if dotProduct < 0 then
                    gearDisplay = "R"
                end
                
                telemetryData.gear = gearDisplay
                
            -- Aircraft specific data
            elseif vehicleType == "air" then
                local x, y, z = table.unpack(GetEntityCoords(cache.vehicle))
                local altitude = Framework.Client.ConvertDistance(
                    z,
                    UserSettingsData and UserSettingsData.distanceMeasurement
                )
                
                local rotation = GetEntityRotation(cache.vehicle, 0)
                local heading = GetEntityHeading(cache.vehicle)
                
                telemetryData.altitude = altitude
                telemetryData.rotation = rotation
                telemetryData.heading = heading
            end
            
            SendNUIMessage({
                type = "vehicleTelemetryData",
                data = telemetryData
            })
            
            Wait(updateInterval)
        end
        
        isTelemetryThreadRunning = false
    end)
end

-- Get vehicle status update interval based on performance mode
local function GetStatusUpdateInterval()
    local perfMode = UserSettingsData and UserSettingsData.performanceMode
    
    if perfMode == "ultra" then
        return 100
    elseif perfMode == "performance" then
        return 200
    elseif perfMode == "lowResmon" then
        return 700
    end
    
    return 300  -- Default
end

-- Send vehicle status update to NUI
local function SendVehicleStatusUpdate(data)
    SendNUIMessage({
        type = "vehicleStatusUpdate",
        data = data
    })
end

-- Vehicle status thread state
local isStatusThreadRunning = false

-- Create vehicle status thread (engine, lights, fuel, etc.)
local function CreateVehicleStatusThread(vehicle)
    local vehicleType = GetVehicleType(vehicle)
    local updateInterval = GetStatusUpdateInterval()
    
    CreateThread(function()
        if isStatusThreadRunning then
            return
        end
        
        isStatusThreadRunning = true
        
        while cache.vehicle and IsHudRunning do
            local engineOn = GetIsVehicleEngineRunning(cache.vehicle)
            local lightsState, headlights, highBeams = GetVehicleLightsState(cache.vehicle)
            
            -- Engine health
            local engineHealth = 0
            if engineOn then
                engineHealth = (GetVehicleEngineHealth(cache.vehicle) / 1000) * 100
            end
            
            -- Check if aircraft for gear display
            local isAircraft = vehicleType == "air"
            
            -- Get fuel level
            local fuel = Framework.Client.VehicleGetFuel(cache.vehicle)
            
            -- Get mileage
            local mileageKm = Framework.Client.GetVehicleMileageInKm(cache.vehicle)
            local mileage = false
            
            if mileageKm then
                mileage = math.floor(
                    (UserSettingsData and UserSettingsData.speedMeasurement == "mph") 
                        and Framework.Client.ConvertKmToMiles(mileageKm) 
                        or mileageKm
                )
            end
            
            -- Check train doors
            local doorsOpen = false
            if vehicleType == "train" then
                local doorCount = GetTrainDoorCount(cache.vehicle)
                for i = 0, doorCount - 1 do
                    if GetTrainDoorOpenRatio(cache.vehicle, i) > 0.1 then
                        doorsOpen = true
                        break
                    end
                end
            end
            
            -- Check if metro train (specific model)
            local isMetroTrain = (vehicleType ~= "train") or (GetEntityModel(cache.vehicle) == 868868440)
            
            SendVehicleStatusUpdate({
                engineOn = engineOn,
                headlights = headlights,
                highBeams = highBeams,
                anchored = IsBoatAnchored(cache.vehicle),
                engineHealth = engineHealth,
                fuel = fuel,
                indicators = GetIndicatingState(cache.vehicle),
                gear = isAircraft,
                isMetroTrain = isMetroTrain,
                doorsOpen = doorsOpen,
                cruiseControl = IsCruiseControlEnabled,
                seatbelt = IsSeatbeltOn,
                mileage = mileage or false
            })
            
            Wait(updateInterval)
        end
        
        isStatusThreadRunning = false
    end)
end

-- Handle vehicle change
local function OnVehicleChanged(vehicle)
    if not vehicle or vehicle == 0 then
        OnExitedVehicle()
        return
    end
    
    -- Start status thread
    CreateVehicleStatusThread(vehicle)
    Wait(100)
    
    -- Notify NUI of vehicle entry
    OnEnteredVehicle(vehicle)
    
    -- Start telemetry thread
    CreateVehicleTelemetryThread(vehicle)
end

-- Listen for vehicle cache changes
lib.onCache("vehicle", OnVehicleChanged)

-- Check vehicle state on script load
function CheckVehicleOnLoad()
    if cache.vehicle then
        OnVehicleChanged(cache.vehicle)
    end
end