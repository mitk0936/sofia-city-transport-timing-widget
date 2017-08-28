print('INITIAL HEAP: ', node.heap())

require('file')
require('cjson') -- WARN: In newest firmware version -> sjson
require('wifi')
require('tmr')

require('event_dispatcher')
require('display')
require('bus-time-api')
require('dns-liar')
require('server')
require('request-handlers')

if (file.open('config.json')) then
	local config = cjson.decode(file.read()) -- WARN: In newest firmware version -> sjson
	file.close()

	config['lineNumber'] = '111'
	config['stopCode'] = '1166005'

	dispatch('configReady', config, true)

	-- setup wifi 
	wifi.setmode(wifi.STATIONAP)
	wifi.sta.config(config.wifi.ssid, config.wifi.pwd or '') -- WARN: In newest firmware version -> { ssid = config.wifi.ssid, pwd = config.wifi.pwd or '' }
	wifi.ap.config({ ssid = config.ap.ssid })
	wifi.sta.connect()

	dispatch('wifiConfigured', nil, true)

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
