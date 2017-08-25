print('INITIAL HEAP: ', node.heap())

require('event_dispatcher')
require('string_helper')
require('display')
require('api')

if (file.open('config.json')) then
	local config = cjson.decode(file.read())
	file.close()

	config['lineNumber'] = '111'
	config['stopCode'] = '1166005'

	dispatch('configReady', config, true)

	-- setup wifi 
	wifi.setmode(wifi.STATIONAP)
	wifi.sta.config(config.wifi.ssid, config.wifi.pwd or '') -- wifi credentials (SSID, password)
	wifi.ap.config({ ssid = config.ap.ssid })
	wifi.sta.connect()

	require('dns-liar')
	require('server')

	tmr.alarm(1, 1500, 1, function()
		if wifi.sta.getip() == nil then
			print('Connecting...')
		else
			tmr.stop(1)
			print('Connected, IP is '..wifi.sta.getip())
			dispatch('wifiConnected', ip, true)
			
		end
	end)
else
	print('Cannot open config.json.')
end
