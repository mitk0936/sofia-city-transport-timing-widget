-- initial setup of the display - SSD1331
spi.setup(1, spi.MASTER, spi.CPOL_HIGH, spi.CPHA_HIGH, spi.DATABITS_8, 0);

local line_position_y = 0;
local line_height = 12;
local cs  = 8; -- GPIO15
local dc  = 4; -- GPIO2
local res = 0; -- GPIO16
local disp = ucg.ssd1331_18x96x64_uvis_hw_spi(cs, dc, res);

-- display initial settings
disp.begin(disp, ucg.FONT_MODE_TRANSPARENT);
disp.clearScreen(disp);
disp.setFontPosTop(disp);
disp.setFont(disp, ucg.font_7x13B_tr);
disp.setPrintPos(disp, 0, 0);
disp.setFontPosTop(disp);
disp.setPrintDir(disp, 0);

local clear_display = function ()
  line_position_y = 0;
  disp.clearScreen(disp);
  disp.setPrintPos(disp, 0, line_position_y); 
end

local print_line = function (lineString)
  disp.setPrintPos(disp, 1, line_position_y);
  disp.setFontPosTop(disp);
  disp.print(disp, lineString or '');
  line_position_y = line_position_y + line_height;
  collectgarbage();
end

local print_header = function (header)
  clear_display();
  disp.setFontPosTop(disp);
  disp.setColor(disp, 255, 255, 25);
  print_line(header[1] or '');
  disp.setColor(disp, 255, 255, 255);
  print_line(header[2] or '');
  collectgarbage();
end

return {
  print_line = print_line,
  print_header = print_header
}
