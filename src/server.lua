local extractJsonFromPayload = function (payload)
	local json = payload:match('(%b{})')
	if (json) then
		json = pcall(cjson.decode, json)
	else
		json = {}
	end

	return json
end

subscribe('sendFile', function (data)
	local conn = data.conn
	local filename = data.filename
	local dataToGet = 0

	conn:send('HTTP/1.1 200 OK\r\n\r\n')
	conn:on('sent', function(conn) 
		if file.open(filename, 'r') then
			file.seek('set', dataToGet)
			local line = file.read(1024)
			
			file.close()

			if line then
				conn:send(line)
				dataToGet = dataToGet + 1024
				if (string.len(line) == 1024) then
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