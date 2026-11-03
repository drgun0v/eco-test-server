local resourceName = GetCurrentResourceName()
local features = Config.Features

local PATH_NODES_KVP = 'nteam_path_nodes_owned'
local ISLAND_PEDS_GROUP = 'Heist_Island_Peds'

local ARENA_EMITTERS = {
    'se_dlc_aw_arena_construction_01',
    'se_dlc_aw_arena_crowd_background_main',
    'se_dlc_aw_crowd_exterior_lobby',
    'se_dlc_aw_crowd_interior_lobby'
}

local VAULT_ENTITY_SETS = {
    diamond = 'pink_diamond_set',
    panther = 'panther_set',
    necklace = 'pearl_necklace_set'
}

local isRunning = true
local isInitialized = false
local isInsideArea = false
local originalIplStates = {}
local savedEnvironment = nil
local originalIslandPedsState = nil
local vaultInterior = nil
local originalVaultSets = nil
local appliedVaultSelection = nil
local ownsPathNodes = GetResourceKvpInt(PATH_NODES_KVP) == 1

function IsInsideIsland(coords, useExitRadius)
    local deltaX = coords.x - Config.Area.center.x
    local deltaY = coords.y - Config.Area.center.y
    local radius = useExitRadius and Config.Area.exitRadius or Config.Area.enterRadius
    return deltaX * deltaX + deltaY * deltaY < radius * radius
end

function AssertBooleanFeature(name)
    assert(type(features[name]) == 'boolean', 'Expected boolean setting: Features.' .. name)
end

function BuildIplStates()
    local states = {}

    for _, iplName in ipairs(CayoIpls.core) do
        states[iplName] = true
    end

    for featureName, iplList in pairs(CayoIpls.groups) do
        AssertBooleanFeature(featureName)
        for _, iplName in ipairs(iplList) do
            states[iplName] = features[featureName]
        end
    end

    for featureName, options in pairs(CayoIpls.variants) do
        assert(options[features[featureName]], 'Invalid variant: Features.' .. featureName)
        for optionName, iplList in pairs(options) do
            for _, iplName in ipairs(iplList) do
                states[iplName] = features[featureName] == optionName
            end
        end
    end

    for _, entry in ipairs(Config.ExtraIpls) do
        assert(type(entry.name) == 'string', 'Invalid ExtraIpls entry')
        states[entry.name:lower()] = entry.enabled
    end

    for _, iplName in ipairs(Config.UnmanagedIpls) do
        assert(type(iplName) == 'string' and iplName ~= '', 'Invalid UnmanagedIpls entry')
        states[iplName:lower()] = nil
    end

    return states
end

function ValidateConfig()
    local area = Config.Area
    local environment = Config.Environment

    assert(area.enterRadius > 0 and area.exitRadius > area.enterRadius, 'exitRadius must exceed enterRadius')
    assert(area.pollMs >= 100, 'Area.pollMs must be at least 100')
    assert(Config.Vault.activationRadius > 0 and Config.Vault.retryMs > 0, 'Invalid Vault radius or retry interval')
    assert(features.vault == 'none' or VAULT_ENTITY_SETS[features.vault] ~= nil, 'Invalid Features.vault selection')

    for _, name in ipairs({ 'islandPeds', 'ambientAudio', 'disableFlightMusic', 'islandRadioMode' }) do
        AssertBooleanFeature(name)
    end

    for _, name in ipairs({ 'peds', 'scenarios', 'vehicles', 'randomVehicles', 'parkedVehicles' }) do
        local value = Config.Population[name]
        assert(type(value) == 'number' and value >= 0 and value <= 1, 'Population values must be between 0 and 1: ' .. name)
    end

    assert(environment.water.type == 0 or environment.water.type == 1, 'Water type must be 0 or 1')
    assert(environment.waves.intensity >= 0 and environment.waves.intensity <= 3, 'Wave intensity must be between 0 and 3')
end

