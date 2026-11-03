-- Client-side Radar/Minimap Script
-- Manages minimap positioning, styling, and component visibility

-- Minimap component positions for different styles
-- Format: {x, y, width, height}
local MINIMAP_STYLES = {
    square = {
        minimap = {-0.0045, 0.002, 0.15, 0.188888},
        minimap_mask = {0.0, -0.01, 0.12, 0.2},
        minimap_blur = {-0.0305, 0.04, 0.267, 0.272}
    },
    rounded = {
        minimap = {-0.0045, 0.002, 0.15, 0.188888},
        minimap_mask = {0.0, -0.01, 0.12, 0.2},
        minimap_blur = {-0.0305, 0.04, 0.267, 0.272}
    },
    circular = {
        minimap = {-0.008, 0.005, 0.12, 0.202},
        minimap_mask = {0.0, 0.0, 0.111, 0.2},
        minimap_blur = {-0.021, 0.04, 0.192, 0.272}
    }
}

-- Check if game resolution differs from NUI resolution (windowed mode detection)
local function IsWindowedMode()
    local nuiWidth, nuiHeight = GetNUIScreenResolution()
    local gameWidth, gameHeight = GetActiveScreenResolution()
    return nuiWidth ~= gameWidth or nuiHeight ~= gameHeight
end

-- Calculate position offsets based on resolution and aspect ratio
-- Returns: xOffset, yOffset
local function GetResolutionOffsets(ignoreAspectRatioLimit)
    local screenWidth, screenHeight = GetNUIScreenResolution()
    
    local xOffset = 0.0
    local yOffset = -0.05
    
    -- Adjust for ultra-wide aspect ratios
    if ignoreAspectRatioLimit then
        local aspectRatio = GetNUIAspectRatio()
        local standardAspectRatio = 1.7777777777777777  -- 16:9
        
        if aspectRatio > standardAspectRatio then
            xOffset = (standardAspectRatio - aspectRatio) / 3.6
        end
    end
    
    -- Adjust Y offset based on screen height
    if screenHeight < 1400 then yOffset = -0.06 end
    if screenHeight < 1240 then yOffset = -0.07 end
    if screenHeight < 1050 then yOffset = -0.09 end
    if screenHeight < 950 then yOffset = -0.09 end
    if screenHeight < 850 then yOffset = -0.1 end
    if screenHeight < 750 then yOffset = -0.11 end
    if screenHeight < 650 then yOffset = -0.14 end
    
    return xOffset, yOffset
end

-- Calculate adjusted position with custom offsets
-- Returns: adjustedX, adjustedY, scale
local function CalculateAdjustedPosition(baseX, baseY, baseWidth, baseHeight, offsetX, offsetY, customWidth, customHeight, ignoreAspectRatioLimit)
    local scale = 1.0
    local xOffset, yOffset = GetResolutionOffsets(ignoreAspectRatioLimit)
    
    local screenWidth, screenHeight = GetNUIScreenResolution()
    local aspectRatio = GetNUIAspectRatio()
    local standardAspectRatio = 1.7777777777777777  -- 16:9
    
    -- Calculate uniform scale from custom dimensions
    if customWidth and customWidth > 0 then
        scale = customWidth / baseWidth
    elseif customHeight and customHeight > 0 then
        scale = customHeight / baseHeight
    end
    
    -- Adjust X position for custom offset
    if offsetX then
        local adjustedOffsetX = (offsetX / screenWidth) * (aspectRatio / standardAspectRatio)
        xOffset = xOffset + adjustedOffsetX
    end
    
    -- Adjust Y position for custom offset and height difference
    if offsetY then
        local targetHeight = customHeight or (baseHeight * scale)
        local heightDiff = targetHeight - baseHeight
        local adjustedOffsetY = (offsetY + heightDiff) / screenHeight
        yOffset = yOffset + adjustedOffsetY
    end
    
    return xOffset, yOffset, scale
end

