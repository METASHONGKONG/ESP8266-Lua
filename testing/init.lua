--Wifi connection
cfg = { ssid="METAS HONG KONG",pwd = "aabbccddee"} 
wifi.setmode(wifi.STATIONAP)
wifi.sta.config(cfg.ssid,cfg.pwd)
local str_ip = wifi.sta.getip()

--Import lua file
require "oled"
require "si7021"

init_set()

tmr.alarm(0,500,1,function ()
	if str_ip == nil then
        work_display("Waiting")
		
		print("Waiting for SSID...")
		str_ip =  wifi.sta.getip()
	else
		
			tmr.stop(0)
            init_display(cfg.ssid,cfg.pwd,str_ip)
			print("IP: "..str_ip)
			cfg = nil
			
		end
	end)

tmr.alarm(1,10000,1,function ()

    --a0/a1
    gpio.mode(8,gpio.OUTPUT)
	gpio.write(8,gpio.HIGH)
	local a0 = adc.read(0) 
	gpio.write(8,gpio.LOW)
	local a1 = adc.read(0) 
   
    --Temperature/humidity
    local humi = read_humi()
    local temp = read_temp()

    print("Connecting to ThingSpeak")
	print("A0: "..a0)
	print("A1: "..a1)
    print("Temperature: "..temp)
	print("humidity: "..humi)
    
	--analog_display(a0,a1,temp,humi)
	conn=net.createConnection(net.TCP, 0) 
	conn:connect(80,'184.106.153.149') 
	conn:send("POST /update?key=665JMSM7ZTAO732P&field1="..a0.."&field2="..a1.."&field4="..humi.." HTTP/1.1\r\n") 
    --conn:send("POST /update?key=665JMSM7ZTAO732P&field1="..a0.."&field2="..a1.." HTTP/1.1\r\n") 
    --conn:send("POST /update?key=665JMSM7ZTAO732P&field3="..temp.."&field4="..humi.." HTTP/1.1\r\n")
	conn:send("Host: api.thingspeak.com\r\nAccept: */*\r\nUser-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n\r\n")
	conn:on("receive", function(conn, payload)
    if (string.find(payload, "Status: 200 OK") ~= nil) then
        print("Posting to Thingspeak OK");
    else
        print("Posting failed");
    end
	end)
	


	
	
end)


