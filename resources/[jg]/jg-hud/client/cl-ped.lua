-- JG HUD Client Ped/Player Data Script

-- Native function references for better performance
local GetGameplayCamRot = GetGameplayCamRot
local GetEntityHeading = GetEntityHeading
local GetEntityCoords = GetEntityCoords
local GetStreetNameAtCoord = GetStreetNameAtCoord
local GetStreetNameFromHashKey = GetStreetNameFromHashKey
local GetNameOfZone = GetNameOfZone
local GetLabelText = GetLabelText
local GetEntityHealth = GetEntityHealth
local GetPedArmour = GetPedArmour
local GetPlayerSprintStaminaRemaining = GetPlayerSprintStaminaRemaining
local IsEntityInWater = IsEntityInWater
local GetPlayerUnderwaterTimeRemaining = GetPlayerUnderwaterTimeRemaining
local NetworkIsPlayerTalking = NetworkIsPlayerTalking
local GetClockHours = GetClockHours
local GetClockMinutes = GetClockMinutes
local GetPlayerMaxStamina = GetPlayerMaxStamina

-- Get current time based on user settings (local or in-game)
local function GetCurrentTime()
    local timeMode = UserSettingsData and UserSettingsData.playerInfoTime
    
    if timeMode == "local" then
        local _, _, hours, minutes = GetLocalTime()
        return string.format("%s:%s", 
            string.format("%02d", hours),
            string.format("%02d", minutes)
        )
    end
    
    -- Default to in-game time
    return string.format("%s:%s",
        string.format("%02d", GetClockHours()),
        string.format("%02d", GetClockMinutes())
    )
end

-- Get compass heading (camera or entity based on settings)
local function GetCompassHeading()
    local followCamera = UserSettingsData and UserSettingsData.compassFollowCamera
    
    if followCamera then
        local camRot = GetGameplayCamRot(0)
        return (camRot.z + 360.0) % 360.0
    end
    
    return GetEntityHeading(cache.ped)
end

-- Get custom or default street name
local function GetStreetName(streetHash)
    local customName = Config.CustomStreetNames and Config.CustomStreetNames[streetHash & 0xFFFFFFFF]
    
    if not customName then
        customName = GetStreetNameFromHashKey(streetHash) or "Unknown"
    end
    
    return customName
end

-- Get street names at coordinates
local function GetStreetNamesAtCoords(coords)
    local mainStreet, crossStreet = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    
    if mainStreet == 0 and crossStreet == 0 then
        return false
    end
    
    local mainStreetName = GetStreetName(mainStreet)
    local fullStreetName = mainStreetName
    
    if crossStreet > 0 then
        fullStreetName = string.format("%s / %s", mainStreetName, GetStreetName(crossStreet))
    end
    
    return mainStreetName, fullStreetName
end

-- Get speed limit for a street
local function GetSpeedLimitForStreet(streetName)
    if not streetName then
        return false
    end
    
    if not Config.SpeedLimits or type(Config.SpeedLimits) ~= "table" then
        return false
    end
    
    return Config.SpeedLimits[streetName] or false
end

-- Get cardinal direction from heading
local function GetCardinalDirection()
    local heading = GetCompassHeading()
    
    local directions = {
        "N",   -- North
        "NW",  -- Northwest
        "W",   -- West
        "SW",  -- Southwest
        "S",   -- South
        "SE",  -- Southeast
        "E",   -- East
        "NE"   -- Northeast
    }
    
    local index = math.floor((heading + 22.5) / 45) + 1
    if index > 8 then
        index = 1
    end
    
    return directions[index], heading
end

-- Get custom or default zone name
local function GetZoneName(zoneName)
    local customName = Config.CustomZoneNames and Config.CustomZoneNames[zoneName]
    
    if not customName then
        customName = GetLabelText(zoneName)
    end
    
    return customName
end

-- Get zone/area name at coordinates
local function GetZoneAtCoords(coords)
    local zoneName = GetNameOfZone(coords.x, coords.y, coords.z)
    local displayName = GetZoneName(zoneName)
    
    -- Return original zone name if display name is invalid
    if displayName == "NULL" or not displayName then
        return zoneName
    end
    
    return displayName or zoneName
end

-- Generate ped mugshot/headshot
function GeneratePedHeadshot()
    if not Config.ShowComponents.pedAvatar then
        return false
    end
    
    -- Wait for ped to exist
    lib.waitFor(function()
        return cache.ped and DoesEntityExist(cache.ped)
    end, nil, 5000)
    
    -- Register headshot
    local headshotHandle = RegisterPedheadshot(cache.ped)
    
    -- Wait for headshot to be ready
    lib.waitFor(function()
        return IsPedheadshotReady(headshotHandle) and IsPedheadshotValid(headshotHandle)
    end, "Could not load ped headshot", 5000)
    
    -- Get texture string
    local txdString = GetPedheadshotTxdString(headshotHandle)
    local mugshotUrl = string.format("https://nui-img/%s/%s", txdString, txdString)
    
    -- Cleanup
    UnregisterPedheadshot(headshotHandle)
    
    return mugshotUrl
