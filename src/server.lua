require('node')
require('cjson') -- WARN: In newest firmware version -> sjson
require('net')
require('file')
require('event_dispatcher')

local extractJsonFromPayload = function (payload)
	local json = payload:match('(%b{})')
	local parsed, json = pcall(cjson.decode, json) -- WARN: In newest firmware version -> sjson
	
	if (not parsed) then
		return { }
	end

	return json
end

subscribe('sendFile', function (data)
	local conn = data.conn
	local filename = data.filename
	local dataToGet = 0
	local chunk = 1024

	conn:send('HTTP/1.1 200 OK\r\n\r\n')
	conn:send(data.contentType)
	
	conn:on('sent', function(conn) 
		if file.open(filename, 'r') then
			file.seek('set', dataToGet)
			local line = file.read(chunk)
			file.close()

			if line then
				conn:send(line)
				dataToGet = dataToGet + chunk
				if (string.len(line) == chunk) then
					return
				end
			end
		end
		conn:close()
	end)
end)

subscribe('wifiConfigured', function ()
	local srv = net.createServer(net.TCP)

	srv:listen(80, function (conn)
		conn:on('receive', function (conn, payload)
			local _, _, method, url, vars = string.find(payload, '([A-Z]+) /([^?]*)%??(.*) HTTP')
			local json = extractJsonFromPayload(payload)

			dispatch('httpReceive', {
				method = method,
				url = url,
				vars = vars,
				json = json,
				conn = conn
			})
		end)
	end)

	print('HTTP Server is now listening. Free Heap:', node.heap())
end)