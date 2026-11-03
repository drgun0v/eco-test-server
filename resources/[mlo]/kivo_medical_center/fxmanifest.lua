fx_version 'cerulean'
game 'gta5'

this_is_a_map 'yes'

author 'KivoStudios'
description 'Kivo Los Santos Medical Center'
version '1.0.2'

files {
    'stream/*.ytyp'
}

escrow_ignore {
    'stream/meta/**',
    'fxmanifest.lua',
    'kivo_hsp_texts1.ytd',
    'kivo_hsp_ext_sign1.ydr',
    'kivo_hsp_lobby_sign.ydr',

}


data_file 'DLC_ITYP_REQUEST' 'stream/*.ytyp'

dependency 'kivo_medical_center_v'
dependency '/assetpacks'

dependency '/assetpacks'