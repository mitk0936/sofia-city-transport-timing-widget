require('node')
require('http')
require('cjson')
require('event_dispatcher')

local timingUrl = 'http://https-proxy-server.herokuapp.com/'

local retryRequest = function (failedFunction, successCallback)
	print("HTTP request failed...")
	node.task.post(node.task.HIGH_PRIORITY, function ()
		failedFunction(successCallback)
	end)
end

subscribe('configReady', function (config)
	getTiming = function (onSuccess)
		local url = timingUrl..'?stop_id='..config.timing.stopCode
		node.task.post(function ()

		dispatch('printHeader', { 'Fetching data...', 'Line '..config.timing.lineNumber })
		dispatch('printLine', 'Stop code '..config.timing.stopCode)

		print('Requesting', url)
		
		http.get(
			url,
			'Content-Type: application/json\r\n',
			function (code, data)
				if (code < 0) then
					print('Failed request', code)
					retryRequest(getTiming, onSuccess)
				else
					-- WARN: In newest firmware version -> sjson
					local parsed, jsonData = pcall(cjson.decode, data)
					if ((not parsed) or (not pcall(onSuccess, jsonData))) then
						dispatch('printHeader', { 'Bad response' })
					end
				end
			end
		)
	end

	subscribe('wifiConnected', function ()
			getTiming(function (busTimingJson)
				for i, line in ipairs(busTimingJson['virtual_panel_data']['lines']) do
					if (line['name'] == config.timing.lineNumber) then
						for j, car in ipairs(line['cars']) do
							dispatch('printLine', car['departure_time'])
						end
						return
					end
				end

				dispatch('printHeader', { 'Badly configured', 'stop and line' })
				collectgarbage()
				print('HEAP AFTER REQUEST', node.heap())
			end)
		end)
	end)
end)
