fx_version 'cerulean'
game 'gta5'
author 'kiiya'
description 'La Puerta Apartments'
version '1.0.0'
this_is_a_map 'yes'
lua54 'yes'

data_file 'TIMECYCLEMOD_FILE' 'kiiya_timecycle.xml'
data_file 'AUDIO_GAMEDATA' 'lapuerta_game.dat'

client_script 'client.lua'

files {
  'sp_manifest.ymt',
  'lapuerta_game.dat151.rel',
  'kiiya_timecycle.xml',
}

  client_scripts {
  'elevator/config.lua',
  'elevator/functions.lua', 
  'elevator/NativeUI.lua',
  'elevator/menu.lua',
}

escrow_ignore {
  'elevator/config.lua', 
  'client.lua',
}

data_file 'SCENARIO_POINTS_OVERRIDE_PSO_FILE' 'sp_manifest.ymt'

dependency '/assetpacks'
