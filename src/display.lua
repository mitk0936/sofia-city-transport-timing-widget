require('node')
require('spi')
require('ucg')
require('event_dispatcher')

-- initial setup of the display - SSD1331
spi.setup(1, spi.MASTER, spi.CPOL_HIGH, spi.CPHA_HIGH, spi.DATABITS_8, 0)

local linePositionY = 0
local lineHeight = 12
local cs  = 8 -- GPIO15
local dc  = 4 -- GPIO2
local res = 0 -- GPIO16
local disp = ucg.ssd1331_18x96x64_uvis_hw_spi(cs, dc, res)

-- display initial settings
disp.begin(disp, ucg.FONT_MODE_TRANSPARENT)
disp.clearScreen(disp)
disp.setFontPosTop(disp)
disp.setFont(disp, ucg.font_7x13B_tr)
disp.setPrintPos(disp, 0, 0)
disp.setPrintDir(disp, 0)

local clearDisplay = function ()
	linePositionY = 0
	disp.clearScreen(disp)
	disp.setPrintPos(disp, 0, linePositionY) 
end

local printLine = function (lineString)
	print('LINE', lineString)
	print('HEAP', node.heap())
	disp.setPrintPos(disp, 1, linePositionY)
	disp.print(disp, lineString or '')
	linePositionY = linePositionY + lineHeight
end

subscribe('printHeader', function (linesData)
	print('HEADER', linesData[1], linesData[2])
	clearDisplay()
	disp.setColor(disp, 255, 255, 25)
	printLine(linesData[1] or '')
	disp.setColor(disp, 255, 255, 255)
	printLine(linesData[2] or '')
end)

subscribe('printLine', printLine)

clearDisplay()