wifi.setmode(wifi.SOFTAP)
cfg = {}
cfg.ssid = "Metas"..node.chipid()
l = string.len(cfg.ssid)
cfg.ssid = string.sub(cfg.ssid,1,l-2)
cfg.pwd = "12345678"
wifi.ap.config(cfg)
local srv = nil
srv = net.createServer(net.TCP)
srv:listen(80,function(conn)
	conn:on("receive",function(client,request)
		local buf = ""
		local _,_,method,path,vars = string.find(request,"([A-Z]+) (.+)?(.+) HTTP")
		if method == nil then
			_,_,method,path = string.find(request, "([A-Z]+) (.+) HTTP")
		end
		local _GET = {}
		if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=([^%&]+)&*") do
                _GET[k] = v
            end
        end
		if _GET.num ~= nil then
			file.open("thinkspeak_config.lua","w+")
			file.writeline('thinkspeak_key="'.._GET.thinkspeak_key..'"')
			file.close()
			node.restart()
		end
		buf = buf.."<!DOCTYPE html><html><head><meta http-equiv=Content-Type content=\"text/html;charset=utf-8\"></head>"
		buf = buf.."<body><h1>Thinkspeak API Key</h1>"
		buf = buf.."1.請輸入API Key,點擊保存,等待重啟完成,會自動重啟。</br></br>"
		buf = buf.."<form method = 'get' action='http://"..wifi.ap.getip().."'>"
		buf = buf.."API Key:<input name='thinkspeak_key'></input></br>"
		buf = buf.."<button type='submit'>save</button></form></body><html>"
		client:send(buf)
		client:close()
		collectgarbage()
	end)

end)