-- Calculate default minimap bounds (used for positioning calculation)
-- Returns: left, top, width, height
local function GetDefaultMinimapBounds(ignoreAspectRatioLimit)
    local xOffset, yOffset = GetResolutionOffsets(ignoreAspectRatioLimit)
    local safeZone = GetSafeZoneSize()
    
    -- Set alignment to bottom-left
    SetScriptGfxAlign(string.byte("L"), string.byte("B"))
    
    local aspectRatio = GetNUIAspectRatio()
    local standardAspectRatio = 1.7777777777777777  -- 16:9
    
    -- Get aligned positions
    local baseX, baseY = GetScriptGfxPosition(0.0, -0.186888)
    local adjustedX, adjustedY = GetScriptGfxPosition(
        0.0 + (xOffset / (aspectRatio / standardAspectRatio)),
        -0.186888 + yOffset
    )
    
    ResetScriptGfxAlign()
    
    local gameWidth, gameHeight = GetActiveScreenResolution()
    local nuiWidth, nuiHeight = GetNUIScreenResolution()
    
    -- Cap aspect ratio for calculations
    if aspectRatio > 2 then
        aspectRatio = 1.7777777777777777
    end
    
    local left = nuiWidth * adjustedX
    local top = nuiHeight * adjustedY
    
    -- Adjust for windowed mode
    if IsWindowedMode() then
        local windowedOffset = ((1920 * gameHeight / 1080) - gameWidth) / 2
        left = left + windowedOffset
        nuiWidth = gameWidth * (nuiHeight / gameHeight)
    end
    
    -- Calculate width with aspect ratio correction
    local width = (1.0 / nuiWidth) * (nuiWidth / (4 * aspectRatio))
    
    -- Apply aspect ratio scaling factor
    local scaleFactor = 1
    if aspectRatio > 2 then
        scaleFactor = 0.76
    elseif aspectRatio > 1.8 then
        scaleFactor = 0.995
    end
    width = width * scaleFactor
    
    -- Apply safe zone adjustment
    width = width * ((nuiWidth * (1 / safeZone)) - (nuiWidth * baseX * 2))
    
    local height = nuiHeight / 5.5
    
    return left, top, width, height
end

-- Set radar mask texture and position all minimap components
-- Returns: left, top, width, height (final bounds)
function SetRadarMaskAndPos(style, offsetX, offsetY, customWidth, customHeight, ignoreAspectRatioLimit, showNorthBlip)
    local left, top, width, height = GetDefaultMinimapBounds(ignoreAspectRatioLimit)
    
    -- Load custom radar mask textures
    lib.requestStreamedTextureDict("jgradar")
    
    -- Select mask texture based on style
    local maskTexture
    if style == "circular" then
        maskTexture = "radarmasksm-circular"
    elseif style == "square" then
        maskTexture = "radarmasksm-square"
    else
        maskTexture = "radarmasksm-rounded"
    end
    
    -- Replace default radar mask textures
    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "jgradar", maskTexture)
    AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "jgradar", maskTexture)
    SetStreamedTextureDictAsNoLongerNeeded("jgradar")
    
    -- Adjust position for windowed mode
    if IsWindowedMode() then
        local safeZone = GetSafeZoneSize()
        left = (1920 * (1 - safeZone)) / 2
    end
    
    -- Calculate adjusted position with custom offsets
    local adjustedX, adjustedY, scale = CalculateAdjustedPosition(
        left, top, width, height,
        offsetX, offsetY,
        customWidth, customHeight,
        ignoreAspectRatioLimit
    )
    
    -- Position all minimap components
    local components = MINIMAP_STYLES[style]
    for componentName, dimensions in pairs(components) do
        SetMinimapComponentPosition(
            componentName,
            "L", "B",
            (dimensions[1] * scale) + adjustedX,
            (dimensions[2] * scale) + adjustedY,
            dimensions[3] * scale,
            dimensions[4] * scale
        )
    end
    
    -- Show/hide north blip
    local northBlip = GetNorthRadarBlip()
    SetBlipAlpha(northBlip, showNorthBlip and 255 or 0)
    
    -- Set minimap clip type (circular vs rectangular)
    SetMinimapClipType(style == "circular" and 1 or 0)
    
    -- Force minimap refresh
    SetBigmapActive(true, false)
    Wait(1)
    SetBigmapActive(false, false)
    
    return left, top, width, height
end

-- Thread management
local radarThreadActive = false

-- Create thread to conditionally display radar
function CreateRadarThread()
    if radarThreadActive then
        return
    end
    
    radarThreadActive = true
    
    CreateThread(function()
        while IsHudRunning do
            DisplayRadarConditionally()
            Wait(2000)
        end
        radarThreadActive = false
    end)
end

-- Hide base game HUD components
local hideHudThreadActive = false

function CreateHideHudComponentsThread()
    if not Config or not Config.HideBaseGameHudComponents then
        return
    end
    
    if hideHudThreadActive then
        return
    end
    
    hideHudThreadActive = true
    
    CreateThread(function()
        while IsHudRunning do
            -- Hide each specified HUD component
            for _, componentId in ipairs(Config.HideBaseGameHudComponents or {}) do
                HideHudComponentThisFrame(componentId)
            end
            Wait(1)
        end
        hideHudThreadActive = false
    end)
end