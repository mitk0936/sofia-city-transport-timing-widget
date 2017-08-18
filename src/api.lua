local timingUrl = 'http://drone.sumc.bg/api/v1/timing'
local configUrl = 'http://drone.sumc.bg/api/v1/config'
local contentType = 'Content-Type: application/json\r\n'

local __retryRequest = function (failedFunction, successCallback)
	print("HTTP request failed...")
	node.task.post(node.task.HIGH_PRIORITY, function ()
		failedFunction(successCallback)
	end)
end

local __getApiConfig = function (onSuccess)
	http.get(
		configUrl,
		contentType,
		function (code, data)
			if (code < 0) then
				__retryRequest(__getApiConfig, onSuccess)
			else
				configJson = cjson.decode(data)
				onSuccess(configJson)
			end
		end
	)
end

subscribe('configReady', function (config)
	local __getTiming = function (onSuccess)
		http.post(
			timingUrl,
			contentType,
			'{"stopCode":"'..config['stopCode']..'"}',
			function (code, data)
				if (code < 0) then
					__retryRequest(__getTiming, onSuccess)
				else
					busTimingJson = cjson.decode(data)
					onSuccess(busTimingJson)
				end
			end
		)
	end

	dispatch('printHeader', { 'Fetching data...', 'Bus '..config['lineNumber']..' comes' })

	subscribe('wifiConnected', function ()
		__getApiConfig(function (apiConfigData)
			-- extract current time
			local configTimeArray = split(apiConfigData['date'], ' ')
			local currentHour = getNthElementInStringArray(configTimeArray, 2)

			dispatch('printHeader', { currentHour, 'Bus '..config['lineNumber']..' comes'})

			node.task.post(function ()
				__getTiming(function (busTimingJson)
					for i, line in ipairs(busTimingJson) do
						if (line['lineName'] == config['lineNumber']) then
							for j, timeArrive in ipairs(split(line['timing'], ',')) do
								dispatch('printLine', timeArrive)
							end
							break
						end
					end
				end)
			end)
		end)
	end)
end)
