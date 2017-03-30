-- The actual healer program...

-- Port definitions - make sure these are right or you might end up putting the wrong voltage into something.
-- For motors, port A is 1, B is 2, C is 3
COLOR_SENSOR = 4
LATERAL_MOTOR = 1

-- Direction definitions - set to +1 or -1 depending on which direction everything is oriented.
-- If something is always going backwards, switch this.
LATERAL_MOTOR_DIR = 1
RING_MOTOR_DIR = 1



-- Distance definitions
-- The total distance the lateral motor should move to move across the entire arm
FULL_ARM_DISTANCE = 720
FULL_ROTATION_DISTANCE = 360*20

-- Speed definitions
INJURY_SCAN_SPEED = 50

-- Miscellaneous definitions
INJURY_COLOR_THRESHOLD = 100

function heal()
	-- Using color sensor, scan entire forearm from wrist to elbow.
	
	nxt.InputSetType(COLOR_SENSOR, 13, 0x80)
	-- 13 means to turn on all three lights
	-- 0x80 means ???
	--
	-- Collect initial color values.
	_,_,_,_,red_cali, green_cali, blue_cali = nxt.InputGetStatus(COLOR_SENSOR)
	calibration_color = red_cali + green_cali + blue_cali
	
	-- We need to make sure that we are in the correct initial position.
	-- Another assumption is that the wound is on top!
	nxt.OutputSetRegulation(LATERAL_MOTOR, 1, 1)
	-- 1 = regulated mode
	-- 2nd 1 = brake
	-- This means the motor will accurately move to where we want it to, and
	-- force it to stop there by negative throttling it.
	
	nxt.OutputSetSpeed(LATERAL_MOTOR, 32, LATERAL_MOTOR_DIR*INJURY_SCAN_SPEED, FULL_ARM_DISTANCE)
	local tacho_initial
	_, tacho_initial = nxt.OutputGetStatus(LATERAL_MOTOR)
	inj_tacho1
	inj_tacho2
	-- These are the initial and final tachometer values around the injury.

	repeat
		local tacho
		_, tacho = nxt.OutputGetStatus(LATERAL_MOTOR)
		-- do the color sensor stuff...
		_,_,_,_,r,g,b = nxt.InputGetStatus(COLOR_SENSOR)
		color = r+g+b
		if nxt.abs(color - calibration_color) > INJURY_COLOR_THRESHOLD then
			if inj_tacho1 ~= nil then
				inj_tacho2 = tacho
			else 
				inj_tacho1 = tacho
			end
		end
	until d1 - 4 <= tacho - tacho_initial
	-- Now we are at the other end.
	-- Move back...
	nxt.OutputSetSpeed(LATERAL_MOTOR,32,-1*LATERAL_MOTOR_DIR*INJURY_SCAN_SPEED, FULL_ARM_DISTANCE)
	repeat
		local tacho
		_, tacho = nxt.OutputGetStatus(LATERAL_MOTOR)
	until d1 - 4 <= tacho - tacho_initial

	nxt.OutputSetSpeed(LATERAL_MOTOR,0,0,0)

	-- After a full pass, lower arm to correct height, and scrape on the return
	-- Then, reposition arm to press module against pin and drop down on the side
	-- Reinsert connector into wrapping module
	-- Return to highest position of the arm
	-- Return to the end of the wound closest to current position
	--
	-- Make wrap while shifting over slightly to the other side of the wound
	-- 3 wraps over 8-10cm of wound
	-- Now we will assume that we are at the pin holder
	--
	

	-- Here, we also do the push thing to secure the bandage?
end

heal()
