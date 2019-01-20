wifi_helper = require('lib/wifi');
common_utils = require('lib/common');
display = require('app/display');

local file_helper = require('lib/file');
local bus_time_api = require('app/bus-time-api');

local ok, config = file_helper.read_json_file('static/config.json');

if (ok) then
  config = common_utils.table_merge({
    wifi = { ssid = nil, pwd = nil },
    ap = { ssid = nil, pwd = nil },
    timing = { lineNumber = nil, stopCode = nil }
  }, config);

  wifi_helper.wifi_config_sta(config.wifi.ssid, config.wifi.pwd);
  wifi_helper.wifi_config_ap(config.ap.ssid, config.ap.pwd);

  local net_http_server = require('lib/net-http-server');
  local net_helper = require('lib/net');
  net_helper.dns_liar(wifi.ap.getip());

  net_http_server.start(function (request)
    if (request.url == 'config-timing') then
      local new_config = common_utils.table_merge(config, request.json_body);
      local serialized, encoded_json = pcall(sjson.encode, new_config);

      if (serialized) then
        local updated = file_helper.update_file(
          'static/config.json',
          encoded_json
        );

        if (updated) then
          return net_http_server.send_response(
            request.conn,
            'application/json',
            encoded_json,
            node.restart
          );
        end
      end

      return net_http_server.throw_server_error(conn);
    else
      net_http_server.send_file(request.conn, 'static/html/index.htm', 'Content-Type: text-html');
    end
  end);

  display.print_header({ 'Connecting', config.wifi.ssid });

  wifi_helper.wifi_connect(
    config.wifi.ssid,
    2000,
    function (ip)
      print('Connected, IP is '..ip);
      bus_time_api.start(config.timing.lineNumber, config.timing.stopCode);
    end
  );
else
  display.print_header({ 'Missing Configuration' });
  print('Cannot open static/config.json.');
end