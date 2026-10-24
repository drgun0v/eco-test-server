

fx_version 'adamant'
game 'gta5'
author 'CodeWave, Jamie'
lua54 'yes'
description 'Codewaves BBQ (Lets Cook)'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/client.lua'
}

ui_page "web/index.html"

files {
    "web/index.html",
    'web/script.js',
    'web/style.css',
	'web/sounds/*.mp3',
    'stream/*.ydr',
    'stream/*.ytyp',
    'web/image/*.png'
}


server_scripts {
    'server/server.lua'
}

escrow_ignore {
    'config.lua'
}

  data_file 'DLC_ITYP_REQUEST' 'stream/bbqgazebo.ytyp'  
  data_file 'DLC_ITYP_REQUEST' 'stream/codewavebbq.ytyp' 

dependency '/assetpacks'


