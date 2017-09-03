require('file')
require('cjson') -- WARN: In newest firmware version -> sjson
require('wifi')
require('tmr')
require('utils')
require('event_dispatcher')
require('display')
require('bus-time-api')
require('dns-liar')
require('server')
require('request-handlers')

if (file.open('config.json')) then
	local decoded, config = pcall(cjson.decode, file.read()) -- WARN: In newest firmware version -> sjson
	config = decoded and config or { }
	file.close()

	config = tableMerge({
		wifi = {
			ssid = 'wifi-network',
			pwd = 'wifi-network'
		},
		ap = {
			ssid = 'config-bus',
			pwd = 'config-bus'
		},
		timing = {
			lineNumber = '99999',
			stopCode = '99999'
		}
	}, config)

	dispatch('configReady', config, true)

	-- setup wifi 
	wifi.setmode(wifi.STATIONAP)
	wifi.sta.config(config.wifi.ssid, config.wifi.pwd) -- WARN: In newest firmware version -> { ssid = config.wifi.ssid, pwd = config.wifi.pwd or '' }
	wifi.ap.config({ ssid = config.ap.ssid, pwd = config.ap.pwd })

	dispatch('printHeader', { 'AP '..config.ap.ssid, 'WIFI '..config.wifi.ssid })
	wifi.sta.connect()

	dispatch('wifiConfigured', nil, true)

	tmr.alarm(1, 1500, 1, function()
		if wifi.sta.getip() == nil then
			print('Connecting...', config.wifi.ssid)
		else
			tmr.stop(1)
			print('Connected, IP is '..wifi.sta.getip())
			dispatch('wifiConnected', ip, true)
		end
	end)
else
	dispatch('printHeader', { 'Cannot load', 'config.json' })
	print('Cannot open config.json.')
end
