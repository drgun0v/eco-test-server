local switchStates = {}

local ENABLE_VISUAL_MARKERS = false
local SILENT_ON_INITIAL_SYNC = true
local hasFinishedInitialSync = false

local userHasInteracted = false

local lastToggle = 0
local TOGGLE_COOLDOWN_MS = 500

local loadedInteriors = {}
local lastWarmup = {}

local function Notify(title, description, ntype)
    lib.notify({
        title = title or 'MRPD',
        description = description or '',
        type = ntype or 'inform'
    })
end

local function iterRooms()
    return pairs(Config.Rooms)
end

local function getRoomMarkers(room)
    return room.markers or room.Markers or {}
end

local function findPVGById(markerId)
    for _, room in iterRooms() do
        local markers = getRoomMarkers(room)
        for _, marker in pairs(markers) do
            if marker and marker.id == markerId and (marker.type == "PRIVACY_WINDOW_GLASS" or marker.type == nil) then
                return room, marker
            end
        end
    end
    return nil, nil
end

local function getInteriorFast(coords)
    if not coords then return 0 end

    local interior = GetInteriorAtCoords(coords.x, coords.y, coords.z)
    if interior ~= 0 then return interior end

    for _ = 1, 10 do
        Wait(100)
        interior = GetInteriorAtCoords(coords.x, coords.y, coords.z)
        if interior ~= 0 then return interior end
    end

    return 0
end

local function ensureInteriorLoaded(interior)
    if interior == 0 then return end

    PinInteriorInMemory(interior)
    LoadInterior(interior)

    local start = GetGameTimer()
    while not IsInteriorReady(interior) and (GetGameTimer() - start) < 2000 do
        Wait(50)
    end
end

local function warmupInterior(room)
    if not room or not room.roomCoords then return end

    local c = room.roomCoords
    local key = ("%s:%s:%s"):format(tostring(c.x), tostring(c.y), tostring(c.z))
    local now = GetGameTimer()

    if lastWarmup[key] and (now - lastWarmup[key] < 3000) then
        return
    end
    lastWarmup[key] = now

    local interior = GetInteriorAtCoords(c.x, c.y, c.z)
    if interior ~= 0 then
        ensureInteriorLoaded(interior)
    end
end

local isScenarioUIOpen = false

local function SetScenarioUIVisible(state)
    isScenarioUIOpen = state
    SetNuiFocus(state, state)
    SendNUIMessage({ type = 'setVisible', visible = state })
end

local function PushScenarioCards()
    SendNUIMessage({
        type = 'setCards',
        cards = Config.Cards or {}
    })
end

local function openScenarioMenu()
    PushScenarioCards()
    SetScenarioUIVisible(true)
end

CreateThread(function()
    while true do
        if isScenarioUIOpen then
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 322, true)
            DisableControlAction(0, 200, true)
            DisableControlAction(0, 21, true)
            DisableControlAction(0, 22, true)
            Wait(0)
        else
            Wait(250)
        end
    end
end)

RegisterNUICallback('closeUI', function(_, cb)
    SetScenarioUIVisible(false)
    if cb then cb({ ok = true }) end
end)

RegisterNUICallback('requestCards', function(_, cb)
    PushScenarioCards()
    if cb then cb({ ok = true }) end
end)

RegisterNUICallback('selectCard', function(data, cb)
    local id = data and data.id
    if id then
        TriggerServerEvent('tstudio_mrpd_scenarios:cardSelected', { id = id })
    end
    SetScenarioUIVisible(false)
    if cb then cb({ ok = true }) end
end)

RegisterNetEvent('tstudio_mrpd_scenarios:openUI', function()
    if not isScenarioUIOpen then
        openScenarioMenu()
    end
end)

local function openPVGSwitchMenu(marker)
    local isOn = switchStates[marker.id] == true
    local switchState = isOn and "ON" or "OFF"
    local nextState = isOn and "OFF" or "ON"

    lib.registerContext({
        id = 'mrpd_pvg_' .. marker.id,
        title = marker.name or marker.id,
        options = {
            {
                title = ('Toggle (%s → %s)'):format(switchState, nextState),
                description = 'Enable or disable associated entity sets.',
                icon = 'toggle-on',
                onSelect = function()
                    local now = GetGameTimer()
                    if now - lastToggle < TOGGLE_COOLDOWN_MS then
                        Notify('PVG', 'Please wait before toggling again.', 'warning')
                        return
                    end
                    lastToggle = now
                    TriggerServerEvent('tstudio_mrpd_scenarios:toggleSwitch', marker.id)
                end
            },
            { title = 'Close', icon = 'xmark', onSelect = function() end }
        }
    })

    lib.showContext('mrpd_pvg_' .. marker.id)
