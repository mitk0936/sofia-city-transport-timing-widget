module.exports = {
  connectionDelay: 200,
  baud: 115200,
  source: {
    libs: [
      './lib/nodemcu-esp8266-helpers/file.lua',
      './lib/nodemcu-esp8266-helpers/net-http-server.lua',
      './lib/nodemcu-esp8266-helpers/net.lua',
      './lib/nodemcu-esp8266-helpers/wifi.lua',
      './lib/nodemcu-esp8266-helpers/common.lua'
    ],
    scripts: './app/*.lua',
    static: './static/**/*.{json,htm}'
  }
};