end

-- Get update interval based on performance mode
local function GetUpdateInterval()
    local perfMode = UserSettingsData and UserSettingsData.performanceMode
    
    if perfMode == "ultra" then
        return 50
    elseif perfMode == "performance" then
        return 250
    elseif perfMode == "lowResmon" then
        return 1000
    end
    
    return 500  -- Default
end

-- Talking indicator thread state
local isTalkingThreadRunning = false

-- Create thread to monitor player talking state
function CreateIsTalkingThread()
    if isTalkingThreadRunning then
        return
    end
    
    isTalkingThreadRunning = true
    
    CreateThread(function()
        while IsHudRunning do
            SendNUIMessage({
                type = "isTalking",
                isTalking = NetworkIsPlayerTalking(cache.playerId)
            })
            
            Wait(200)
        end
        
        isTalkingThreadRunning = false
    end)
end

-- Player data thread state
local isPlayerThreadRunning = false
local updateInterval = 100
local isPlayerDead = false
local deathCheckCounter = 0

-- Create main player data update thread
function CreatePlayerThread()
    if isPlayerThreadRunning then
        return
    end
    
    isPlayerThreadRunning = true
    
    -- Setup framework event listeners
    Framework.Client.CreateEventListeners()
    
    -- Get performance-based update interval
    updateInterval = GetUpdateInterval()
    
    CreateThread(function()
        while IsHudRunning do
            if not cache.ped then
                break
            end
            
            -- Check player death status every 5 iterations
            if deathCheckCounter == 0 then
                isPlayerDead = Framework.Client.IsPlayerDead()
                deathCheckCounter = 5
            else
                deathCheckCounter = deathCheckCounter - 1
            end
            
            -- Calculate health
            local health = isPlayerDead and 0 or (GetEntityHealth(cache.ped) - 100)
            
            -- Get armour
            local armour = GetPedArmour(cache.ped)
            
            -- Calculate oxygen/stamina
            local oxygen = 100
            
            if isPlayerDead then
                oxygen = 0
            elseif IsEntityInWater(cache.ped) then
                if IsPedSwimmingUnderWater(cache.ped) then
                    -- Underwater oxygen
                    oxygen = GetPlayerUnderwaterTimeRemaining(cache.playerId) * 10
                else
                    -- Swimming stamina
                    oxygen = GetPlayerStamina(cache.playerId)
                end
            elseif not cache.vehicle then
                -- Sprint stamina when on foot
                local stamina = math.max(0, GetPlayerSprintStaminaRemaining(cache.playerId))
                local maxStamina = GetPlayerMaxStamina(cache.playerId)
                oxygen = (1 - (stamina / maxStamina)) * 100
            end
            
            -- Get time
            local currentTime = GetCurrentTime()
            
            -- Get position and location data
            local coords = GetEntityCoords(cache.ped)
            local cardinalDir, heading = GetCardinalDirection()
            local mainStreet, fullStreet = GetStreetNamesAtCoords(coords)
            local areaName = GetZoneAtCoords(coords)
            
            -- Send all player data to NUI
            SendNUIMessage({
                type = "pedData",
                pedData = {
                    -- Stats
                    health = health,
                    armour = armour,
                    food = Framework.CachedPlayerData.hunger or false,
                    water = Framework.CachedPlayerData.thirst or false,
                    oxygen = oxygen or false,
                    stress = Framework.CachedPlayerData.stress or false,
                    
                    -- Job/Gang
                    job = Framework.CachedPlayerData.job,
                    gang = Framework.CachedPlayerData.gang,
                    
                    -- Time and ID
                    time = currentTime,
                    playerId = cache.serverId,
                    
                    -- Money
                    cash = Framework.CachedPlayerData.cash,
                    bank = Framework.CachedPlayerData.bank,
                    dirtyMoney = Framework.CachedPlayerData.dirtyMoney,
                    
                    -- Voice/Radio
                    micRange = Framework.CachedPlayerData.micRange,
                    radioActive = Framework.CachedPlayerData.radioActive,
                    radioChannel = LocalPlayer.state.radioChannel or 0,
                    voiceModes = Framework.CachedPlayerData.voiceModes,
                    
                    -- Location
                    cardinalDirection = cardinalDir,
                    heading = heading,
                    streetName = fullStreet or areaName,
                    areaName = areaName,
                    nearestPostal = GetNearestPostal(coords),
                    speedLimit = GetSpeedLimitForStreet(mainStreet)
                }
            })
            
            Wait(updateInterval)
        end
        
        isPlayerThreadRunning = false
    end)
end