local MAP_SCALE = 5.333333333333333

local mainMapScaleform = nil
local minimapScaleform = nil
local bigmapForced = false
local requestedDictionaries = {}
local boundaryBlips = {}
local isStopping = false

function ClearMapTiles()
    if mainMapScaleform and HasScaleformMovieLoaded(mainMapScaleform) then
        BeginScaleformMovieMethod(mainMapScaleform, 'CLEAR_TEXTURES')
        EndScaleformMovieMethod()
    end
end

function CreateBoundaryBlip(x, y)
    local blip = AddBlipForCoord(x, y, 0.0)
    SetBlipSprite(blip, 575)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.0)
    SetBlipAlpha(blip, 255)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Map boundary')
    EndTextCommandSetBlipName(blip)
    boundaryBlips[#boundaryBlips + 1] = blip
end

function DrawMapTile(tile, opacity)
    BeginScaleformMovieMethod(mainMapScaleform, 'DRAW_TEXTURE')
    PushScaleformMovieFunctionParameterString(tile.name)
    PushScaleformMovieFunctionParameterString(tile.dictionary)
    PushScaleformMovieFunctionParameterString(tile.name)
    PushScaleformMovieFunctionParameterFloat(864.0 + tile.x / MAP_SCALE)
    PushScaleformMovieFunctionParameterFloat(1440.0 - tile.y / MAP_SCALE)
    PushScaleformMovieFunctionParameterFloat(tile.width / MAP_SCALE)
    PushScaleformMovieFunctionParameterFloat(tile.height / MAP_SCALE)
    PushScaleformMovieFunctionParameterBool(false)
    PushScaleformMovieFunctionParameterInt(opacity)
    PushScaleformMovieFunctionParameterFloat(0.0)
    EndScaleformMovieMethod()
end

-- Returns false if the resource started stopping while waiting.
function WaitUntil(condition, interval)
    while not isStopping and not condition() do
        Wait(interval)
    end
    return not isStopping
end

function WaitForScaleform(handle)
    return WaitUntil(function()
        return HasScaleformMovieLoaded(handle)
    end, 50)
end

function RequestTileDictionaries()
    for _, tile in ipairs(MapTiles) do
        if not requestedDictionaries[tile.dictionary] then
            requestedDictionaries[tile.dictionary] = true
            RequestStreamedTextureDict(tile.dictionary, false)
        end
    end

    for dictionary in pairs(requestedDictionaries) do
        local loaded = WaitUntil(function()
            return HasStreamedTextureDictLoaded(dictionary)
        end, 50)
        if not loaded then
            return false
        end
    end

    return true
end

function RefreshMinimap()
    if not IsBigmapActive() then
        bigmapForced = true
        SetBigmapActive(true, false)
        Wait(0)
        if not isStopping then
            SetBigmapActive(false, false)
            bigmapForced = false
        end
    end
end

function ExpandPauseMapBounds()
    local padding = math.max(0.0, math.min(5000.0, tonumber(Config.MapBoundaryPadding) or 2500.0))
    CreateBoundaryBlip(MapBounds.maxX + padding, MapBounds.minY - padding)
end

CreateThread(function()
    local opacity = math.floor(math.max(0, math.min(100, tonumber(Config.Opacity) or 100)))
    if not Config.Enabled or opacity == 0 then
        return
    end

    if not RequestTileDictionaries() then
        return
    end

    if not WaitUntil(IsMinimapRendering, 100) then
        return
    end

    mainMapScaleform = RequestScaleformMovie('minimap_main_map')
    if not WaitForScaleform(mainMapScaleform) then
        return
    end

    ClearMapTiles()
    for _, tile in ipairs(MapTiles) do
        DrawMapTile(tile, opacity)
    end

    minimapScaleform = RequestScaleformMovie('minimap')
    if not WaitForScaleform(minimapScaleform) then
        return
    end

    RefreshMinimap()
    if isStopping then
        return
    end

    SetScaleformMovieAsNoLongerNeeded(minimapScaleform)
    minimapScaleform = nil

    if Config.ExpandPauseMap and not isStopping then
        ExpandPauseMapBounds()
    end
end)

AddEventHandler('onResourceStop', function(stoppedResource)
    if stoppedResource ~= GetCurrentResourceName() then
        return
    end

    isStopping = true

    if bigmapForced then
        SetBigmapActive(false, false)
        bigmapForced = false
    end

    ClearMapTiles()

    for _, blip in ipairs(boundaryBlips) do
        RemoveBlip(blip)
    end

    for dictionary in pairs(requestedDictionaries) do
        SetStreamedTextureDictAsNoLongerNeeded(dictionary)
    end

    if mainMapScaleform then
        SetScaleformMovieAsNoLongerNeeded(mainMapScaleform)
    end

    if minimapScaleform then
        SetScaleformMovieAsNoLongerNeeded(minimapScaleform)
    end
end)
