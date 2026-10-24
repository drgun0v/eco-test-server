fx_version 'cerulean'
games { 'gta5' }
this_is_a_map 'yes'

author 'CubeTome1'
description 'Mirror Park Police Station'
version '1.0.0'

data_file 'SCENARIO_POINTS_OVERRIDE_FILE' 'sp_manifest.ymt' -- scenarios override
data_file 'TIMECYCLEMOD_FILE' 'cube_mppd_timecycles.xml' -- custom timecycles
data_file 'AUDIO_GAMEDATA' 'audio/cube_mppd_doors_game.dat' -- doors sounds
data_file 'AUDIO_GAMEDATA' 'audio/D5517709_game.dat' -- basement audio occlusion
data_file 'AUDIO_GAMEDATA' 'audio/750FB6BB_game.dat' -- top audio occlusion

files {
    'gta5.meta',
    'doortuning.ymt',
    'sp_manifest.ymt',
    'cube_mppd_timecycles.xml',
    'audio/**/*.rel'
}

-- Scripts used to load entitysets - you can replace this with your own --
shared_script 'config.lua'
client_script 'client.lua'
--------------------------------------------------------------------------

escrow_ignore {
    'stream/int/top/cube_mppd_atrium_wallofhonor.ydr', -- wall of honor, lspd logo embedded,
    'config.lua', -- entitysets loading configuration - you can replace this with your own
    'client.lua' -- entitysets loading client script - you can replace this with your own
}
dependency '/assetpacks'