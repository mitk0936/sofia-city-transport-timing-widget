subscribe('wifiConfigured', function ()
	local dns_ip = wifi.ap.getip()

	local i1,i2,i3,i4 = dns_ip:match('(%d+)%.(%d+)%.(%d+)%.(%d+)')
	local x00 = string.char(0)
	local x01 = string.char(1)
	local dns_str1 = string.char(128)..x00..x00..x01..x00..x01..x00..x00..x00..x00
	local dns_str2 = x00..x01..x00..x01..string.char(192)..string.char(12)..x00..x01..x00..x01..x00..x00..string.char(3)..x00..x00..string.char(4)
	local dns_strIP = string.char(i1)..string.char(i2)..string.char(i3)..string.char(i4)

	function decodedns(dns_pl)
		local a=string.len(dns_pl)
		dns_tr = string.sub(dns_pl, 1, 2)
		local bte=''
		dns_q=''
		local i=13
		local bte2=''
		while bte2 ~= '0' do
			bte = string.byte(dns_pl,i)
			bte2 = string.format('%x', bte )
			dns_q = dns_q .. string.char(bte)
			i=i+1
		end
	end

	local svr = net.createServer(net.UDP) -- net.createUDPSocket()
	svr:on('receive', function (svr, dns_pl) -- port, ip
		decodedns(dns_pl)
		svr:send(dns_tr..dns_str1..dns_q..dns_str2..dns_strIP) -- port, ip, ...
		collectgarbage()
	end)

	svr:listen(53)
	print('DNS Server is listening. Free Heap: ', node.heap())
end)