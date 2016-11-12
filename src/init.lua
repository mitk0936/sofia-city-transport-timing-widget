-- setup wifi 
wifi.setmode(wifi.STATION)
wifi.sta.config("***","***") -- wifi credentials (SSID, password)
wifi.sta.connect()

-- Global config variables
timingUrl = "http://drone.sumc.bg/api/v1/timing";
configUrl = "http://drone.sumc.bg/api/v1/config"; -- getting server time

lineNumber = "111";
stopCode = "0968";

local display = dofile("display.lua");
local stringHelper = dofile("string_helper.lua");
local httpData = dofile("http_data.lua");

display.printHeader("Fetching data...", "Bus "..lineNumber.." comes");

-- start getting data
httpData.getConfig(function (configResponse)
	-- extract current time
	local configTimeArray = stringHelper.split(configResponse["date"], " ")
	local currentHour = stringHelper.getNthElementInStringArray(configTimeArray, 2);
	display.printHeader(currentHour, "Bus "..lineNumber.." comes");

	node.task.post(function ()
		httpData.getTiming(function (busTimingJson)
			for i, line in ipairs(busTimingJson) do
				if (line["lineName"] == lineNumber) then

					for j, timeArrive in ipairs(stringHelper.split(line["timing"], ",")) do
						display.printLine(timeArrive)
					end

					break;

				end
			end
		end)
	end);
end);
