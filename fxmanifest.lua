fx_version 'cerulean'
game 'gta5'
author 'Petris'
title 'Briefcase Mission'
description 'A briefcase mission script made by Petris.'
lua54 'yes'
version '1.0.0'

-- ## SERVER ## --
server_script('configuration/petris_config_sv.lua') 
server_script('server/petris_sv.lua')
 
-- ## CLIENT ## --
client_script('extra/clm_ProgressBar/main.lua') -- Credits To: https://github.com/Daudeuf/clm_ProgressBar
client_script('extra/clm_ProgressBar/class.lua') -- Credits To: https://github.com/Daudeuf/clm_ProgressBar
client_script('client/death.lua')
client_script('configuration/petris_config_cl.lua')
client_script('client/petris_cl.lua')