function init_set()
	i2c.setup(0,7,6,i2c.SLOW)
	disp = u8g.ssd1306_128x64_i2c(0X3C)
	disp:setFont(u8g.font_chikita)
	disp:setFontRefHeightExtendedText()
    disp:setDefaultForegroundColor()
    disp:setFontPosTop()
	disp:setScale2x2()
end

function display_word(word)
	disp:firstPage()
	repeat		
        disp:drawStr(5,0,"METAS IOT")	
		disp:drawStr(0,20,word)		
	until disp:nextPage() == false
end

function init_display(ssid,pwd,ip)
	disp:firstPage()
	repeat
		disp:drawStr(0,0,""..ssid)
		disp:drawStr(0,10,""..pwd)
		disp:drawStr(0,20,""..ip)
	until disp:nextPage() == false
end

function work_display(value)
	disp:firstPage()
	repeat
		disp:drawStr(4,0,"METAS IOT")
		disp:drawStr(10,15,""..value)
	until disp:nextPage() == false
end

function display_runconfig(ssid,pwd)
    disp:firstPage();
    repeat
        disp:drawStr(0,0, "Wifi:"..ssid);
        disp:drawStr(0,12, "pw:"..pwd);
		disp:drawStr(8,24, "Connecting...");
    until disp:nextPage() == false
end

function display_deviceid(ssid,ip)
    disp:firstPage();
    repeat
      
        disp:drawStr(0,0, "Wifi:"..ssid);
		disp:drawStr(0,12, "IP:"..ip);
		disp:drawStr(12,24, "Connected");
    until disp:nextPage() == false
end

function analog_display(a1,temp,status)
    disp:firstPage();
    repeat
        disp:drawStr(0,0, "a1:"..a1);
        disp:drawStr(0,12, "Temp: "..temp);
		disp:drawStr(0,24, "Status: "..status);
    until disp:nextPage() == false
end






