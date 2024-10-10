local initLuis = require("luis.init")
-- Direct this to your widgets folder.
local luis = initLuis("examples/complex_ui/widgets")

-- register flux in luis, because the widgets of complex_ui need this
luis.flux = require("examples.3rdparty.flux")

-- Configuration variables for analog stick
local analogStickInnerDeadzone = 0.2
local analogStickOuterDeadzone = 0.9
local analogStickSensitivity = 1.0
local analogStickExtendedRange = 2.0  -- Size multiplier for the extended movement area
local useExtendedAnalogStick = true   -- Toggle for the extended analog stick feature

function love.load()
    love.window.setMode(800, 600)

    luis.setGridSize(20)
    luis.newLayer("gamepad")
    luis.enableLayer("gamepad")

    -- Create virtual gamepad elements
    createVirtualGamepad()

    -- Initialize joystick emulation variables
    joystickX, joystickY = 0, 0
    buttonStates = {
        a = false,
        b = false,
        x = false,
        y = false,
        dpup = false,
        dpdown = false,
        dpleft = false,
        dpright = false
    }
end

local analogStick
local analogStick2
local dpad = {}
local button = {}
function createVirtualGamepad()
	local draw = function(self)
			love.graphics.setColor(0.5, 0.5, 0.5)
			love.graphics.circle("fill", self.position.x + self.width/2, self.position.y + self.height/2, self.width/2)
			
			-- Draw inner deadzone
			love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
			love.graphics.circle("fill", self.position.x + self.width/2, self.position.y + self.height/2, self.width/2 * analogStickInnerDeadzone)
			
			-- Draw outer deadzone
			love.graphics.setColor(0.7, 0.7, 0.7, 0.5)
			love.graphics.circle("line", self.position.x + self.width/2, self.position.y + self.height/2, self.width/2 * analogStickOuterDeadzone)
			
			-- Draw extended range (if enabled)
			if useExtendedAnalogStick then
				love.graphics.setColor(0.7, 0.7, 0.7, 0.2)
				love.graphics.circle("line", self.position.x + self.width/2, self.position.y + self.height/2, self.width/2 * analogStickExtendedRange)
			end
			
			-- Draw stick handle
			love.graphics.setColor(0.8, 0.8, 0.8)
			love.graphics.circle("fill", self.position.x + self.width/2 + joystickX * self.width/2, self.position.y + self.height/2 + joystickY * self.height/2, 20)
		end

    -- Analog stick
    analogStick = luis.createElement("gamepad", "Button", "Analog", 6, 6, function() end, function() end, 14, 5)
    analogStick.draw = draw

    -- Analog stick 2
    analogStick2 = luis.createElement("gamepad", "Button", "Analog2", 6, 6, function() end, function() end, 20, 25)
    analogStick2.draw = draw
    
    -- A, B, X, Y buttons
    local buttonSize = 3
    local buttonSpacing = 1
    local startRow = 10
    local startCol = 32

    local buttons = {
        {name = "A", color = {0, 1, 0}},
        {name = "B", color = {1, 0, 0}},
        {name = "X", color = {0, 0, 1}},
        {name = "Y", color = {1, 1, 0}}
    }

    for i, btn in ipairs(buttons) do
        local row = math.floor((i-1) / 2)
        local col = (i-1) % 2
        button[i] = luis.createElement("gamepad", "Button", btn.name, buttonSize, buttonSize, 
            function() buttonStates[string.lower(btn.name)] = true end,
            function() buttonStates[string.lower(btn.name)] = false end,
            startRow + row * (buttonSize + buttonSpacing), 
            startCol + col * (buttonSize + buttonSpacing)
        )
		button[i].draw = function(self)
			love.graphics.setColor(btn.color)
			love.graphics.circle("fill", self.position.x + self.width/2, self.position.y + self.height/2, self.width/2)
			love.graphics.setColor(0, 0, 0)
			love.graphics.print(self.text, self.position.x + self.width/2 - 5, self.position.y + self.height/2 - 10)
		end
    end

    -- D-pad
    -- A, B, X, Y buttons
    local buttonSize = 3
    local buttonSpacing = 1
    local startRow = 22
    local startCol = 9

    local dpad_btns = {
        {name = "left", color = {1, 0, 0}, width=0, height=1 },
        {name = "right", color = {0, 0, 1}, width=2, height=1 },
        {name = "up", color = {0, 1, 0}, width=1, height=0 },
        {name = "down", color = {1, 1, 0}, width=1, height=1 }
    }

    for i, btn in ipairs(dpad_btns) do
		local row = btn.height
		local col = btn.width
        dpad[i] = luis.createElement("gamepad", "Button", btn.name, buttonSize, buttonSize, 
            function() buttonStates[string.lower(btn.name)] = true end,
            function() buttonStates[string.lower(btn.name)] = false end,
            startRow + row * (buttonSize + buttonSpacing), 
            startCol + col * (buttonSize + buttonSpacing)
        )
    end
