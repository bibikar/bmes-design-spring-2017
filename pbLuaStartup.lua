
-- pbLuaStartup.lua
-- This is the startup program file.
-- Anything in here will be automatically executed as soon as the system starts.
-- Here, we want to do stuff which gets ready for the actual code,
-- then load the actual code and execute it.


-- This is the main function. We will define it here, then execute it later.
-- This allows us to exit whenever we feel like it.
function main()

	-- First, we will clear the display, and display the battery state.

	nxt.DisplayClear()
	scrollPos = 0
	nxt.DisplayText("HealBot 4000", 0, scrollPos)
	mv, _, cap = nxt.BatteryRead()
	scrollPos = scrollPos + 8
	nxt.DisplayText("Battery: " .. cap .. "/4",0, scrollPos)
	scrollPos = scrollPos + 8
	nxt.DisplayText("(" .. mv .. " mV)", 0, scrollPos)

	if mv <= 1 then
		scrollPos = scrollPos + 8
		nxt.DisplayText("LOW BATTERY!", 0, scrollPos)
	end

	-- We want to skip a line...
	scrollPos = scrollPos + 16
	nxt.DisplayText("Press orange btn", 0, scrollPos)
	scrollPos = scrollPos + 8
	nxt.DisplayText("to begin healing", 0, scrollPos)

	nxt.SoundTone(900, 0, 0)
	nxt.SoundTone(900, 100, 2)

	-- wait until some button is pressed:
	local btnStatus
	repeat 
		-- If arrows are pressed, go to the console.
		-- If grey button is pressed, shut down.
		-- If any other (orange) button is pressed, go to healer.
		btnStatus = nxt.ButtonRead()
		if btnStatus == 2 or btnStatus == 4 then
			nxt.SoundTone(300, 0, 0)
			nxt.SoundTone(300, 100, 2)
			nxt.DisplayClear()
			nxt.DisplayText("Exiting to the", 0, 24)
			nxt.DisplayText("Lua console!", 6, 32)
			return -- we want to return to console...
		
		else 
			if btnStatus == 1 then
				nxt.SoundTone(1200, 0, 0)
				nxt.SoundTone(1200, 100, 2)
				repeat until nxt.SoundGetStatus() ~= 0
				nxt.SoundTone(900, 100, 2)
				repeat until nxt.SoundGetStatus() ~= 0
				nxt.SoundTone(720, 100, 2)
				repeat until nxt.SoundGetStatus() ~= 0
				nxt.SoundTone(300, 100, 2)
				repeat until nxt.SoundGetStatus() ~= 0
				nxt.PowerDown()
				return
			end
		end
	until btnStatus ~= 0
	nxt.SoundTone(1200, 0, 0)
	nxt.SoundTone(1200, 100, 2)

	-- Now we actually load the programs and execute them.
	-- In order to do this, we will have to figure out the return values/inputs.
	-- The first function must clean up the wound and also return
	-- the tachometer value at which the wound was found.
	-- The second function will take that tachometer value and go there, then 
	-- bandage the wound.
	
	-- check if the healer file exists first of all!
	if not nxt.FileExists("healer") then
		nxt.DisplayClear()
		nxt.DisplayText("No program!", 0, 0)
		nxt.DisplayText("Make sure that", 0, 8)
		nxt.DisplayText("the program is", 0, 16)
		nxt.DisplayText("saved with the", 0, 24)
		nxt.DisplayText("name 'healer'!", 0, 32)
		nxt.DisplayText("[exiting to", 6, 48)
		nxt.DisplayText("Lua console]", 3, 56)
		nxt.SoundTone(900*5/6, 0, 0)
		nxt.SoundTone(900*5/6, 100, 2)
		return
	end
	
	nxt.dofile("healer")

	-- The way this is set up, it'll be trivial to test the healer file.
	-- All that needs to be done is paste it into the lua console and the program
	-- should run. When we want to flash it, we can do that with luaflash.lua
--
end

main()
