fx_version 'cerulean'
game 'gta5'
lua54 'yes'
this_is_a_map 'yes'

author 'Retro Store'
description 'modder bazq'
version '1.0.0'

files {
    'stream/mod/ytyp/rs_paddock_items.ytyp',
    'stream/mod/ytyp/rs_paddock_milo.ytyp',
    'stream/vanilla/ytyp/cityhills_01_metadata_006_strm.ytyp',
} 

data_file 'DLC_ITYP_REQUEST' 'stream/mod/ytyp/bazq-obs_bunker2_arch.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/mod/ytyp/rs_paddock_items.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/vanilla/ytyp/cityhills_01_metadata_006_strm.ytyp'

escrow_ignore {
    'stream/**/*.ytd',
    'stream/**/*.ytyp',
    'stream/vanilla/**'
  }
dependency '/assetpacks'