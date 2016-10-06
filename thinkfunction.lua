
function startThinkspeak()
    
    if pcall(function ()require "thinkspeak" end) then
    
        print("Start thinkspeak finished.");
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
            
            conn=net.createConnection(net.TCP, 0) 
            conn:connect(80,'184.106.153.149') 
            conn:send("POST /update?key="..thinkspeak_key.."&field1="..a0.."&field2="..a1.."&field4="..humi.." HTTP/1.1\r\n") 
            conn:send("Host: api.thingspeak.com\r\nAccept: */*\r\nUser-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n\r\n")
            conn:on("receive", function(conn, payload)
            if (string.find(payload, "Status: 200 OK") ~= nil) then
                print("Posting to Thingspeak OK");
            else
                print("Posting failed");
            end
            end)
            
        end)
        
    else
        print("Start thinkspeak failed.");
    end

end