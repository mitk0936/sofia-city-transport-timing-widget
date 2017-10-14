tableMerge = function (t1, t2)
	for k,v in pairs(t2) do
		if type(v) == 'table' then
			if type(t1[k] or false) == 'table' then
				tableMerge(t1[k] or {}, t2[k] or {})
			else
				t1[k] = v
			end
		else
			t1[k] = v
		end
	end
	return t1
end

splitBySeparator = function (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end
