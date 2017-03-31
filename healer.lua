-- The actual healer program...

-- Port definitions - make sure these are right or you might end up putting the wrong voltage into something.
-- For motors, port A is 1, B is 2, C is 3
COLOR_SENSOR = 4
TOUCH_SENSOR = 1
LATERAL_MOTOR = 1
RING_MOTOR = 2
RACK_MOTOR = 3

-- Direction definitions - set to +1 or -1 depending on which direction everything is oriented.
-- If something is always going backwards, switch this.
-- We want to set this such that away from the elbow is positive
LATERAL_MOTOR_DIR = 1
-- TODO which direction does this assume
RING_MOTOR_DIR = 1
-- We want to assume that positive values for speed mean going up
RACK_MOTOR_DIR = 1


-- Distance definitions
-- The total distance the lateral motor should move to move across the entire arm
FULL_ARM_DISTANCE = 720
PIN_DISTANCE = 800
FULL_ROTATION_DISTANCE = 360*20
INJURY_SCRAPE_THRESHOLD = 40

-- Speed definitions
INJURY_SCAN_SPEED = 50
LATERAL_BANDAGE_SPEED = 50
RING_BANDAGE_SPEED = 100
RACK_MOTOR_SPEED = 50

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
	nxt.OutputSetRegulation(RACK_MOTOR, 1, 1)
	-- 1 = regulated mode
	-- 2nd 1 = brake
	-- This means the motor will accurately move to where we want it to, and
	-- force it to stop there by negative throttling it.

	-- Record the initial tachometer value of the rack motor.
	local rack_tacho_initial
	_, rack_tacho_initial = nxt.OutputGetStatus(RACK_MOTOR)
	
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
		if nxt.abs(color - calibration_color) > INJURY_COLOR_THRESHOLD and inj_tacho1 == nil then
			inj_tacho1 = tacho
		else if inj_tacho1 ~= nil then
			inj_tacho2 = tacho
		end end
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
	nxt.OutputSetSpeed(RACK_MOTOR,0,0)
	
	_, tacho_initial = nxt.OutputGetStatus(LATERAL_MOTOR)
	-- Move to the wound
	nxt.OutputSetSpeed(LATERAL_MOTOR, 32, LATERAL_MOTOR_DIR*INJURY_SCAN_SPEED, FULL_ARM_DISTANCE)
	repeat
		local tacho
		_, tacho = nxt.OutputGetStatus(LATERAL_MOTOR)
	until nxt.abs(tacho - inj_tacho1) < INJURY_SCRAPE_THRESHOLD
	
	-- touchval is < 512 if it is pressed
	-- Lower the arm until touch sensor is pressed
	nxt.OutputSetSpeed(LATERAL_MOTOR,0,0)
	nxt.InputSetType(TOUCH_SENSOR,0)
	local touchval = nxt.InputGetStatus(TOUCH_SENSOR)
	nxt.OutputSetSpeed(RACK_MOTOR,32,-1*RACK_MOTOR_DIR*RACK_MOTOR_SPEED)
	repeat
		touchval = nxt.InputGetStatus(TOUCH_SENSOR)
	until touchval < 512

	-- Now we scrape the wound until inj_tacho2 + INJURY_SCRAPE_THRESHOLD
	nxt.OutputSetSpeed(LATERAL_MOTOR, 32, LATERAL_MOTOR_DIR*INJURY_SCAN_SPEED)
	repeat
		local tacho
		_, tacho = nxt.OutputGetStatus(LATERAL_MOTOR)
	until LATERAL_MOTOR_DIR*(tacho - inj_tacho2) > INJURY_SCRAPE_THRESHOLD
	nxt.OutputSetSpeed(LATERAL_MOTOR,0,0,0)
	-- If you're confused about the above condition, this is based on that when
	-- if we are moving in the positive direction, we want tacho - inj_tacho2
	-- to be greater than the threshold (INJURY_SCRAPE_THRESHOLD past the end
	-- of the wound). and if we are moving in the negative direction, we want
	-- inj_tacho2 - tacho to be greater than the threshold just because this
	-- will be negative until we are past the end of the wound.

	-- Then we lift the scraper to maximum position
	nxt.OutputSetSpeed(RACK_MOTOR,32,RACK_MOTOR_DIR*RACK_MOTOR_SPEED)
	repeat
		local tacho
		_, tacho = nxt.OutputGetStatus(RACK_MOTOR)
	until nxt.abs(rack_tacho_initial - tacho) < 10
	nxt.OutputSetSpeed(RACK_MOTOR,0,0,0)
	-- This just means we'll stop moving up once we're within 10 degrees of the initial position.

	-- Move to the end now
	nxt.OutputSetSpeed(LATERAL_MOTOR,32,LATERAL_MOTOR_DIR*INJURY_SCAN_SPEED)
	repeat
		local tacho
		_, tacho = nxt.OutputGetStatus(LATERAL_MOTOR)
	until tacho - tacho_initial > PIN_DISTANCE
	nxt.OutputSetSpeed(LATERAL_MOTOR,0,0,0)

	-- TODO module replacement
	-- Then, reposition arm to press module against pin and drop down on the side
	-- TODO what exactly does this mean, quantitatively?

	-- Reinsert connector into wrapping module
	-- Go to center, lower rack and pinion until touch sensor is pressed. (thtat means it's clicked in)
	-- Then stop for a bit, then lift back up with the new module attached.
	-- Return to highest position of the arm
	-- Return to the end of the wound closest to current position
	-- (this is where the module holder is)
	nxt.OutputSetSpeed(LATERAL_MOTOR,32,-1*LATERAL_MOTOR_DIR*INJURY_SCAN_SPEED)
	repeat
		local tacho
		_, tacho = nxt.OutputGetStatus(LATERAL_MOTOR)
	until nxt.abs(tacho - inj_tacho2) < INJURY_SCRAPE_THRESHOLD
	nxt.OutputSetSpeed(LATERAL_MOTOR,0,0,0)
	--
	-- Make wrap while shifting over slightly to the other side of the wound
	-- 3 wraps over 8-10cm of wound
	-- Now we will assume that we are at the pin holder
	nxt.OutputSetSpeed(LATERAL_MOTOR,32,-1*LATERAL_MOTOR_DIR*LATERAL_BANDAGE_SPEED)
	nxt.OutputSetSpeed(RING_MOTOR,32,RING_MOTOR_DIR*RING_BANDAGE_SPEED)
	repeat
		local tacho
		_, tacho = nxt.OutputGetStatus(LATERAL_MOTOR)
	until LATERAL_MOTOR_DIR*(inj_tacho1 - tacho) > INJURY_SCRAPE_THRESHOLD
	-- Same logic here as before...

	-- TODO push thing
	-- Here, we also do the push thing to secure the bandage?
end

heal()
