require('event_dispatcher')

subscribe('httpReceive', function (eventData)
	print('requested', eventData.url)
	
	if (eventData.url == 'get-stops') then
		dispatch('sendFile', {
			conn = eventData.conn,
			filename = 'stops.json',
			contentType = 'Content-Type: application/json; charset=UTF-8\r\n'
		})
	elseif (eventData.url == 'submit-config') then
		print('submitted', eventData.json)
		conn:send('HTTP/1.1 200 OK\r\n\r\n')
	else
		dispatch('sendFile', {
			conn = eventData.conn,
			filename = 'index.htm',
			contentType = 'Content-Type: text-html; charset=UTF-8\r\n'
		})
	end
end)