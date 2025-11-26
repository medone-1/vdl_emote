fx_version 'adamant'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Jelali'
description "A lightweight and responsive NUI menu for RedM that provides animations, scenarios, emotes, walkstyles, and more with smooth navigation and full keyboard support."
version '1.1.1'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

client_scripts {
    'config.lua',
    'data/*.lua',
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
