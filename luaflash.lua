-- luaflash.lua
-- This file contains the functions to write the program into flash.
-- You must execute this by using the lua console.
-- (or you must have the lua console open, since that's where
-- you will paste the programs to be flashed)
-- Just paste in this entire file, and push enter. 
-- This script will walk you through flashing the program files.

function flashprogram(name, size, program)
	nxt.DisplayClear()
	nxt.DisplayText("FLASHING PROGRAM", 0, 0)
	nxt.DisplayText("Do not shut down", 0, 16)
	nxt.DisplayText("until complete!", 4, 24)
	
	-- Make some sort of warning sound
	nxt.SoundTone(800,0,1)
	nxt.SoundTone(800,100,1)
	repeat until nxt.SoundGetStatus() ~= 0
	nxt.SoundTone(400,100,1)
	repeat until nxt.SoundGetStatus() ~= 0
	nxt.SoundTone(800,100,1)
	repeat until nxt.SoundGetStatus() ~= 0
	nxt.SoundTone(400,100,1)

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
	local bytes = nxt.FileWrite(handle, program)
	print(bytes .. " bytes written.")
	nxt.DisplayClear()
	nxt.DisplayText("Flash complete!")

	-- make some sort of flash complete sound:
	nxt.SoundTone(800,0,1)
	nxt.SoundTone(800,100,1)
	repeat until nxt.SoundGetStatus() ~= 0
	nxt.SoundTone(400,100,1)
	repeat until nxt.SoundGetStatus() ~= 0
	nxt.SoundTone(800,100,1)
	repeat until nxt.SoundGetStatus() ~= 0
	nxt.SoundTone(1066,100,1)
end

function flashstartup(program)
	flashprogram("pbLuaStartup", 8, program)
end

function flashhealer(program)
	flashprogram("healer", 32, program)
end

function flashhelp()
	local help = [=[To write to flash, call the function flashprogram().
		flashprogram(name, size, program)
		name (string) - name of file to write to
		size (integer) - size of file to write, in KB
		program (string) - string containing the program.
		
		There are also two presets:
		flashstartup(program) - flashes pbLuaStartup as 8KB file
		flashhealer(program) - flashes healer as 32KB file
		
		If you want to enter a multiline string, enclose it in 
		double square brackets as follows:
		multiline = [[This is a
		multiline string!]]]=]
	print(help)
end

flashhelp()

