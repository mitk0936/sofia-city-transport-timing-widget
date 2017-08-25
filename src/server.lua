srv = net.createServer(net.TCP)

local __extractJSONRequest = function (payload)
	local json = payload:match('(%b{})')
	if (json) then
		json = pcall(cjson.decode, json)
	else
		json = {}
	end

	return json
end

local __sendFile = function (conn, filename)
	local dataToGet = 0
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
		collectgarbage()
	end)
end

srv:listen(80, function (conn)
	conn:on('receive', function (conn, payload)
		--_, _, method, url, vars = string.find(payload, '([A-Z]+) /([^?]*)%??(.*) HTTP')
		--print('HTTTP method: ', method, 'URL: ', url, 'GET variables: ', vars)
		local json = __extractJSONRequest(payload)

		conn:send('HTTP/1.1 200 OK\r\n\r\n')

		if (url == 'login') then
			print(json)
			conn:close()
		else
			__sendFile(conn, 'index.htm')
		end
	end)
end)

print('HTTP Server is now listening. Free Heap:', node.heap())