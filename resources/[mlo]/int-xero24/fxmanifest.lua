fx_version 'cerulean'
game 'gta5'
this_is_a_map 'yes'
lua54 'yes' 
-- Download Door Audio and Door Tuning at https://github.com/Heleniust/helnius-map-data
author 'helnius' -- Discord: https://discord.gg/RGgqnsxvMv, Tebex: https://helnius.com/
description 'Xero Gas Stations' 
version '1.0.0-release'

escrow_ignore {
    'config.lua',
    'client.lua',
    'paleto_bay_RemoveIpl.lua',
    'version-check.lua'
}

client_scripts {
    'config.lua',
    'client.lua',
    'paleto_bay_RemoveIpl.lua'
}

server_script 'version-check.lua' 

dependency '/assetpacks'