end

function ApplyScenarioEntitySets(scenarioData)
    if not scenarioData then
        Notify('MRPD Scenarios', 'No scenario data received.', 'error')
        return
    end

    local function interiorFromCard(card)
        if not card then return nil end
        if type(card.interior) == "vector3" or type(card.interior) == "table" then
            return card.interior
        end
        for _, room in iterRooms() do
            if room.roomCoords then
                return room.roomCoords
            end
        end
        return nil
    end

    for _, card in ipairs(Config.Cards or {}) do
        if card.entitysets and #card.entitysets > 0 then
            local coords = interiorFromCard(card)
            if coords then
                local interiorID = getInteriorFast(coords)
                if interiorID ~= 0 then
                    ensureInteriorLoaded(interiorID)
                    for _, entitysetName in ipairs(card.entitysets) do
                        DeactivateInteriorEntitySet(interiorID, entitysetName)
                    end
                    RefreshInterior(interiorID)
                end
            end
        end
    end

    if scenarioData.entitysets and #scenarioData.entitysets > 0 then
        local coords = interiorFromCard(scenarioData)
        if coords then
            local interiorID = getInteriorFast(coords)
            if interiorID ~= 0 then
                ensureInteriorLoaded(interiorID)
                for _, entitysetName in ipairs(scenarioData.entitysets) do
                    ActivateInteriorEntitySet(interiorID, entitysetName)
                end
                RefreshInterior(interiorID)
            else
                Notify('MRPD Scenarios', 'Interior not found.', 'warning')
            end
        end
    else
        Notify('MRPD Scenarios', ('No entity set defined for scenario: %s'):format(scenarioData.id or 'unknown'), 'warning')
    end
end

local function ApplyPVGSwitchStateById(markerId, state)
    local room, marker = findPVGById(markerId)
    if not room or not marker then return end

    local ped = PlayerPedId()
    local interior = 0

    if marker.coords then
        interior = getInteriorFast(marker.coords)
    end
    if interior == 0 then
        interior = GetInteriorFromEntity(ped)
    end
    if interior == 0 and room.roomCoords then
        interior = getInteriorFast(room.roomCoords)
    end
    if interior == 0 then
        if room then warmupInterior(room) end
        return
    end

    UnpinInterior(interior)
    Wait(0)
    PinInteriorInMemory(interior)
    LoadInterior(interior)

    local start = GetGameTimer()
    while not IsInteriorReady(interior) and (GetGameTimer() - start) < 3000 do
        Wait(50)
    end

    if state then
        for _, setName in ipairs(marker.entitySetsOn or {}) do
            ActivateInteriorEntitySet(interior, setName)
        end
        for _, setName in ipairs(marker.entitySetsOff or {}) do
            DeactivateInteriorEntitySet(interior, setName)
        end
    else
        for _, setName in ipairs(marker.entitySetsOff or {}) do
            ActivateInteriorEntitySet(interior, setName)
        end
        for _, setName in ipairs(marker.entitySetsOn or {}) do
            DeactivateInteriorEntitySet(interior, setName)
        end
    end

    RefreshInterior(interior)
    Wait(0)
    RefreshInterior(interior)
    Wait(50)
    RefreshInterior(interior)
end

RegisterNetEvent('tstudio_mrpd_scenarios:syncSwitchState', function(markerId, state)
    switchStates[markerId] = state
    ApplyPVGSwitchStateById(markerId, state)

    if userHasInteracted then
        Notify('PVG', ('%s is now %s'):format(markerId, state and 'ON' or 'OFF'), 'success')
    end
end)

RegisterNetEvent('tstudio_mrpd_scenarios:syncScenario', function(scenarioData)
    ApplyScenarioEntitySets(scenarioData)

    if userHasInteracted and scenarioData and scenarioData.id then
        Notify('MRPD Scenarios', ('Scenario applied: %s'):format(scenarioData.id), 'success')
    end
end)

