-- JG HUD Client Main Script
-- Locale setup
Locale = Locales[Config.Locale or "en"]

-- Global state variables
local isNuiReady = false
local nuiScreenResolution = {}
local isPauseMenuThreadRunning = false
IsHudRunning = false
IsHudVisible = true
UserSettingsData = {}
UserLayoutData = {}

-- Debug print helper
function DebugPrint(message)
    if Config.Debug then
        print(("[JG HUD Debug]: %s"):format(message))
    end
end

-- Get vehicle type (sea, air, train, bicycle, land)
function GetVehicleType(vehicle)
    if not DoesEntityExist(vehicle) or not IsEntityAVehicle(vehicle) then
        return nil
    end
    
    local model = GetEntityModel(vehicle)
    
    if IsThisModelABoat(model) or IsThisModelAJetski(model) then
        return "sea"
    elseif IsThisModelAHeli(model) or IsThisModelAPlane(model) then
        return "air"
    elseif IsThisModelATrain(model) then
        return "train"
    elseif IsThisModelABicycle(model) then
        return "bicycle"
    else
        return "land"
    end
end

-- Check if vehicle is electric
function IsVehicleElectric(vehicle)
    local buildNumber = GetGameBuildNumber()
    
    if buildNumber >= 3258 then
        -- Use native for newer game versions
        return Citizen.InvokeNative(0x1FDE91D481B33EF9, GetEntityModel(vehicle)) == 1
    end
    
    -- Fallback to config list for older versions
    return lib.table.contains(Config.ElectricVehicles, GetEntityArchetypeName(vehicle))
end

-- Display radar conditionally based on settings and player state
function DisplayRadarConditionally()
    local shouldShow = IsHudVisible and 
                      (not Config.ShowMinimapOnFoot or 
                       (UserSettingsData and UserSettingsData.showMinimapOnFoot) or 
                       cache.vehicle)
    
    DisplayRadar(shouldShow)
    SetBigmapActive(false, false)
    
    if Config.UpdateRadarZoom then
        SetRadarZoom(1100)
    end
    
    return shouldShow
end

-- Get NUI screen resolution
function GetNUIScreenResolution()
    if nuiScreenResolution and nuiScreenResolution.width and nuiScreenResolution.height then
        return nuiScreenResolution.width, nuiScreenResolution.height
    end
    return GetActualScreenResolution()
end

-- Get NUI aspect ratio
function GetNUIAspectRatio()
    if nuiScreenResolution and nuiScreenResolution.width and nuiScreenResolution.height then
        return nuiScreenResolution.width / nuiScreenResolution.height
    end
    return GetAspectRatio(false)
end

-- Toggle HUD visibility
local function ToggleHudVisibility(visible)
    IsHudVisible = visible
    
    if not visible then
        SetMinimapClipType(0)
        DisplayRadar(false)
        SendNUIMessage({ type = "hideHud" })
    else
        local clipType = (UserSettingsData and UserSettingsData.radarStyle == "circular") and 1 or 0
        SetMinimapClipType(clipType)
        DisplayRadarConditionally()
        SendNUIMessage({ type = "showHud" })
    end
end

-- Monitor pause menu state
local function CreateHideHudComponentsThread()
    if isPauseMenuThreadRunning then
        return
    end
    
    isPauseMenuThreadRunning = true
    local wasPauseMenuActive = IsPauseMenuActive()
    
    CreateThread(function()
        while IsHudRunning do
            Wait(1000)
            
            local isPauseMenuActive = IsPauseMenuActive()
            if wasPauseMenuActive ~= isPauseMenuActive then
                wasPauseMenuActive = isPauseMenuActive
                ToggleHudVisibility(not isPauseMenuActive)
            end
        end
        
        isPauseMenuThreadRunning = false
    end)
end

-- Apply radar settings
local function ApplyRadarSettings(layoutData, settingsData)
    local radarStyle = (settingsData and settingsData.radarStyle) or "rounded"
    
    local minimapData = nil
    if layoutData then
        local minimapKey = ("%sMinimap"):format((settingsData and settingsData.radarStyle) or "rounded")
        minimapData = layoutData[minimapKey]
    end
    
    local offsetX = minimapData and minimapData.offset and minimapData.offset.offsetX
    local offsetY = minimapData and minimapData.offset and minimapData.offset.offsetY
    local width = minimapData and minimapData.dimensions and minimapData.dimensions.width
    local height = minimapData and minimapData.dimensions and minimapData.dimensions.height
    local ignoreAspect = settingsData and settingsData.ignoreAspectRatioLimit
    local showNorthBlip = settingsData and settingsData.showNorthBlip
    
    local left, top, resultWidth, resultHeight = SetRadarMaskAndPos(
        radarStyle, 
        offsetX, 
        offsetY, 
        width, 
        height, 
        ignoreAspect, 
        showNorthBlip
    )
    
    DisplayRadarConditionally()
    
    return left, top, resultWidth, resultHeight
