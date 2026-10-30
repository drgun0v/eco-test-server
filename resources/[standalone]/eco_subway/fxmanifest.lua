fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Dragunov'
description 'Custom Networked Autonomous Underground Metro System (LST) with Live PIDS'
version '1.8.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
