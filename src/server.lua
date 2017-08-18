srv = net.createServer(net.TCP)

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
		_, _, method, url, vars = string.find(payload, '([A-Z]+) /([^?]*)%??(.*) HTTP')
		print('HTTTP method: '..method, 'URL: '..url, 'GET variables: '.. vars)
		conn:send('HTTP/1.1 200 OK\r\n\r\n')
		__sendFile(conn, 'index.htm')
	end)

	conn:on('sent', function (conn)
		print('sent')
	end)
end)

print('HTTP Server is now listening. Free Heap:', node.heap())