end

-- Start all HUD threads
function StartThreads()
    if IsHudRunning then
        return
    end
    
    IsHudRunning = true
    
    CreateRadarThread()
    CreateHideHudComponentsThread()
    CreateIsTalkingThread()
    CreatePlayerThread()
    CheckWeaponOnLoad()
    CheckVehicleOnLoad()
    CheckTrainOnLoad()
end

-- Initialize HUD
local isInitializing = false

local function InitializeHud()
    if IsHudRunning or isInitializing then
        return
    end
    
    isInitializing = true
    
    -- Wait for NUI and player to be ready
    lib.waitFor(function()
        return cache.ped and isNuiReady
    end, "NUI wasn't ready or ped wasn't available; JG HUD has aborted initialisation!", 1000000)
    
    -- Load settings
    local layoutData, settingsData, defaultSettings = GetAllHudSettings()
    DebugPrint("1. Settings loaded")
    
    -- Apply radar settings
    local left, top, width, height = ApplyRadarSettings(layoutData, settingsData)
    DebugPrint("2. Minimap/radar loaded")
    
    -- Generate player mugshot
    local mugshot = GeneratePedHeadshot()
    DebugPrint("3. Ped headshot loaded/skipped successfully")
    
    -- Get weapon data
    local weaponData = GetWeaponData()
    DebugPrint("4. Weapon data retrieved/skipped successfully")
    
    -- Send init event to NUI
    DebugPrint("5. Sending initHud NUI event...")
    SendNUIMessage({
        type = "initHud",
        bounds = {
            left = left,
            top = top,
            width = width,
            height = height
        },
        isMinimapShowing = not IsRadarHidden(),
        showMinimapOnFoot = Config.ShowMinimapOnFoot,
        showCompassOnFoot = Config.ShowCompassOnFoot,
        mugshot = mugshot,
        weaponData = weaponData,
        layout = layoutData,
        settings = settingsData,
        defaultAllSettings = defaultSettings,
        showComponents = Config.ShowComponents,
        speedMeasurement = Config.SpeedMeasurement,
        distanceMeasurement = Config.DistanceMeasurement,
        allowLayoutEditing = Config.AllowUsersToEditLayout,
        allowSettingsEditing = Config.AllowPlayersToEditSettings,
        allowServerLogoEditing = Config.AllowServerLogoEditing,
        currency = Config.Currency,
        numberFormat = Config.NumberFormat,
        locale = Locale
    })
    
    DebugPrint("6. Sent initHud NUI event")
    
    Wait(100)
    
    isInitializing = false
    StartThreads()
    
    DebugPrint("7. Started threads")
end

-- Shutdown HUD
local function ShutdownHud()
    if not IsHudRunning then
        return
    end
    
    IsHudRunning = false
    SendNUIMessage({ type = "unmountHud" })
end

-- NUI Callbacks
RegisterNUICallback("get-bounds", function(data, cb)
    DebugPrint(json.encode(data))
    nuiScreenResolution = data
    
    local layoutData, settingsData = GetAllHudSettings()
    local left, top, width, height = ApplyRadarSettings(layoutData, settingsData)
    
    cb({
        left = left,
        top = top,
        width = width,
        height = height
    })
end)

RegisterNUICallback("on-nui-ready", function(data, cb)
    nuiScreenResolution = data
    isNuiReady = true
    
    DebugPrint("NUI ready")
    DebugPrint(json.encode(data))
    
    cb(true)
end)

-- Player login/logout handling
CreateThread(function()
    Framework.Client.SetupPlayerLoginListeners()
    Wait(1000)
    
    if LocalPlayer.state.jgHudPlayerLoggedIn then
        InitializeHud()
    end
    
    AddStateBagChangeHandler(
        "jgHudPlayerLoggedIn",
        ("player:%s"):format(cache.serverId),
        function(bagName, key, value)
            if value then
                InitializeHud()
            else
                ShutdownHud()
            end
        end
    )
end)

-- Toggle HUD command
RegisterCommand(Config.ToggleHudCommand or "togglehud", function()
    ToggleHudVisibility(not IsHudVisible)
end)

-- Export
exports("toggleHud", function(visible)
    ToggleHudVisibility(visible)
end)

-- Network event
RegisterNetEvent("jg-hud:client:toggle-hud", function(visible)
    ToggleHudVisibility(visible)
end)

-- Update game text entries for custom names
if Config.CustomNamesShouldUpdateGameTextEntries then
    -- Custom street names
    for hash, name in pairs(Config.CustomStreetNames) do
        AddTextEntryByHash(hash, name)
    end
    
    -- Custom zone names
    for zoneName, displayName in pairs(Config.CustomZoneNames) do
        AddTextEntryByHash(joaat(zoneName), displayName)
    end
end