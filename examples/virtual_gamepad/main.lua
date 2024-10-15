local initLuis = require("luis.init")
-- Direct this to your widgets folder.
local luis = initLuis("examples/complex_ui/widgets")

-- register flux in luis, because the widgets of complex_ui need this
luis.flux = require("examples.3rdparty.flux")

local Vector2D = require("examples.3rdparty.vector")
local utils = require("examples.3rdparty.utils")
local BallArena = require("examples.virtual_gamepad.ball")

-- Configuration variables for analog stick

-- luis has it's own inner deadzone support, use this!
luis.deadzone = 0.2
-- setup the other analog stick values yourself
local analogStickOuterDeadzone = 0.9
local analogStickSensitivity = 1.0
local analogStickExtendedRange = 2.0  -- Size multiplier for the extended movement area
local useExtendedAnalogStick = true   -- Toggle for the extended analog stick feature

-- Initialize joystick emulation variables
local joystickX, joystickY = {}, {}

local buttonStates = {
    a = false,
    b = false,
    x = false,
    y = false,
    dpup = false,
    dpdown = false,
    dpleft = false,
    dpright = false
}

-- Mapping keyboard keys to buttons
local keyToButton = {
    d = "a",
    s = "b",
    w = "x",
    a = "y",
    left = "dpleft",
    right = "dpright",
    up = "dpup",
    down = "dpdown"
}

-- create BallArena Container
local ballArenaContainer = luis.newFlexContainer(12, 12, 3, 15)
local ballArenaWidget = nil

-- custom BallArena widget
local function createBallArenaWidget(x, y, width, height)
    local ballArena = BallArena.new(x*luis.gridSize, y*luis.gridSize, width*luis.gridSize, height*luis.gridSize)
    
    local drawFunc = function(self)
        ballArena:draw()
    end
    
    local widget = luis.newCustom(drawFunc, width / luis.gridSize, height / luis.gridSize, y / luis.gridSize + 1, x / luis.gridSize + 1)
    
    -- Add update method to the widget
    widget.update = function(self, dt)
		local stick = 3
		-- Attach a real joystick, it's added first. If not attached, use the vietual Sticks.
		if luis.getActiveJoystick(1) then
			stick = 1
		end
		local x,y = luis.getJoystickAxis(stick, 'leftx'), luis.getJoystickAxis(stick, 'lefty')
		local joystick1 = Vector2D.new(x, y)
		local a,b = luis.getJoystickAxis(stick, 'rightx'), luis.getJoystickAxis(stick, 'righty')
		local joystick2 = Vector2D.new(a, b)
		-- map real Analog Stick values back to virtual to animate the Stick
		if luis.getActiveJoystick(1) then
			joystickX[1]=x
			joystickY[1]=y
			joystickX[2]=a
			joystickY[2]=b
		end
        ballArena:update(dt, joystick1, joystick2, ballArenaContainer.width, ballArenaContainer.height)
    end
    
    return widget
end

function love.load()
    love.window.setMode(800, 600)

    luis.setGridSize(20)
    
	luis.newLayer("game")
    luis.enableLayer("game")

	-- create BallArena Widget
	ballArenaWidget = createBallArenaWidget(5, 5, 12, 12)
	ballArenaContainer:addChild(ballArenaWidget)
	-- Add the BallArena Container to your LUIS layer
	luis.createElement("game", "FlexContainer", ballArenaContainer)

    luis.newLayer("gamepad")
    luis.enableLayer("gamepad")

    -- Create virtual gamepad elements
    createVirtualGamepad()

	-- Initialize joysticks/Gamepads
	luis.initJoysticks()
	if luis.activeJoysticks then
		for id, activeJoystick in pairs(luis.activeJoysticks) do
			local name = activeJoystick:getName()
			local index = activeJoystick:getConnectedIndex()
			print(string.format("Active joystick #%d '%s'.", index, name))
		end
	end
end

local analogStick
local analogStick2
local dpad = {}
local button = {}
function createVirtualGamepad()
    -- Initialize joystick emulation variables
    joystickX[1], joystickY[1] = 0, 0
    joystickX[2], joystickY[2] = 0, 0

	-- create Virtual Analog Stick to emulate Löve2D Gamepad API
	local vjoystick = {}
	-- first virtual Analog Stick
	vjoystick.getName = function()
		return "Virtual Gamepad #1"
	end
	vjoystick.getConnectedIndex = function()
		return 3
	end
	vjoystick.getGamepadAxis = function(self, axis)
		if axis == 'leftx' then return joystickX[1] end
		if axis == 'lefty' then return joystickY[1] end
		if axis == 'rightx' then return joystickX[2] end
		if axis == 'righty' then return joystickY[2] end
		return 0
	end
	luis.setActiveJoystick(3, vjoystick)


	local drawAnalogStick = function(self)
		local stickId = self.text == "Analog1" and 1 or 2
		love.graphics.setColor(0.5, 0.5, 0.5)
		love.graphics.circle("fill", self.position.x + self.width/2, self.position.y + self.height/2, self.width/2)
		
		-- Draw inner deadzone
		love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
		love.graphics.circle("fill", self.position.x + self.width/2, self.position.y + self.height/2, self.width/2 * luis.deadzone)
		
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
		love.graphics.circle("fill", self.position.x + self.width/2 + joystickX[stickId] * self.width/2, self.position.y + self.height/2 + joystickY[stickId] * self.height/2, 20)
		
		-- Draw stick position text
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(string.format("%.2f\n%.2f", joystickX[stickId], joystickY[stickId]), self.position.x + self.width/2 - 20, self.position.y + self.height/2 - 10)
	end

    -- Update analog stick creation
    analogStick = luis.createElement("gamepad", "Button", "Analog1", 6, 6, function() end, function() end, 14, 5)
    analogStick.draw = drawAnalogStick

    -- Add second analog stick
    analogStick2 = luis.createElement("gamepad", "Button", "Analog2", 6, 6, function() end, function() end, 20, 26)
    analogStick2.draw = drawAnalogStick
    
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

