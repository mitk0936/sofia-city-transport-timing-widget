# sofia-city-transport-timing-widget

Embedded device for home usage,
fetching data from Sofia city-transport API and showing timetable on oled display.

Using NodeMcu http://nodemcu.com
and SSD-1331 oled display

Using API endpoints, exposed here: https://github.com/ivkos/Sofia-Public-Transport-API

# Wiring:

<p align="center">
	<img src="IMG_20160804_210255.jpg" width="450"/>
</p>

<table>
	<tr>
		<th>
			NodeMcu pins
		</th>
		<th>
			SSD-1331 pins
		</th>
	</tr>
	<tr>
		<td>
			GPIO16 (D0)
		</td>
		<td>
			RES
		</td>
	</tr>
	<tr>
		<td>
			GPIO2 (D4)
		</td>
		<td>
			D/C
		</td>
	</tr>
	<tr>
		<td>
			GPIO15 (D8)
		</td>
		<td>
			CS
		</td>
	</tr>
	<tr>
		<td>
			GPIO14 (D5)
		</td>
		<td>
			CLK
		</td>
	</tr>
	<tr>
		<td>
			GPIO14 (D5)
		</td>
		<td>
			CLK
		</td>
	</tr>
	<tr>
		<td>
			GPIO13 (D7)
		</td>
		<td>
			DIN
		</td>
	</tr>
	<tr>
		<td>
			GPIO12 (D6)
		</td>
		<td>
			NC
		</td>
	</tr>
	<tr>
		<td>
			GND
		</td>
		<td>
			GND
		</td>
	</tr>
	<tr>
		<td>
			3V3
		</td>
		<td>
			VCC
		</td>
	</tr>
</table>

# Configuration:
Before uploading the file, configurate your wifi network at src/config.json

# Firmware:

Using Lua firmware for nodemcu, built here: http://nodemcu-build.com/
with global modules: cjson, file, gpio, http, net, node, spi, tmr, uart, ucg, wifi

The binary of the firmware is imcluded in the repo.
<br/>

For flashing, flash esp_init_data_default.bin at:
<ul>
	<li>ESP-01, -03, -07 etc. with 512 kByte flash require 0x7c000</li>
	<li>Init data goes to 0x3fc000 on an ESP-12E with 4 MByte flash</li>
</ul>

<br/>

Flash nodemcu-master-11-modules-2016-08-11-16-28-01-float.bin at 0x00000