require('node')
require('http')
require('event_dispatcher')

local timingUrl = 'http://https-proxy-server.herokuapp.com/'
local headers = 'Content-Type: application/json\r\n'

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
		node.task.post(function ()
			local foundLine = false

			getTiming(function (busTimingJson)
				for i, line in ipairs(busTimingJson['virtual_panel_data']['lines']) do
					if (line['name'] == config['lineNumber']) then
						foundLine = true
						for j, car in ipairs(line['cars']) do
							dispatch('printLine', car['departure_time'])
						end
						break
					end
				end

				if (not foundLine) then
					dispatch('printHeader', { 'Badly configured', 'stop and line' })
				end

				collectgarbage()
				print('HEAP AFTER REQUEST', node.heap())
			end)
		end)
	end)
end)
