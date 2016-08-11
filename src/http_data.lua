local function retryRequest (failedFunction, successCallback)
    print("HTTP request failed...");
    node.task.post(node.task.HIGH_PRIORITY, function ()
        failedFunction(successCallback);
    end);
end

local function getTiming (onSuccess)
    http.post(timingUrl,
    'Content-Type: application/json\r\n',
    '{"stopCode":"'..stopCode..'"}',
    function(code, data)
        if (code < 0) then
            retryRequest (getTiming, onSuccess);
        else
            busTimingJson = cjson.decode(data);
            onSuccess(busTimingJson);
        end
    end)
end

local function getConfig (onSuccess)
    http.get(configUrl,
    'Content-Type: application/json\r\n',
    function(code, data)
        if (code < 0) then
            requestFail(getConfig, onSuccess);
        else
            configJson = cjson.decode(data);
            onSuccess(configJson);
        end
    end)
end

HttpData = {
    getConfig = getConfig,
    getTiming = getTiming
}

return HttpData;
