-- Client-side Train/Metro Station Tracking Script
-- Tracks player's location on train/metro and displays next station information

local STATION_PROXIMITY_THRESHOLD = 50.0  -- Distance to be considered "at station"
local lastKnownStation = nil
local lastKnownDirection = nil
local trainThreadActive = false

-- Calculate distance between two coordinates
-- Returns: rounded distance in meters
local function CalculateDistance(coord1, coord2)
    local vec1 = vector3(coord1.x, coord1.y, coord1.z)
    local vec2 = vector3(coord2.x, coord2.y, coord2.z)
    local distance = #(vec1 - vec2)
    return math.round(distance)
end

-- Calculate heading/bearing from one coordinate to another
-- Returns: heading in degrees (0-360)
local function CalculateHeading(from, to)
    local angle = math.deg(math.atan(to.y - from.y, to.x - from.x))
    return (angle + 360) % 360
end

-- Find the nearest station to given coordinates
-- Returns: stationKey, distance
local function FindNearestStation(coords)
    local nearestStation = nil
    local shortestDistance = math.huge
    
    for stationKey, stationData in pairs(Config.TrainMetroStations) do
        local distance = CalculateDistance(coords, stationData.coords)
        
        if distance < shortestDistance then
            nearestStation = stationKey
            shortestDistance = distance
        end
    end
    
    return nearestStation, shortestDistance
end

-- Check if train is facing in the direction of the station
-- Returns: boolean (true if heading matches within 90 degrees)
local function IsHeadingTowardsStation(trainHeading, stationHeading)
    local angleDiff = math.abs(((trainHeading - stationHeading + 180) % 360) - 180)
    return angleDiff <= 90
end

-- Get current train/metro station information
-- Returns: table with station data or false
local function GetTrainStationData(vehicle)
    local vehicleCoords = GetEntityCoords(vehicle)
    local vehicleHeading = GetEntityHeading(vehicle)
    
    local nearestStation, distanceToStation = FindNearestStation(vehicleCoords)
    
    -- Check if at a station (within proximity threshold)
    if distanceToStation <= STATION_PROXIMITY_THRESHOLD then
        local stationData = Config.TrainMetroStations[nearestStation]
        local northboundData = stationData.nextStation.Northbound
        local southboundData = stationData.nextStation.Southbound
        
        -- Determine direction based on heading
        if northboundData.s then
            if IsHeadingTowardsStation(vehicleHeading, northboundData.h) then
                lastKnownStation = nearestStation
                lastKnownDirection = "Northbound"
            end
        elseif southboundData.s then
            if IsHeadingTowardsStation(vehicleHeading, southboundData.h) then
                lastKnownStation = nearestStation
                lastKnownDirection = "Southbound"
            end
        end
        
        -- Return current station data
        return {
            atStation = true,
            currentStation = stationData.name,
            nextStation = "",
            stationDistance = 0,
            stationHeading = 0
        }
    else
        -- Between stations - use last known station and direction
        if lastKnownStation and lastKnownDirection then
            local lastStation = Config.TrainMetroStations[lastKnownStation]
            local nextStationKey = lastStation.nextStation[lastKnownDirection].s
            
            if nextStationKey then
                local nextStation = Config.TrainMetroStations[nextStationKey]
                local distanceToNext = CalculateDistance(vehicleCoords, nextStation.coords)
                local headingToNext = CalculateHeading(vehicleCoords, nextStation.coords)
                
                return {
                    atStation = false,
                    nextStation = nextStation.name,
                    stationDistance = Framework.Client.ConvertDistance(
                        distanceToNext,
                        UserSettingsData and UserSettingsData.distanceMeasurement
                    ),
                    stationHeading = headingToNext
                }
            end
        else
            return false
        end
    end
end

-- Create thread to track train station data
local function CreateTrainTrackingThread(vehicle)
    if trainThreadActive then
        return
    end
    
    trainThreadActive = true
    
    CreateThread(function()
        while cache.vehicle and IsHudRunning do
            -- Send station data to UI
            SendNUIMessage({
                type = "trainMetroData",
                trainMetroData = GetTrainStationData(vehicle)
            })
            
            Wait(1000)
        end
        
        trainThreadActive = false
    end)
end

-- Check if player is in a metro train and start tracking
local function CheckAndTrackMetroTrain(vehicle)
    if not vehicle then
        return
    end
    
    -- Check if vehicle is a train
    if GetVehicleType(vehicle) ~= "train" then
        return
    end
    
    -- Check if it's a metro train (model hash: 868868440)
    local vehicleModel = GetEntityModel(vehicle)
    if vehicleModel ~= 868868440 then
        return
    end
    
    -- Start tracking thread
    CreateTrainTrackingThread(vehicle)
end

-- Listen for vehicle changes
lib.onCache("vehicle", CheckAndTrackMetroTrain)

-- Check train on initial load
function CheckTrainOnLoad()
    if cache.vehicle then
        CheckAndTrackMetroTrain(cache.vehicle)
    end
end