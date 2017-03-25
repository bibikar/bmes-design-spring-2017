
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
	nxt.DisplayText("Press any button", 0, scrollPos)
	scrollPos = scrollPos + 8
	nxt.DisplayText("to begin healing", 0, scrollPos)

	-- wait until some button is pressed:
	repeat until nxt.ButtonRead() ~= 0

	-- Now we actually load the programs and execute them.
	-- In order to do this, we will have to figure out the return values/inputs.
	-- The first function must clean up the wound and also return
	-- the tachometer value at which the wound was found.
	-- The second function will take that tachometer value and go there, then 
	-- bandage the wound.
--
end

main()
