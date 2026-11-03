fx_version "cerulean"
game "gta5"
lua54 "yes"

author 'MXC'
description 'DATA'
version '1.0.0'

replace_level_meta 'gta5'

data_file 'SCENARIO_POINTS_OVERRIDE_PSO_FILE' 'sp_manifest.ymt'


files {
    'gta5.meta',
    'doortuning.ymt',
    'sp_manifest.ymt',
}


escrow_ignore {
    "doortuning.ymt"
}
dependency '/assetpacks'