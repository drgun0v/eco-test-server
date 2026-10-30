fx_version "cerulean"
game "gta5"
lua54 "yes"

author 'MXC'
description 'PIZZATHIS'
version '1.0.0'

this_is_a_map 'yes'

data_file 'DLC_ITYP_REQUEST' 'v_int_57.ytyp'
data_file 'DLC_ITYP_REQUEST' 'mxc_pizzathis_props_ytyp.ytyp'
data_file 'TIMECYCLEMOD_FILE' 'mxc_timecycle_list_01.xml'
data_file 'AUDIO_GAMEDATA' '[audio]/mxc_pizzathis_game.dat'

files {
    'mxc_timecycle_list_01.xml',
    '[audio]/mxc_pizzathis_game.dat151.rel',
}

client_script {
    'pizzathis_entityset_mods.lua',
}

escrow_ignore {
    'pizzathis_entityset_mods.lua',
    'stream/[multi-location]/[[1-VinewoodBoulevard]/*.ydr',
    'stream/[multi-location]/[2-AtleeStreet]/*.ydr',
    'stream/[multi-location]/[3-DelPerro]/*.ydr',
    'stream/[eup-clothing]/*.ydd',
    'stream/[interior]/*.ydr',
}
dependency '/assetpacks'