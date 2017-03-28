-- The actual healer program...

-- Port definitions - make sure these are right or you might end up putting the wrong voltage into something.
-- For motors, port A is 1, B is 2, C is 3
COLOR_SENSOR = 4
LATERAL_MOTOR = 1

-- Direction definitions - set to +1 or -1 depending on which direction everything is oriented.
-- If something is always going backwards, switch this.
LATERAL_MOTOR_DIR = 1

-- Distance definitions
-- The total distance the lateral motor should move to move across the entire arm
FULL_ARM_DISTANCE = 720

-- Speed definitions
INJURY_SCAN_SPEED = 50

function heal()
	-- Using color sensor, scan entire forearm from wrist to elbow.
	
	nxt.InputSetType(COLOR_SENSOR, 13, 0x80)
	-- 13 means to turn on all three lights
	-- 0x80 means ???
	
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

	repeat
		local tacho
		_, tacho = nxt.OutputGetStatus(LATERAL_MOTOR)
		-- do the color sensor stuff...
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
	-- Make wrap while shifting over slightly to the other side of the wound
	-- 3 wraps over 8-10cm of wound
end

heal()
