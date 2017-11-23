--╪стьнд╪Ч temperature, PM2.5, RGB--
require "si7021"
dofile("PwmSvr_PCA9685.lua")
PwmSvr.begin()
PwmSvr.setPWMFreq(60)

local aREST = {}
local message = "Wrong API."

function aREST.handle(conn, request)

	local R_D0 = 0
	local R_D5 = 5
	local L_D4 = 4
	local L_D3 = 3
	
    -- New request, Find start/end
    local e = string.find(request, "/")
    local request_handle = string.sub(request, e + 1)
    e = string.find(request_handle, "HTTP")
    request_handle = string.sub(request_handle, 0, (e-2))
    print('-----------------------')
    print('Request: ', request_handle)
		
	-- if no favicon included, re-ew message everytime
	-- if favicon included, just use the last message
	if(string.find(request_handle,"favicon.ico") == nil) then message = "Wrong API." end 
	
	-- Pattern: http://IP/mode/value[2]/value[3]/value[4]
	local value={} ; i=1
	for str in string.gmatch(request_handle, "([^//]+)") do
		value[i] = str
		i = i + 1
	end
	local mode = value[1]
	if mode == nil then mode = "" end

	--------------Wifi---------------------
    if mode == "wifi"  and not check_nil(value, 3) then
        if value[2]~=nil and string.len(value[3])>=8 then
            file.open("config_wifi.lua","w+")
            value[2] = string.gsub(value[2],"+"," ")
            file.writeline('ssid="'..value[2]..'"')
            file.writeline('pwd="'..value[3]..'"')
            file.close()
            node.restart()
        end
	else
		value[2] = tonumber(value[2])
    end
    
    --------------General---------------------
    if mode == "mode" and not check_nil(value, 3) then
        if value[3] == "o" then
            gpio.mode(value[2], gpio.OUTPUT)
            message = "" .. value[2] .. " set to output" 
        elseif value[3] == "i" then
            gpio.mode(value[2], gpio.INPUT)
            message = "" .. value[2] .. " set to input"
        elseif value[3] == "p" then
            pwm.setup(value[2], 50, 0);
            pwm.start(value[2]);
            message = "Pin D" .. value[2] .. " set to PWM";
        end 
    end

    if mode == "digital" and not check_nil(value, 3) then
        if value[3] == "0" then 
            gpio.mode(value[2], gpio.OUTPUT)
            gpio.write(value[2], gpio.LOW)
            message = "" .. value[2] .. " set to 0"   
        elseif value[3] == "1" then
            gpio.mode(value[2], gpio.OUTPUT)
            gpio.write(value[2], gpio.HIGH)
            message = "" .. value[2] .. " set to 1" 
        elseif value[3] == "r" then
            value = gpio.read(value[2])
            message = value
        end
    end

    if (mode == "pwm" or mode == "output") and not check_nil(value, 3) then
		value[3] = error_handling(tonumber(value[3]),0,1023)
		pwm.setup(value[2],50,value[3])	
		pwm.start(value[2])
		message = ""..value[2]..":"..value[3]	
	end
    
    if (mode == "analog" or mode == "input") and not check_nil(value, 2) then
        gpio.mode(8,gpio.OUTPUT)
        if value[2] == 0 then
            gpio.write(8,gpio.HIGH)
        else
            gpio.write(8,gpio.LOW)
        end
        message = error_handling(adc.read(0),0,1023)
    end
	
    --------------Function port---------------------
    if (mode == "servo" or mode == "servo2") and not check_nil(value, 3) then
		value[3] = error_handling(tonumber(value[3]),0,180)
		if mode == "servo"  then
			pwm.setup(value[2],50,math.floor(33+((128-33)*value[3]/180)))
			pwm.start(value[2])
		elseif mode == "servo2" then			
			PwmSvr.setPWM(value[2], 0, math.floor(130+((550-130)*value[3]/180)))
		end
        message = ""..value[2]..":"..value[3]
    end
    
    if mode == "motor" and not check_nil(value, 4) then
		
		value[4] = error_handling(tonumber(value[4]),0,1023)
		
        if value[2] == 1 then 
            if value[3] == "cw" then 
				gpio.write(R_D0,gpio.HIGH)
                pwm.setduty(R_D5,value[4])
                message = "Motor " .. value[2] .. " set to " .. value[4] .. " in " .. value[3]   
            elseif value[3] == "acw" then
				gpio.write(R_D0,gpio.LOW)
                pwm.setduty(R_D5,value[4])
                message = "Motor " .. value[2] .. " set to " .. value[4] .. " in " .. value[3]  
            end 
        elseif value[2] == 2 then
            if value[3] == "cw" then 
				gpio.write(L_D4,gpio.HIGH)
                pwm.setduty(L_D3,value[4])
                message = "Motor " .. value[2] .. " set to " .. value[4] .. " in " .. value[3]   
            elseif value[3] == "acw" then
				gpio.write(L_D4,gpio.LOW)
                pwm.setduty(L_D3,value[4])
                message = "Motor " .. value[2] .. " set to " .. value[4] .. " in " .. value[3]  
            end 
        end
    end
    
	if(value[2] ~= nil) then value[2] = error_handling(tonumber(value[2]),0,1023) end
	if mode == "forward" and not check_nil(value, 2) then 
		message = motor_control(value[2],value[2],0,1,"forward",value[2])
	elseif mode == "backward" and not check_nil(value, 2) then
		message = motor_control(value[2],value[2],1,0,"backward",value[2])
	elseif  mode == "left" and not check_nil(value, 2) then
		message = motor_control(value[2],value[2],1,1,"left",value[2])
	elseif mode == "right" and not check_nil(value, 2) then
		message = motor_control(value[2],value[2],0,0,"right",value[2])
	elseif mode == "stop" and not check_nil(value, 1) then
		message = motor_control(0,0,0,0,"stop","")
    end	
                   
    if mode == "temperature" then
        local temp = read_temp()
        message = ""..temp	
    end
    
    if mode == "humidity" then
        local humi = read_humi()
        message = ""..humi	
    end
        
    conn:send("HTTP/1.1 200 OK\r\nContent-type: text/html\r\nAccess-Control-Allow-Origin:* \r\n\r\n" .. message .. "\r\n")
end

function motor_control(M2_speed,M1_speed,M2_direction,M1_direction,direction,speed)
	pwm.setduty(5,M2_speed)
	pwm.setduty(3,M1_speed) 
	gpio.write(0,M2_direction)
	gpio.write(4,M1_direction)
	return "car "..direction.." "..speed.." now... "
	
end

function error_handling(value,min_value,max_value)
	num = value
	if num <= min_value then
		num = min_value
	elseif  num >= max_value then
		num = max_value
	end
	return num
end

function check_nil(value, num)
	for i=1,num,1 do
		if value[i] == nil then
			return true
		end
	end
	return false
end

return aREST