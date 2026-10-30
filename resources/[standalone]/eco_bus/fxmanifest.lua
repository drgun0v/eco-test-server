fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Dragunov'
description 'Custom Networked Autonomous Public Transit System'
version '1.3.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
