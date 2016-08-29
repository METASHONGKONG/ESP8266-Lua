	function trim(s)
		return (s:gsub("^%s*(.-)%s*$", "%1"))
	end
	wifi.setmode(wifi.STATIONAP)
	list_ap = ""
	--local for_mat={}
	wifi.sta.getap(function (t)
		if t then 
			
			for k,v in pairs(t) do
				
				ap = string.format("%-10s",k)
				ap = trim(ap)
				list_ap = list_ap.."<option value = "..ap..">"..ap.."</option>"
			end
		
		end
	
	end)

	cfg = {}
	cfg.ssid = "Metas"..node.chipid()
	l = string.len(cfg.ssid)
	cfg.ssid = string.sub(cfg.ssid,1,l-2)
	cfg.pwd = "12345678"
	--wifi.setmode(wifi.SOFTAP)  
    wifi.ap.config(cfg)  
	srv = nil
    srv=net.createServer(net.TCP)  
    srv:listen(80,function(conn)  
        conn:on("receive", function(client,request)  
			
            local buf = "";  
            local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");  
         
			if(method == nil)then  
                _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");  
            end  
			local _GET={}
			local s_num = 0
			local e_num = 0
			local l_num = 0
			if (vars ~= nil)then  
				s_num = string.find(vars,"=")
				e_num = string.find(vars,"&")
				l_num = string.len(vars)
				_GET.sta = string.sub(vars,s_num+1,e_num-1)
				_GET.sta = string.gsub(_GET.sta, "%%(%x%x)", function (h)
					return string.char(tonumber(h, 16))
				end)
				_GET.psd = string.sub(vars,e_num+5,l_num)
            end  
			if _GET.sta~=nil and  string.len(_GET.psd)>=8  then
				
				file.open("config_wifi.lua","w+")
				file.writeline('ssid="'.._GET.sta..'"')
				file.writeline('pwd="'.._GET.psd..'"')
				file.close()
				node.restart()
			end
            buf = buf.."<!DOCTYPE html><html><head><meta http-equiv=Content-Type content=\"text/html;charset=utf-8\"></head>"
			buf = buf.."<body><h1> ESP8266 Web Server</h1>" 
			buf = buf.."<form method = 'get' action='http://"..wifi.ap.getip().."'>"
			buf = buf.."ssid:<select name = 'sta'>"
			buf = buf..list_ap.."</select></br>"
			buf = buf.."pwd:<input type='password' name='psd'></input><br>"
			buf = buf.."<button type='submit'>save</button></form></body><html>"
            client:send(buf); 
			tmr.delay(50000)			
            client:close();  
            collectgarbage();  
        end)  
    end)  