ValidateConfig()
local iplStates = BuildIplStates()

function SetIplStates(states)
    for iplName, enabled in pairs(states) do
        if not enabled then
            RemoveIpl(iplName)
        end
    end
    for iplName, enabled in pairs(states) do
        if enabled then
            RequestIpl(iplName)
        end
    end
end

function ApplyIplStates()
    for iplName in pairs(iplStates) do
        originalIplStates[iplName] = IsIplActive(iplName)
    end
    SetIplStates(iplStates)
end

function SetIslandAudio(disableFlightMusic, islandRadioMode, ambientAudio)
    SetAudioFlag('DisableFlightMusic', disableFlightMusic)
    SetAudioFlag('PlayerOnDLCHeist4Island', islandRadioMode)
    SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Zones', ambientAudio, true)
    SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Disabled_Zones', not ambientAudio, true)
end

function SetArenaEmittersEnabled(enabled)
    for _, emitterName in ipairs(ARENA_EMITTERS) do
        SetStaticEmitterEnabled(emitterName, enabled)
    end
end

function EnterIslandEnvironment()
    local environment = Config.Environment
    savedEnvironment = {}

    if environment.waves.enabled then
        savedEnvironment.waves = GetDeepOceanScaler()
    end

    if environment.water.enabled then
        savedEnvironment.water = GetGlobalWaterType()
        LoadGlobalWaterType(environment.water.type)
    end

    if environment.waves.enabled then
        SetDeepOceanScaler(environment.waves.intensity + 0.0)
    end

    if environment.disablePrologueZone then
        local zoneId = GetZoneFromNameId('PrLog')
        if zoneId ~= -1 then
            savedEnvironment.zone = zoneId
            SetZoneEnabled(zoneId, false)
        end
    end

    if environment.disableArenaEmitters then
        SetArenaEmittersEnabled(false)
    end

    if environment.managePathNodes then
        SetAiGlobalPathNodesType(1)
        ownsPathNodes = true
        SetResourceKvpInt(PATH_NODES_KVP, 1)
    end

    SetIslandAudio(features.disableFlightMusic, features.islandRadioMode, features.ambientAudio)
end

function RestoreIslandEnvironment()
    if not savedEnvironment then
        return
    end

    local environment = Config.Environment

    if savedEnvironment.water ~= nil then
        LoadGlobalWaterType(savedEnvironment.water)
    end

    if savedEnvironment.waves ~= nil then
        SetDeepOceanScaler(savedEnvironment.waves)
    end

    if savedEnvironment.zone then
        SetZoneEnabled(savedEnvironment.zone, environment.restorePrologueZone)
    end

    if environment.disableArenaEmitters then
        SetArenaEmittersEnabled(environment.restoreArenaEmitters)
    end

    SetIslandAudio(false, false, false)
    savedEnvironment = nil
end

function ReleasePathNodesIfOutside(coords)
    if ownsPathNodes and not IsInsideIsland(coords, true) then
        SetAiGlobalPathNodesType(0)
        ownsPathNodes = false
        DeleteResourceKvp(PATH_NODES_KVP)
    end
end

function RestoreVaultEntitySets()
    if vaultInterior and originalVaultSets and IsValidInterior(vaultInterior) then
        for entitySet, wasActive in pairs(originalVaultSets) do
            if wasActive then
                ActivateInteriorEntitySet(vaultInterior, entitySet)
            else
                DeactivateInteriorEntitySet(vaultInterior, entitySet)
            end
        end
        RefreshInterior(vaultInterior)
    end

    vaultInterior = nil
    originalVaultSets = nil
    appliedVaultSelection = nil
end

function GetReadyVaultInterior()
    local vaultCoords = Config.Vault.coords
    local interiorId = GetInteriorAtCoords(vaultCoords.x, vaultCoords.y, vaultCoords.z)

    if interiorId == 0 or not IsValidInterior(interiorId) or not IsInteriorReady(interiorId) then
        return nil
    end

    return interiorId
