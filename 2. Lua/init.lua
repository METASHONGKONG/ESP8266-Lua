require "oled"
init_set()

-----------------Initialize all pins-----------------

--Output: Reset
gpio.mode(1,gpio.OUTPUT);
gpio.write(1,gpio.LOW);
gpio.mode(2,gpio.OUTPUT);
gpio.write(2,gpio.LOW);

--Input: Read A0 first
gpio.mode(8,gpio.OUTPUT)
gpio.write(8,gpio.HIGH)

--Motor: initialize and reset
local R_D0 = 0 --右脚正反转
local R_D5 = 5 --右脚马达
local L_D4 = 4 --左脚正反转
local L_D3 = 3 --左脚马达

gpio.mode(R_D0,gpio.OUTPUT)
gpio.mode(L_D4,gpio.OUTPUT)

pwm.setup(R_D5,50,0)
pwm.setup(L_D3,50,0)
pwm.start(R_D5)
pwm.start(L_D3)

-----------------Initialize all pins-----------------

--Reset network wifi--

analog_value = adc.read(0) 
if analog_value >= 800 then
    local timeout = 0    
    print("Reset mode")
    tmr.alarm(1,500,1,function()                 
        timeout = timeout+0.5
        analog_value = adc.read(0)
        print("Checking..  "..analog_value)
        
        if timeout == 5 then
            tmr.stop(1)
        else
            if analog_value < 100 then
                tmr.stop(0)
                tmr.stop(4)
                tmr.stop(5)
                timeout = 4.5
                file.remove("config_wifi.lua")
                display_word(" Reset OK")
                print("Reset OK")                
                tmr.alarm(2,4000,0,function() display_word("Restart...")	end)
                tmr.alarm(3,5000,0,function() node.restart()	end)                
            end
        end
    end)  
end
print(analog_value)

--Welcome page with OS version--
display_word("  Welcome")


--Input wifi/connect wifi--
tmr.alarm(4,5000,0,function()
    if pcall(function ()require "config_wifi" end) then
            
        wifi.setmode(wifi.STATION)
        wifi.sta.config(ssid,pwd)
        wifi.sta.connect()
        local timeout = 0
        local ip = wifi.sta.getip()
        
        tmr.alarm(0,1000,1,function ()
            timeout = timeout+1
            
            if ip == nil then

                print("please wait")
                
                if timeout >= 25 then
                    wifi.sta.disconnect()
					
					-- AP SSID/PW config               
					apcfg = {}
					apcfg.ssid = "Metas"..node.chipid()                    
					apcfg.ssid = string.sub(apcfg.ssid,1,string.len(apcfg.ssid)-1)
					apcfg.pwd = "12345678"

					-- Wifi AP mode
					wifi.setmode(wifi.SOFTAP)
					wifi.ap.config(apcfg)  
					print("AP mode started: "..apcfg.ssid.." "..apcfg.pwd)

                    ip = wifi.ap.getip()                        
                    display_word(" Time Out")                                              
                    
                else	               
                    ip = wifi.sta.getip()
                    if timeout < 4 then                   
                        display_wifi(ssid,pwd)
                    else
                        display_word("Connecting..") 
                    end
                end
            else
                tmr.stop(0)
                            
                print('IP: ', ip)        
                rest = require "arest"
                    
                if timeout>=25 then
                    display_word("Direct Mode") 
                    tmr.alarm(0,5000,0,function() init_display(apcfg.ssid,apcfg.pwd,ip)	end) 
                else
                    len_num = string.len(ip)
                    display_word("  Ready")
                    tmr.alarm(0,5000,0,function() display_ip(ssid,string.sub(ip,1,10),string.sub(ip,11,len_num))	end)  
                                
                end
				
				srv = nil
                srv=net.createServer(net.TCP) 
                srv:listen(80,function(conn)
					conn:on("receive",function(conn,request)
						rest.handle(conn, request)
					end)
					conn:on("sent",function(conn) conn:close() end)
                end)
            
            end
        end)
        
    else
        print("run_config: input wifi")
        require "run_config"
        display_two_row("NodeOne"," OS Ver1.3")
        tmr.alarm(5,5000,0,function()  display_word("Input Wifi") end)
        tmr.alarm(0,10000,0,function()
            init_display(apcfg.ssid,apcfg.pwd,wifi.ap.getip())
        end)  

    end
end)  