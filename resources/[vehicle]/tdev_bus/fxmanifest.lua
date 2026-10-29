fx_version 'cerulean'
game 'gta5'

author 'Tdev'
description 'Advanced Bus System'
version '2.0.9'
lua54 'yes'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

escrow_ignore {
    'fxmanifest.lua',
    'config.lua',
    'README.md'
    
}

dependency '/assetpacks'