fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Dragunov & EcoTransit Systems'
description 'EcoTablet iPadOS with EcoLink Transit & Uber-Style EcoCab App'
version '2.1.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

exports {
    'OpenEcoTablet',
    'CloseEcoTablet'
}
