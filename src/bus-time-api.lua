local timingUrl = 'http://https-proxy-server.herokuapp.com/'
local headers = 'Content-Type: appnplication/json\r\n'

local retryRequest = function (failedFunction, successCallback)
	print("HTTP request failed...")
	node.task.post(node.task.HIGH_PRIORITY, function ()
		failedFunction(successCallback)
	end)
end

subscribe('configReady', function (config)
	dispatch('printHeader', { 'Fetching data...', 'Bus '..config['lineNumber']..' comes' })

	getTiming = function (onSuccess)
		local url = timingUrl..'?stop_id='..config['stopCode']
		print('Requesting', url)
		http.get(
			url,
			headers,
			function (code, data)
				if (code < 0) then
					print('Failed request', code)
					retryRequest(getTiming, onSuccess)
				else
					onSuccess(cjson.decode(data))	
				end
			end
		)
	end

	subscribe('wifiConnected', function ()
		node.task.post(function ()
			getTiming(function (busTimingJson)
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
