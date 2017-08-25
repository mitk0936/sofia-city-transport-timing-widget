local timingUrl = 'http://https-proxy-mitk0936.c9users.io/'
local headers = 'Content-Type: appnplication/json\r\n'

local __retryRequest = function (failedFunction, successCallback)
	print("HTTP request failed...")
	node.task.post(node.task.HIGH_PRIORITY, function ()
		failedFunction(successCallback)
	end)
end

subscribe('configReady', function (config)
	dispatch('printHeader', { 'Fetching data...', 'Bus '..config['lineNumber']..' comes' })

	__getTiming = function (onSuccess)
		local url = timingUrl..'?stop_id='..config['stopId']
		print('Requesting', url)
		http.get(
			url,
			headers,
			function (code, data)
				if (code < 0) then
					print('Failed request', code)
					__retryRequest(__getTiming, onSuccess)
				else
					onSuccess(cjson.decode(data))	
				end
			end
		)
	end

	subscribe('wifiConnected', function ()
		node.task.post(function ()
			__getTiming(function (busTimingJson)
				for i, line in ipairs(busTimingJson['virtual_panel_data']['lines']) do
					if (line['name'] == config['lineNumber']) then
						for j, car in ipairs(line['cars']) do
							dispatch('printLine', car['departure_time'])
						end
						break
					end
				end
			end)
		end)
	end)
end)
