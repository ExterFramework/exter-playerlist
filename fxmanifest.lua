fx_version 'cerulean'
game 'gta5'

name 'exter-playerlist'
author 'NCHub (patched by Codex)'
version '1.1.0'
lua54 'yes'

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/script.js',
  'html/style.css',
  'html/*otf',
  'html/*png',
  'html/sounds/*.ogg',
  'images/*.png',
  'images/*.jpg',
  'images/*.webp',
  'images/*.mp4',
  'fonts/*.ttf',
  'fonts/*.otf'
}

shared_script 'config.lua'

client_script 'client/client.lua'
server_script 'server/server.lua'

escrow_ignore {
  'config.lua',
  'client/client.lua',
  'server/server.lua'
}
