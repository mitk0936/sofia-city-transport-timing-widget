local timing_url = 'http://https-proxy-server.herokuapp.com/';
local fetch;

local http_request = function (resolve, reject, url)
  node.task.post(function ()
    http.get(
      url,
      'Content-Type: application/json\r\n',
      function (code, data)
        if (code < 0) then
          print('HTTP request failed', code);
          reject(code);
        else
          local ok, json_data = pcall(sjson.decode, data);

          if (ok) then
            resolve(json_data);
            print('HEAP AFTER REQUEST', node.heap());
          else
            reject('Bad response');
          end
        end
      end
    );
  end)
end

fetch = function (
  line_number,
  stop_code
)
  display.print_header({ 'Line: '..line_number, 'Stop: '..stop_code });

  http_request(
    function(loaded_data)
      for i, line in ipairs(loaded_data) do
        if (line['lineName'] == line_number) then
          timing_array = common_utils.split(line['timing'], ',');

          for index, time in ipairs(timing_array) do
            display.print_line(time);
          end
          return;
        end
      end
    end,
    function (error)
      display.print_header(error);
    end,
    timing_url..'?stop_id='..stop_code
  );
end

return {
  start = fetch
};