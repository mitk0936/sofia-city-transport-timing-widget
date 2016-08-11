# sofia-city-transport-timing-widget

Embedded device for home usage,
fetching data from Sofia city-transport API and showing timetable on oled display.

Using NodeMcu http://nodemcu.com
and SSD-1331 oled display

Using API endpoints, exposed here: https://github.com/ivkos/Sofia-Public-Transport-API

# Wiring:

NodeMcu pins -> SSD-1331 pins

GPIO16 (D0)  -> RES
GPIO2 (D4)   -> D/C
GPIO15 (D8)  -> CS
GPIO14 (D5)  -> CLK
GPIO13 (D7)  -> DIN
GPIO12 (D6)  -> NC
GND          -> GND
3V3          -> VCC

Using Lua firmware for nodemcu, built here: http://nodemcu-build.com/
with global modules: cjson, file, gpio, http, net, node, spi, tmr, uart, ucg, wifi

The binary of the firmware is imcluded in the repo.