----------------------- [ MenuV ] -----------------------
-- GitHub: https://github.com/ThymonA/menuv/
-- License: GNU General Public License v3.0
--          https://choosealicense.com/licenses/gpl-3.0/
-- Author: Thymon Arens <contact@arens.io>
-- Name: MenuV
-- Version: 1.0.0
-- Description: FiveM menu libarary for creating menu's
----------------------- [ MenuV ] -----------------------
fx_version 'adamant'
game 'gta5'


client_scripts {
    '@menuv/menuv.lua',
    'language.lua',
	'config.lua',
	'client/*.lua'

}
server_scripts {
    'language.lua',
    'config.lua',
    'server/*.lua',
   
    
  

}

dependencies {
    'menuv'
}