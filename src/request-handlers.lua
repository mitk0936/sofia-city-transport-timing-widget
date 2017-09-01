require('node')
require('cjson')
require('file')
require('event_dispatcher')

local updateConfigFile = function (newConfig, onSuccess, onError)
	local serialized, encodedJson = pcall(cjson.encode, newConfig)
	if (serialized) then
		if (file.open('config.json', 'w+')) then
			print(encodedJson)
			file.write(encodedJson)
			file.close()
			onSuccess()
		else
			onError()
		end
	else
		onError()
	end
end

subscribe('configReady', function (config)
	subscribe('httpReceive', function (eventData)
		print('received on url: ', eventData.url)
		if (eventData.url == 'config-timing') then
			local newConfig = tableMerge(config, eventData.json)

			print('new__', cjson.encode(eventData.json))
			
			updateConfigFile(newConfig, function ()
				dispatch('sendResponse', {
					conn = eventData.conn,
					contentType = 'application/json',
					response = cjson.encode(newConfig),
					onComplete = node.restart
				})
			end, function ()
				dispatch('throwServerError', {
					conn = eventData.conn
				})
			end)
		else
			dispatch('sendFile', {
				conn = eventData.conn,
				filename = 'index.htm',
				contentType = 'Content-Type: text-html; charset=UTF-8\r\n'
			})
		end
	end)
end)