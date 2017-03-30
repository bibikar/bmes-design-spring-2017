function displaytacho(port)
	nxt.DisplayClear()
	nxt.DisplayText("Manual adjust",0,0)
	nxt.DisplayText("mode. Push the",0,8)
	nxt.DisplayText("grey square to",0,16)
	nxt.DisplayText("exit.",0,24)
	_,tacho = nxt.OutputGetStatus(port)
	nxt.DisplayText("Tacho: " .. tacho,0,32)
	nxt.DisplayText("Moving port " .. port)			
end	

function motormotion()
	repeat until nxt.ButtonRead() == 0
	local port=1
	local tacho
	displaytacho(port)
	repeat
		local fl
		if nxt.ButtonRead() == 8 then
			repeat until nxt.ButtonRead() == 0
			if port == 3 then port = 1
			else port = port + 1; end
			fl = true
		end
		
		_,tachon = nxt.OutputGetStatus(port)
		if (tachon ~= tacho) or fl then
			fl = false
			tacho = tachon
			displaytacho(port)
		end
		while nxt.ButtonRead() == 2 do
			nxt.OutputSetSpeed(port,32,100)
			displaytacho(port)
		end
		while nxt.ButtonRead() == 4 do
			nxt.OutputSetSpeed(port,32,-100)
			displaytacho(port)
		end
		nxt.OutputSetSpeed(port, 0,0)
	until nxt.ButtonRead() == 1
	nxt.DisplayClear()
	repeat until nxt.ButtonRead() == 0
end
