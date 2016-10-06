require "oled"

init_set()
gpio.mode(3,gpio.OUTPUT)
gpio.write(3,gpio.LOW)
gpio.mode(5,gpio.OUTPUT)
gpio.write(5,gpio.LOW) 
gpio.mode(8,gpio.OUTPUT)
gpio.write(8,gpio.HIGH)
analog_value = adc.read(0)
if analog_value >= 800 then
	file.remove("config.lua")
	file.remove("config_wifi.lua")
    file.remove("config_thinkspeak.lua")
end
print(analog_value)
if pcall(function ()require "config" end) then
	
	if value ~= "thinkspeak" or pcall(function ()require "config_thingspeak" end) then
    
        if pcall(function ()require "config_wifi" end) then
            
            --file.remove("config.lua")
            srv = nil
            wifi.setmode(wifi.STATIONAP)
            wifi.sta.config(ssid,pwd)
            --wifi.sta.connect()
            local timeout = 0
            local ip = wifi.sta.getip()
            
            tmr.alarm(0,1000,1,function ()
            
                timeout = timeout+1
                    
                if ip == nil then
                
                    print("please wait")
                    
                    if timeout >= 40 then
                        --file.remove("config_wifi.lua")
                        cfg = {}
                        cfg.ssid = "Metas"..node.chipid()
                        l = string.len(cfg.ssid)
                        cfg.ssid = string.sub(cfg.ssid,1,l-2)
                        cfg.pwd = "12345678"
                        wifi.ap.config(cfg)  
                        ip = wifi.ap.getip()
                        
                        display_word("Time Out > DC")                                              
                        tmr.alarm(0,5000,0,function() init_display(cfg.ssid,cfg.pwd,ip)end)                        
                        
                    else	
                        display_runconfig(ssid,pwd)
                        ip = wifi.sta.getip()
                        
                    end
                else
                    tmr.stop(0)
                    print("123")
                    if value == "thinkspeak" then
                    
                        if pcall(function ()require "config_thingspeak" end) then
                            print("Start thinkspeak function")
                            work_display(value)
                            require "arest_thinkspeak"
                        else
                            print("Input thinkspeak key")                            
                            display_word("Input Key")
                            tmr.alarm(0,5000,0,function()
                                init_display(cfg.ssid,cfg.pwd,wifi.ap.getip())
                            end)                            
                            require "thinkspeak_config"
                        end
                        
                        
                    else
                        if value == "scratch" then
                        
                            require "wire"
                            print("scratch working")
                            work_display(value)	
                            rest = require "arest_scratch"
                              
                                                                                                  
                            if timeout>=40 then
                                display_word("Time Out > DC")                                              
                                tmr.alarm(0,5000,0,function() init_display(cfg.ssid,cfg.pwd,ip)end)     
                            else                                                                                            
                                ip_len = string.len(ip)
                                display_deviceid(ssid,ip)
                            end                                                       
                            
                        else
                            if value == "snap" then
                                print("snap working")
                                work_display(value)	
                                rest = require "arest_snap"		
                            elseif value == "car" then
                                print("car working")
                                work_display(value)
                                rest = require "arest_car"   
                            end
                            if timeout>=40 then
                                display_deviceid(cfg.ssid,cfg.pwd,ip)
                            else
                                len_num = string.len(ip)
                                display_deviceid(ssid,ip)
                            end
                        end
                        
                        ip = nil
                        cfg = nil
                        ssid = nil 
                        pwd = nil
                        l = nil
                        len_num  = nil
                        deviceid = nil
                    
                        srv=net.createServer(net.TCP) 
                        srv:listen(80,function(conn)
                        conn:on("receive",function(conn,request)
                            rest.handle(conn, request)
                          end)
                          conn:on("sent",function(conn) conn:close() end)
                        end)
                    end
                end
            end)
        else
            print("run_config")
            require "run_config"
            display_word("Choose Wifi")
            tmr.alarm(0,5000,0,function()
                init_display(cfg.ssid,cfg.pwd,wifi.ap.getip())
            end)            

        end
				
	else
        print("Input thinkspeak key")                            
        display_word("Input Key")
        tmr.alarm(0,5000,0,function()
            init_display(cfg.ssid,cfg.pwd,wifi.ap.getip())
        end)                            
        require "thinkspeak_config"                            
	end
	
	
else
	print("choose project")
	require "list_config"
    display_word("Choose project")
    tmr.alarm(0,5000,0,function()
        init_display(cfg.ssid,cfg.pwd,wifi.ap.getip())
    end)
	
end