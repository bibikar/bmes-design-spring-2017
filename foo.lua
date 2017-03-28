function colordetect(port)
	nxt.InputSetType(port, 13, 0x80)
	repeat
		_,_,_,_,r,g,b=nxt.InputGetStatus(port)
		nxt.DisplayClear()
		nxt.DisplayText("Red: " .. r, 0, 16)
		nxt.DisplayText("Green: " .. g, 0, 32)
		nxt.DisplayText("Blue: " .. b, 0, 48)
		local time = nxt.TimerRead()
		repeat until nxt.TimerRead() - time >= 50
	until nxt.ButtonRead() ~= 0
end

function backandforth(p1, p2, d1, d2)
	repeat until nxt.ButtonRead() ~= 0	
	repeat until nxt.ButtonRead() == 0
	nxt.OutputSetRegulation(p1, 1, 1)
	nxt.OutputSetRegulation(p2, 1, 1)
	local s1 = 70
	local s2 = 70
	_, t1 = nxt.OutputGetStatus(p1)
	_, t2 = nxt.OutputGetStatus(p2)
	nxt.OutputSetSpeed(p1, 0x20, s1, d1)
	nxt.OutputSetSpeed(p2, 0x20, s2, d2)
	repeat
		_, ct1 = nxt.OutputGetStatus(p1)
		_, ct2 = nxt.OutputGetStatus(p2)
		print(nxt.OutputGetStatus(p1))

		if 4 > nxt.abs(ct1 - t1 - d1) then
			nxt.OutputSetSpeed(p1, 0x20, -s1, d1)
		end
		if d1 - 4 < nxt.abs(ct1 - t1 - d1) then
			nxt.OutputSetSpeed(p1, 0x20, s1, d1)
		end
		if 4 > nxt.abs(ct2 - t2 - d2) then
			nxt.OutputSetSpeed(p2, 0x20, -s2, d2)
		end
		if d2 - 4 < nxt.abs(ct2 - t2 - d2) then
			nxt.OutputSetSpeed(p2, 0x20, s2, d2)
		end

			
	until nxt.ButtonRead() ~= 0
	nxt.OutputSetSpeed(p1, 0, 0)
	nxt.OutputSetSpeed(p2, 0, 0)
end


function b2()
	local speed = 70
	repeat
		nxt.OutputSetSpeed(1, 32, speed)
		local time = nxt.TimerRead()
		repeat until nxt.ButtonRead() == 8
		repeat until nxt.ButtonRead() ~= 8
		speed = -speed
	until nxt.ButtonRead() == 1
	nxt.OutputSetSpeed(1, 0, 0)
end
function touchdetect(port)
	nxt.InputSetType(port, 1, 0x60)
	repeat
		print(nxt.InputGetStatus(port))
		local time = nxt.TimerRead()
		repeat until nxt.TimerRead() - time >= 50
	until nxt.ButtonRead() ~= 0
end

nxt.OutputSetSpeed(1,32,100,720)
=nxt.OutputGetStatus(1)


