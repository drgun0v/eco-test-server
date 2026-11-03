fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Dragunov'
description 'Custom Networked Autonomous Smart Taxi System (EcoCab)'
version '1.0.0'

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
