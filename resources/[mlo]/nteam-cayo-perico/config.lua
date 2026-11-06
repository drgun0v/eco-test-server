Config = {}

-- NTeam Cayo Perico 1.1.0
-- true = enabled, false = disabled. No commands or server-side configuration.

Config.Area = {
    center = { x = 4840.0, y = -5174.0 },
    enterRadius = 2200.0, -- Horizontal distance; altitude does not affect detection.
    exitRadius = 2450.0,  -- A larger exit radius prevents repeated boundary switching.
    pollMs = 750
}

Config.Features = {
    beachProps = true,
    beachBar = true,
    beachParty = true,         -- Stage and decorations only; no DJ music or dancers.
    airstripProps = true,
    airstripExtraProps = true,
    hangarProps = true,
    hangarDoors = 'open',      -- open / closed / none
    northDockProps = true,
    northDockExtraProps = true,
    mainDockProps = true,
    mainDockExtraProps = true,
    canalProps = true,
    barracksProps = true,
    checkpointProps = false,
    towerVegetation = true,
    islandProps = true,
    grass = true,
    terrainProps05 = false,    -- Broad vegetation/prop groups, not just drug plants.
    terrainProps06 = false,    -- Includes Cayo Porto's h4_islandx_terrain_props_06_a.
    mansionProps = true,
    mansionLights = true,
    islandLodLights = true,
    islandDistantLights = true,
    guardFence = false,
    entranceFence = false,
    sideFence = false,
    padlocks = false,
    mansionGate = 'open',      -- open / closed / broken; uses the retained gate maps.
    underwaterGate = false,
    barracksHatch = true,
    dockWaterHatch = true,
    antiAirProps = false,       -- Map props only; no combat .
    seaMines = false,          -- Map props only; no scripted explosions.
    boatBlockers = false,
    strandedShark = true,      -- Static beached animal, not a living NPC.
    strandedWhale = true,
    remainsCage = false,
    vault = 'none',         -- none / diamond / panther / necklace
    islandPeds = true,         -- GTA island scenario group, not custom guards.
    ambientAudio = true,
    disableFlightMusic = true,
    islandRadioMode = false    -- GTA Heist4 audio flag; may restrict vehicle radio.
}

Config.Population = {
    enabled = false, -- Enable to control density near the island only.
    -- Values: 0.0 to 1.0. Existing/script-created entities are never deleted.
    peds = 1.0,
    scenarios = 1.0,
    vehicles = 1.0,
    randomVehicles = 1.0,
    parkedVehicles = 1.0
}

Config.Environment = {
    waves = { enabled = true, intensity = 0.0 }, -- Restore previous intensity on exit.
    water = { enabled = false, type = 1 },       -- 0 = standard, 1 = Cayo; client-global.
    disablePrologueZone = true,
    restorePrologueZone = true, -- Restore target; this setting has no state getter.
    disableArenaEmitters = true,
    restoreArenaEmitters = true,
    -- Experimental vanilla island path switching. Keep false for Porto's custom YNDs.
    -- Resetting paths near the island can crash GTA. On stop there, paths are left
    -- enabled; reconnect, or restart this resource and leave the island to restore.
    managePathNodes = false
}

Config.Vault = {
    coords = { x = 5012.0, y = -5747.5, z = 15.0 },
    activationRadius = 250.0,
    retryMs = 1500 -- Wait for the interior to stream; no hardcoded interior ID.
}

-- Additional IPL settings override the built-in feature groups.
-- Permanently loaded maps may not respond to RequestIpl/RemoveIpl.
Config.ExtraIpls = {
    -- { name = 'your_custom_ipl', enabled = true },
}

-- Names in this list are left entirely to the map or another resource.
Config.UnmanagedIpls = {
    -- 'h4_islandx_terrain_props_06_a',
}
