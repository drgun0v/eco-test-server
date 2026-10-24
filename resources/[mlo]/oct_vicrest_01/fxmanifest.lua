fx_version 'cerulean'
game 'gta5'
author 'Ortiz'
lua54 'yes'
version '1.0.1'

this_is_a_map "yes"

client_script 'client.lua'

files{
    'interiorproxies.meta',
    'stream/Exterior/venice_metadata_014_strm.ytyp',
    'octavista_vicrest_timecycle.xml',
    'stream/Shell/oct_vicrest_01_main.ytyp',
}

escrow_ignore {
}

data_file 'INTERIOR_PROXY_ORDER_FILE' 'interiorproxies.meta'
data_file 'DLC_ITYP_REQUEST' 'stream/Exterior/venice_metadata_014_strm.ytyp'
data_file 'TIMECYCLEMOD_FILE' 'octavista_vicrest_timecycle.xml'

dependency '/assetpacks'