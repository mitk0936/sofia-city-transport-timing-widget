print('INITIAL HEAP: ', node.heap())

require('event_dispatcher')
require('string_helper')
require('display')
require('api')

if (file.open('config.json')) then
	local config = cjson.decode(file.read())
	file.close()

	config['lineNumber'] = '111'
	config['stopCode'] = '0968'

	dispatch('configReady', config, true)

	-- setup wifi 
	wifi.setmode(wifi.STATION)
	wifi.sta.config(config.wifi.ssid, config.wifi.password) -- wifi credentials (SSID, password)
	wifi.sta.connect()

	tmr.alarm(1, 1500, 1, function()
		if wifi.sta.getip() == nil then
			print("Connecting...")
		else
			tmr.stop(1)
			print("Connected, IP is "..wifi.sta.getip())
			dispatch('wifiConnected', ip, true)
		end
	end)
end