local accumulator = 0
function love.update(dt)
    accumulator = accumulator + dt
    if accumulator >= 1/60 then
        luis.flux.update(accumulator)
        accumulator = 0
    end

    luis.update(dt)

    -- Update ballArena
    ballArenaWidget:update(dt)
end

local function getActiveButtonsString()
    local active = {}
    for button, state in pairs(buttonStates) do
        if state then
            table.insert(active, utils.reverseLookup(keyToButton, button) or button)
        end
    end
    return table.concat(active, ", ")
end

function love.draw()
    luis.draw()

    -- Draw some text to show the current state
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Joystick 1: " .. string.format("%.2f, %.2f", joystickX[1], joystickY[1]), 10, 10)
    love.graphics.print("Joystick 2: " .. string.format("%.2f, %.2f", joystickX[2], joystickY[2]), 10, 30)
    love.graphics.print("Buttons: " .. getActiveButtonsString(), 10, 50)
    love.graphics.print("Inner Deadzone: " .. string.format("%.2f", luis.deadzone), 10, 70)
    love.graphics.print("Outer Deadzone: " .. string.format("%.2f", analogStickOuterDeadzone), 10, 90)
    love.graphics.print("Sensitivity: " .. string.format("%.2f", analogStickSensitivity), 10, 110)
    love.graphics.print("Extended Range: " .. (useExtendedAnalogStick and "On" or "Off"), 10, 130)
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
    local sticks = {analogStick, analogStick2}
    for i, stick in ipairs(sticks) do
        local centerX, centerY = stick.position.x + stick.width/2, stick.position.y + stick.height/2
		local dx, dy = x - centerX, y - centerY
		local distance = math.sqrt(dx*dx + dy*dy)
		local maxDistance = stick.width/2
        
        if isPressed and distance <= maxDistance * analogStickExtendedRange then
            -- Normalize vector
            local nx, ny = dx / distance, dy / distance
            
            -- Apply outer deadzone or extended range
            if distance > maxDistance * analogStickOuterDeadzone then
                distance = maxDistance * analogStickOuterDeadzone
            end
            
            joystickX[i] = nx * (distance / maxDistance)
            joystickY[i] = ny * (distance / maxDistance)
            
            -- Apply inner deadzone
            local magnitude = math.sqrt(joystickX[i]*joystickX[i] + joystickY[i]*joystickY[i])
            if magnitude < luis.deadzone then
                joystickX[i], joystickY[i] = 0, 0
            else
                -- Rescale values after inner deadzone
                local scaleFactor = (magnitude - luis.deadzone) / (1 - luis.deadzone)
                joystickX[i] = joystickX[i] * scaleFactor * analogStickSensitivity
                joystickY[i] = joystickY[i] * scaleFactor * analogStickSensitivity
                
                -- Clamp to extended range circle
                magnitude = math.sqrt(joystickX[i]*joystickX[i] + joystickY[i]*joystickY[i])
                if magnitude > analogStickExtendedRange then
                    joystickX[i] = joystickX[i] / magnitude * analogStickExtendedRange
                    joystickY[i] = joystickY[i] / magnitude * analogStickExtendedRange
                end
            end

            return  -- Exit the loop after updating one stick
        elseif not isPressed then
            joystickX[i], joystickY[i] = 0, 0
        end
    end
end

function love.keypressed(key, scancode, isrepeat)
	if keyToButton[key] then
        buttonStates[keyToButton[key]] = true
    end
    
    -- Add keybindings to adjust deadzones and sensitivity
    if key == "q" then
        luis.deadzone = math.max(0, luis.deadzone - 0.05)
    elseif key == "e" then
        luis.deadzone = math.min(analogStickOuterDeadzone - 0.05, luis.deadzone + 0.05)
    elseif key == "r" then
        analogStickOuterDeadzone = math.max(luis.deadzone + 0.05, analogStickOuterDeadzone - 0.05)
    elseif key == "t" then
        analogStickOuterDeadzone = math.min(1, analogStickOuterDeadzone + 0.05)
    elseif key == "f" then
        analogStickSensitivity = math.max(0.1, analogStickSensitivity - 0.1)
    elseif key == "g" then
        analogStickSensitivity = math.min(2, analogStickSensitivity + 0.1)
    elseif key == "y" then
        useExtendedAnalogStick = not useExtendedAnalogStick
	elseif key == "tab" then
        luis.showGrid = not luis.showGrid
        luis.showElementOutlines = not luis.showElementOutlines
        luis.showLayerNames = not luis.showLayerNames
	else
		luis.keypressed(key, scancode, isrepeat)
	end
	
end

function love.keyreleased(key, scancode)
    luis.keyreleased(key, scancode)
    
    -- Handle button releases
    if keyToButton[key] then
        buttonStates[keyToButton[key]] = false
    end
end
