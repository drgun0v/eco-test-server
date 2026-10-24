-- Client-side HUD Settings Script
-- Manages player HUD layout and settings with persistence

IsSettingsOpen = false
local performanceMode = nil

-- Load all HUD settings from file and KVP storage
function GetAllHudSettings()
    local defaultData = nil
    
    -- Load default settings from resource file
    local fileData = LoadResourceFile(
        GetCurrentResourceName(), 
        Config.DefaultSettingsData
    )
    
    if fileData then
        defaultData = json.decode(fileData)
    else
        print(string.format(
            "Default settings error: Could not find %s file", 
            Config.DefaultSettingsData
        ))
    end
    
    -- Extract layout and settings from default data
    local defaultLayout = nil
    local defaultSettings = nil
    
    if defaultData and type(defaultData) == "table" then
        defaultLayout = defaultData.layout
        defaultSettings = defaultData.settings
    end
    
    -- Dev option: Delete all user settings on start
    if Config.DevDeleteAllUserSettingsOnStart then
        local prefix = Config.DefaultSettingsKvpPrefix or "hud-"
        DeleteResourceKvp(string.format("%slayout", prefix))
        DeleteResourceKvp(string.format("%ssettings", prefix))
    end
    
    -- Load user layout from KVP storage
    local prefix = Config.DefaultSettingsKvpPrefix or "hud-"
    local userLayout = defaultLayout or {}
    local savedLayoutData = json.decode(
        GetResourceKvpString(string.format("%slayout", prefix)) or "{}"
    )
    
    -- Use saved layout if editing is allowed and data exists
    if Config.AllowUsersToEditLayout and next(savedLayoutData) ~= nil then
        userLayout = savedLayoutData
    end
    
    UserLayoutData = userLayout
    
    -- Load user settings from KVP storage
    local userSettings = defaultSettings or {}
    local savedSettingsData = json.decode(
        GetResourceKvpString(string.format("%ssettings", prefix)) or "{}"
    )
    
    -- Use saved settings if editing is allowed and data exists
    if Config.AllowPlayersToEditSettings and next(savedSettingsData) ~= nil then
        userSettings = savedSettingsData
    end
    
    -- Preserve performance mode setting
    if savedSettingsData and savedSettingsData.performanceMode then
        userSettings.performanceMode = savedSettingsData.performanceMode
        performanceMode = savedSettingsData.performanceMode
    end
    
    UserSettingsData = userSettings
    
    return userLayout, userSettings, defaultData
end

-- Register command to open settings menu
RegisterCommand(Config.OpenSettingsCommand or "settings", function()
    ToggleVehicleControl(false)
    DisplayRadar(false)
    TriggerScreenblurFadeIn(500)
    SetNuiFocus(true, true)
    SendNUIMessage({type = "showSettings"})
    IsSettingsOpen = true
end)

-- NUI Callback: Close settings menu
RegisterNUICallback("close-settings", function(data, callback)
    IsSettingsOpen = false
    TriggerScreenblurFadeOut(500)
    SetNuiFocus(false, false)
    DisplayRadarConditionally()
    callback(true)
end)

-- NUI Callback: Save HUD layout
RegisterNUICallback("save-hud-layout", function(layoutData, callback)
    if not IsHudRunning then
        return callback(false)
    end
    
    if not layoutData then
        return callback(false)
    end
    
    -- Get minimap data based on current radar style
    local radarStyle = UserSettingsData and UserSettingsData.radarStyle or "rounded"
    local minimapKey = string.format("%sMinimap", radarStyle)
    local minimapData = layoutData[minimapKey]
    
    -- Apply radar mask and position
    local left, top, width, height = SetRadarMaskAndPos(
        radarStyle,
        minimapData and minimapData.offset and minimapData.offset.offsetX,
        minimapData and minimapData.offset and minimapData.offset.offsetY,
        minimapData and minimapData.dimensions and minimapData.dimensions.width,
        minimapData and minimapData.dimensions and minimapData.dimensions.height,
        UserSettingsData and UserSettingsData.ignoreAspectRatioLimit,
        UserSettingsData and UserSettingsData.showNorthBlip
    )
    
    -- Save layout to KVP storage
    local prefix = Config.DefaultSettingsKvpPrefix or "hud-"
    SetResourceKvp(
        string.format("%slayout", prefix),
        json.encode(layoutData)
    )
    
    UserLayoutData = layoutData
    
    -- Return bounds to UI
    callback({
        bounds = {
            left = left,
            top = top,
            width = width,
            height = height
        }
    })
end)

-- NUI Callback: Save HUD settings
RegisterNUICallback("save-hud-settings", function(settingsData, callback)
    if not IsHudRunning then
        return callback(false)
    end
    
    if not settingsData then
        return callback(false)
    end
    
    -- Check if radar-related settings changed
    local radarChanged = (
        settingsData.radarStyle ~= UserSettingsData.radarStyle or
        settingsData.ignoreAspectRatioLimit ~= UserSettingsData.ignoreAspectRatioLimit or
        settingsData.showNorthBlip ~= UserSettingsData.showNorthBlip
    )
    
    if radarChanged then
        -- Apply new radar settings
        local minimapKey = string.format("%sMinimap", settingsData.radarStyle)
        local minimapData = UserLayoutData[minimapKey]
        
        local left, top, width, height = SetRadarMaskAndPos(
            settingsData.radarStyle or "rounded",
            minimapData and minimapData.offset and minimapData.offset.offsetX,
            minimapData and minimapData.offset and minimapData.offset.offsetY,
            minimapData and minimapData.dimensions and minimapData.dimensions.width,
            minimapData and minimapData.dimensions and minimapData.dimensions.height,
            settingsData.ignoreAspectRatioLimit or false,
            settingsData.showNorthBlip or false
        )
        
        -- Return bounds to UI
        callback({
            bounds = {
                left = left,
                top = top,
                width = width,
                height = height
            }
        })
    end
    
    -- Save settings to KVP storage
    local prefix = Config.DefaultSettingsKvpPrefix or "hud-"
    SetResourceKvp(
        string.format("%ssettings", prefix),
        json.encode(settingsData)
    )
    
    UserSettingsData = settingsData
    
    -- Handle performance mode changes
    if IsHudRunning then
        local newPerformanceMode = settingsData and settingsData.performanceMode
        
        if newPerformanceMode ~= performanceMode then
            performanceMode = newPerformanceMode
            IsHudRunning = false
            Wait(100)
            StartThreads()
            
            -- Hide radar if settings are still open
            if IsSettingsOpen then
                DisplayRadar(false)
            end
        end
    end
    
    callback(false)
end)