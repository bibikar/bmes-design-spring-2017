-- luaflash.lua
-- This file contains the functions to write the program into flash.
-- You must execute this by using the lua console.
-- (or you must have the lua console open, since that's where
-- you will paste the programs to be flashed)
-- Just paste in this entire file, and push enter. 
-- This script will walk you through flashing the program files.

-- inputs: name (string), size (integer, in kilobytes)
function luaflash_writeprogram(name, size)

	
	print("Paste the program now. When done, push Ctrl+D, or ^D")
	print("or any other method of entering an EOF character.")
	
	programString = io.read("*all") -- read until EOF
	flashprogram(name, size, programString)


end

function flashprogram(name, size, program)
	print("Opening " .. name .. " for writing...")
	local handle
	if nxt.FileExists(name) then
		handle = nxt.FileOpen(name)
	else
		handle = nxt.FileCreate(name, size * 1024)
	end

	-- Now we have the file handle. We can get the program 
	-- from the user now, and save it into the file.

	print("\nWriting " .. name .. " into flash!")
	bytes = nxt.FileWrite(handle, program)
	print(bytes .. " bytes written.")
end


function luaflash()

	nxt.DisplayClear()
	nxt.DisplayText("FLASHING PROGRAM", 0, 0)
	nxt.DisplayText("Do not shut down", 0, 16)
	nxt.DisplayText("until complete!", 4, 24)

	-- The plan now is to have the program separated into two files.
	-- 1. pbLuaStartup - executed on startup after usb console is connected
	-- 	The startup file doesn't care about the healer file. It just loads it
	-- 	and lets it do its thing once it's loaded up.
	-- 2. healer - actually does all the bandaging and stuff.
	
	print("Welcome to the luaflash utility.")

	luaflash_writeprogram("pbLuaStartup", 8) -- startup file is 8 KB
	luaflash_writeprogram("healer", 32) -- actual healer file is 32 KB
end
