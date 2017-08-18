split = function (s, pattern, maxsplit)
	local pattern = pattern or " "
	local maxsplit = maxsplit or -1
	local s = s
	local t = {}
	local patsz = #pattern

	while maxsplit ~= 0 do
		local curpos = 1
		local found = string.find(s, pattern)
		if found ~= nil then
			table.insert(t, string.sub(s, curpos, found - 1))
			curpos = found + patsz
			s = string.sub(s, curpos)
		else
			table.insert(t, string.sub(s, curpos))
			break
		end

		maxsplit = maxsplit - 1

		if maxsplit == 0 then
			table.insert(t, string.sub(s, curpos - patsz - 1))
		end
	end

	return t
end

getNthElementInStringArray = function (stringArray, n)
	local searchedSting

	for i, str in ipairs(stringArray) do
		if i == n then
			searchedSting = str
			break
		end
	end

	return searchedSting
end