end

function UpdateVault(coords)
    local vaultCoords = Config.Vault.coords
    local deltaX = coords.x - vaultCoords.x
    local deltaY = coords.y - vaultCoords.y

    if deltaX * deltaX + deltaY * deltaY > Config.Vault.activationRadius ^ 2 then
        if vaultInterior then
            RestoreVaultEntitySets()
        end
        return
    end

    local interiorId = GetReadyVaultInterior()
    if not interiorId then
        return
    end

    if interiorId ~= vaultInterior then
        RestoreVaultEntitySets()
        vaultInterior = interiorId
        originalVaultSets = {}
        for _, entitySet in pairs(VAULT_ENTITY_SETS) do
            originalVaultSets[entitySet] = IsInteriorEntitySetActive(interiorId, entitySet)
        end
    end

    if appliedVaultSelection == features.vault then
        return
    end

    for _, entitySet in pairs(VAULT_ENTITY_SETS) do
        DeactivateInteriorEntitySet(interiorId, entitySet)
    end

    local selectedSet = VAULT_ENTITY_SETS[features.vault]
    if selectedSet then
        ActivateInteriorEntitySet(interiorId, selectedSet)
    end

    RefreshInterior(interiorId)
    appliedVaultSelection = features.vault
end

function CleanupIsland()
    isInitialized = false
    RestoreIslandEnvironment()
    RestoreVaultEntitySets()
    ReleasePathNodesIfOutside(GetEntityCoords(PlayerPedId()))

    if originalIslandPedsState ~= nil then
        SetScenarioGroupEnabled(ISLAND_PEDS_GROUP, originalIslandPedsState)
        originalIslandPedsState = nil
    end

    SetIplStates(originalIplStates)
    originalIplStates = {}
    isInsideArea = false
end

function ApplyPopulationDensity(population)
    SetPedDensityMultiplierThisFrame(population.peds + 0.0)
    SetScenarioPedDensityMultiplierThisFrame(population.scenarios + 0.0, population.scenarios + 0.0)
    SetVehicleDensityMultiplierThisFrame(population.vehicles + 0.0)
    SetRandomVehicleDensityMultiplierThisFrame(population.randomVehicles + 0.0)
    SetParkedVehicleDensityMultiplierThisFrame(population.parkedVehicles + 0.0)
end

CreateThread(function()
    while isRunning and not NetworkIsSessionStarted() do
        Wait(250)
    end

    if not isRunning then
        return
    end

    ApplyIplStates()
    originalIslandPedsState = IsScenarioGroupEnabled(ISLAND_PEDS_GROUP)
    SetScenarioGroupEnabled(ISLAND_PEDS_GROUP, features.islandPeds)
    isInitialized = true

    while isRunning do
        local coords = GetEntityCoords(PlayerPedId())
        local inside = IsInsideIsland(coords, isInsideArea)

        if inside ~= isInsideArea then
            isInsideArea = inside
            if isInsideArea then
                EnterIslandEnvironment()
            else
                RestoreIslandEnvironment()
            end
        end

        ReleasePathNodesIfOutside(coords)
        Wait(Config.Area.pollMs)
    end
end)

CreateThread(function()
    while isRunning do
        if isInitialized and isInsideArea then
            UpdateVault(GetEntityCoords(PlayerPedId()))
        elseif vaultInterior then
            RestoreVaultEntitySets()
        end
        Wait(Config.Vault.retryMs)
    end
end)

if Config.Population.enabled then
    CreateThread(function()
        local population = Config.Population
        while isRunning do
            if isInitialized and isInsideArea then
                ApplyPopulationDensity(population)
                Wait(0)
            else
                Wait(250)
            end
        end
    end)
end

AddEventHandler('onResourceStop', function(stoppedResource)
    if stoppedResource ~= resourceName then
        return
    end

    isRunning = false
    CleanupIsland()
end)
