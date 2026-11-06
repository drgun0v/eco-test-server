fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Dragunov & EcoTransit Systems'
description 'Custom Networked Autonomous Smart Taxi & Ride-Hailing System (EcoLuxe, EcoCab, EcoRide)'
version '2.1.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}