local function registerOxTargetZones()
    if Config.UIBlip and Config.UIBlip.coords then
        exports.ox_target:addSphereZone({
            coords = Config.UIBlip.coords,
            radius = (Config.UIBlip.interactDist or 1.5),
            debug = false,
            options = {
                {
                    name = 'mrpd_scenarios_open',
                    label = 'Open scenarios',
                    icon = 'fa-solid fa-list',
                    canInteract = function()
                        return true
                    end,
                    onSelect = function()
                        userHasInteracted = true
                        openScenarioMenu()
                    end
                }
            }
        })
    end

    for _, room in iterRooms() do
        local markers = getRoomMarkers(room)
        for _, marker in pairs(markers) do
            if marker and marker.coords and marker.id and (marker.type == "PRIVACY_WINDOW_GLASS" or marker.type == nil) then
                exports.ox_target:addSphereZone({
                    coords = marker.coords,
                    radius = (Config.MarkerSettings and Config.MarkerSettings.interactionDistance) or 1.0,
                    debug = false,
                    options = {
                        {
                            name = ('pvg_%s'):format(marker.id),
                            label = (marker.name or marker.id),
                            icon = 'fa-solid fa-toggle-on',
                            canInteract = function()
                                warmupInterior(room)
                                return true
                            end,
                            onSelect = function()
                                userHasInteracted = true
                                openPVGSwitchMenu(marker)
                            end
                        }
                    }
                })
            end
        end
    end
end

CreateThread(function()
    for _, room in iterRooms() do
        if room.ipl then
            RequestIpl(room.ipl)
        end

        local markers = getRoomMarkers(room)
        for _, marker in pairs(markers) do
            if marker and marker.id then
                switchStates[marker.id] = false
            end
        end
    end

    registerOxTargetZones()

    Wait(300)
    TriggerServerEvent('tstudio_mrpd_scenarios:requestSyncStates')

    Wait(1200)
    hasFinishedInitialSync = true
end)

if ENABLE_VISUAL_MARKERS then
    CreateThread(function()
        while true do
            local sleep = 750
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)

            for _, room in iterRooms() do
                local markers = getRoomMarkers(room)
                for _, marker in pairs(markers) do
                    if marker and marker.coords then
                        local distance = #(coords - marker.coords)
                        if Config.MarkerSettings and distance < (Config.MarkerSettings.drawDistance or 10.0) then
                            sleep = 0
                            DrawMarker(
                                Config.MarkerSettings.type or 1,
                                marker.coords.x, marker.coords.y, marker.coords.z,
                                0.0, 0.0, 0.0,
                                0.0, 0.0, 0.0,
                                (Config.MarkerSettings.scale and Config.MarkerSettings.scale.x) or 0.25,
                                (Config.MarkerSettings.scale and Config.MarkerSettings.scale.y) or 0.25,
                                (Config.MarkerSettings.scale and Config.MarkerSettings.scale.z) or 0.25,
                                (marker.color and marker.color.r) or 255,
                                (marker.color and marker.color.g) or 255,
                                (marker.color and marker.color.b) or 255,
                                (marker.color and marker.color.a) or 120,
                                false, true, 2, false, nil, nil, false
                            )
                        end
                    end
                end
            end

            if Config.UIBlip and Config.UIBlip.coords then
                local dist = #(coords - Config.UIBlip.coords)
                if dist < (Config.UIBlip.drawDistance or 25.0) then
                    sleep = 0
                    DrawMarker(
                        Config.UIBlip.markerType or (Config.MarkerSettings and Config.MarkerSettings.type) or 1,
                        Config.UIBlip.coords.x, Config.UIBlip.coords.y, Config.UIBlip.coords.z,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        (Config.UIBlip.markerScale and Config.UIBlip.markerScale.x) or 0.25,
                        (Config.UIBlip.markerScale and Config.UIBlip.markerScale.y) or 0.25,
                        (Config.UIBlip.markerScale and Config.UIBlip.markerScale.z) or 0.25,
                        (Config.UIBlip.markerColor and Config.UIBlip.markerColor.r) or 255,
                        (Config.UIBlip.markerColor and Config.UIBlip.markerColor.g) or 255,
                        (Config.UIBlip.markerColor and Config.UIBlip.markerColor.b) or 255,
                        (Config.UIBlip.markerColor and Config.UIBlip.markerColor.a) or 120,
                        false, true, 2, false, nil, nil, false
                    )
                end
            end

            Wait(sleep)
        end
    end)
end