end

function love.update(dt)
    luis.update(dt)
    
    -- Update joystick position for LUIS
    luis.setJoystickPos(400 + joystickX * 200, 300 + joystickY * 200)

    -- Update analog stick visual
    analogStick.text = string.format("%.2f\n%.2f", joystickX, joystickY)
end

local function getActiveButtonsString()
    local active = {}
    for button, state in pairs(buttonStates) do
        if state then
            table.insert(active, button)
        end
    end
    return table.concat(active, ", ")
end

function love.draw()
    luis.draw()

    -- Draw some text to show the current state
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Joystick: " .. string.format("%.2f, %.2f", joystickX, joystickY), 10, 10)
    love.graphics.print("Buttons: " .. getActiveButtonsString(), 10, 30)
    love.graphics.print("Inner Deadzone: " .. string.format("%.2f", analogStickInnerDeadzone), 10, 50)
    love.graphics.print("Outer Deadzone: " .. string.format("%.2f", analogStickOuterDeadzone), 10, 70)
    love.graphics.print("Sensitivity: " .. string.format("%.2f", analogStickSensitivity), 10, 90)
    love.graphics.print("Extended Range: " .. (useExtendedAnalogStick and "On" or "Off"), 10, 110)
end

function love.mousepressed(x, y, button)
    luis.mousepressed(x, y, button)
    updateVirtualAnalogStick(x, y, true)
end

function love.mousereleased(x, y, button)
    luis.mousereleased(x, y, button)
    updateVirtualAnalogStick(x, y, false)
end

function love.mousemoved(x, y, dx, dy)
	updateVirtualAnalogStick(x, y, love.mouse.isDown(1))
end

function updateVirtualAnalogStick(x, y, isPressed)
	local centerX, centerY = analogStick.position.x + analogStick.width/2, analogStick.position.y + analogStick.height/2
	local dx, dy = x - centerX, y - centerY
	local distance = math.sqrt(dx*dx + dy*dy)
	local maxDistance = analogStick.width/2
	
	if isPressed then
		-- Normalize vector
		local nx, ny = dx / distance, dy / distance
		
		-- Apply outer deadzone or extended range
		if useExtendedAnalogStick and distance > maxDistance * analogStickExtendedRange then
			-- return when mouse/touch is out of extended Range
			return
		elseif distance > maxDistance * analogStickOuterDeadzone then
			distance = maxDistance * analogStickOuterDeadzone
		end
		
		joystickX = nx * (distance / maxDistance)
		joystickY = ny * (distance / maxDistance)
		
		-- Apply inner deadzone
		local magnitude = math.sqrt(joystickX*joystickX + joystickY*joystickY)
		if magnitude < analogStickInnerDeadzone then
			joystickX, joystickY = 0, 0
		else
			-- Rescale values after inner deadzone
			local scaleFactor = (magnitude - analogStickInnerDeadzone) / (1 - analogStickInnerDeadzone)
			joystickX = joystickX * scaleFactor * analogStickSensitivity
			joystickY = joystickY * scaleFactor * analogStickSensitivity
			
			-- Clamp to extended range circle
			magnitude = math.sqrt(joystickX*joystickX + joystickY*joystickY)
			if magnitude > analogStickExtendedRange then
				joystickX = joystickX / magnitude * analogStickExtendedRange
				joystickY = joystickY / magnitude * analogStickExtendedRange
			end
		end
	else
		joystickX, joystickY = 0, 0
	end
	
	-- Emulate gamepad events for LUIS
	luis.setJoystickPos(centerX + joystickX * maxDistance, centerY + joystickY * maxDistance)
end

function love.keypressed(key, scancode, isrepeat)
    luis.keypressed(key, scancode, isrepeat)
    
    -- Add keybindings to adjust deadzones and sensitivity
    if key == "q" then
        analogStickInnerDeadzone = math.max(0, analogStickInnerDeadzone - 0.05)
    elseif key == "w" then
        analogStickInnerDeadzone = math.min(analogStickOuterDeadzone - 0.05, analogStickInnerDeadzone + 0.05)
    elseif key == "e" then
        analogStickOuterDeadzone = math.max(analogStickInnerDeadzone + 0.05, analogStickOuterDeadzone - 0.05)
    elseif key == "r" then
        analogStickOuterDeadzone = math.min(1, analogStickOuterDeadzone + 0.05)
    elseif key == "a" then
        analogStickSensitivity = math.max(0.1, analogStickSensitivity - 0.1)
    elseif key == "s" then
        analogStickSensitivity = math.min(2, analogStickSensitivity + 0.1)
    elseif key == "t" then
        useExtendedAnalogStick = not useExtendedAnalogStick
    end
end
