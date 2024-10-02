local json = require("luis.3rdparty.json")

local luis = {}

-- UI elements storage
luis.layers = {}	-- Store all created layers
luis.elements = {}  -- Store all created elements
luis.elementStates = {}  -- Store states of stateful elements
luis.currentLayer = nil	-- current Layer (deprecaded - use enable or disable layer!)
luis.layerStack = {}	-- Layer stack (don't touch)
luis.enabledLayers = {}  -- Store enabled layers
luis.lastFocusedWidget = {} -- Table to store the last focused widget for each layer

-- Scaling
luis.baseWidth, luis.baseHeight = 1920, 1080
luis.scale = 1

-- Grid settings
luis.gridSize = 20
luis.showGrid = false
luis.showElementOutlines = false
luis.showLayerNames = false

-- Variables for joystick and gamepad support
luis.joysticks = {}
luis.activeJoystick = nil
luis.deadzone = 0.2
luis.dpadSpeed = 300
-- Variables for joystick navigation
luis.currentFocus = nil
luis.focusableElements = {}
luis.joystickButtonStates = {}

--[[
love.graphics.newFont(fontsize, hinting mode)

normal - Default hinting. Should be preferred for typical antialiased fonts.
light - Results in fuzzier text but can sometimes preserve the original glyph shapes of the text better than normal hinting.
mono - Results in aliased / unsmoothed text with either full opacity or completely transparent pixels. Should be used when antialiasing is not desired for the font.
none - Disables hinting for the font. Results in fuzzier text.
]]--

--==============================================
-- Default theme
--==============================================
luis.theme = {
    background = {
        color = {0.1, 0.1, 0.1},
    },
    text = {
        color = {1, 1, 1},
        font = love.graphics.newFont(32, "normal"),
        align = "left",
    },
    button = {
        color = {0.2, 0.2, 0.2, 1},
        hoverColor = {0.25, 0.25, 0.25, 1},
        pressedColor = {0.15, 0.15, 0.15, 1},
        textColor = {1, 1, 1, 1},
		align = "center",
        cornerRadius = 4,
        elevation = 4,
        elevationHover = 8,
        elevationPressed = 12,
        transitionDuration = 0.25,
    },
    slider = {
        trackColor = {0.4, 0.4, 0.4},
        knobColor = {0.6, 0.6, 0.6},
		grabColor = {0.8, 0.8, 0.8},
        knobRadius = 10,
    },
    switch = {
        offColor = {0.5, 0.5, 0.5},
        onColor = {0, 0.7, 0},
        knobColor = {1, 1, 1},
    },
    checkbox = {
        boxColor = {0.4, 0.4, 0.4},
        checkColor = {0, 0.7, 0},
        cornerRadius = 4,
    },
    radiobutton = {
        circleColor = {0.4, 0.4, 0.4},
        dotColor = {0, 0.7, 0},
    },
    grid = {
        color = {0.5, 0.5, 0.5, 0.3},
    },
    progressbar = {
        backgroundColor = {0.2, 0.2, 0.2, 1},
        fillColor = {0.15, 0.15, 0.15, 1},
        borderColor = {0.25, 0.25, 0.25, 1},
    },
    icon = {
        color = {1, 1, 1, 1},
    },
    dropdown = {
        backgroundColor = {0.2, 0.2, 0.2, 1},
        textColor = {1, 1, 1},
		align = "left",
        hoverColor = {0.25, 0.25, 0.25, 1},
        borderColor = {0.15, 0.15, 0.15, 1},
        arrowColor = {1, 1, 1},
        scrollBarColor = {0.5, 0.5, 0.5},
        scrollBarWidth = 10
    },
	textinput = {
		backgroundColor = {0.2, 0.2, 0.2},
		textColor = {1, 1, 1},
		cursorColor = {1, 1, 1},
		selectionColor = {0.3, 0.7, 1, 0.5},
		borderColor = {0.5, 0.5, 0.5},
		borderWidth = 2,
		padding = 5
	},
	flexContainer = {
        backgroundColor = {0.2, 0.2, 0.2, 0.5},
        borderColor = {0.3, 0.3, 0.3, 1},
        borderWidth = 2,
        padding = 10,
        handleSize = 20,
        handleColor = {0.5, 0.5, 0.5, 1}
	},
}

--==============================================
-- Layer handling
--==============================================

-- Create a new layer
function luis.newLayer(name)
    local layer = {
        name = name,
        elements = {}
    }
    luis.layers[name] = layer
    if luis.currentLayer == nil then
        luis.currentLayer = name
    end
	
    return name
end

function luis.setCurrentLayer(layerName)
    if luis.layers[layerName] then
        -- Store the last focused widget of the current layer before changing
        luis.updateLastFocusedWidget(luis.currentLayer)
        
        -- Remove the layer if it's already in the stack
        for i, layer in ipairs(luis.layerStack) do
            if layer == layerName then
                table.remove(luis.layerStack, i)
                break
            end
        end
        -- Add the layer to the top of the stack
        table.insert(luis.layerStack, layerName)
		-- disable currentLayer
		luis.disableLayer(luis.currentLayer)
		-- set new CurrentLayer
        luis.currentLayer = layerName
        -- Ensure the current layer is also enabled
        luis.enableLayer(layerName)
		-- 
		luis.currentFocus = nil
        -- Restore focus to the last focused widget of the new current layer
        luis.restoreFocus(layerName)
    end
end

function luis.popLayer()
    if #luis.layerStack > 1 then
        local poppedLayer = table.remove(luis.layerStack)
        -- Store the last focused widget of the popped layer
        luis.updateLastFocusedWidget(poppedLayer)
		-- disable currentLayer
        luis.disableLayer(poppedLayer)
		-- set new CurrentLayer
        luis.currentLayer = luis.layerStack[#luis.layerStack]
		-- Ensure the current layer is also enabled
        luis.enableLayer(luis.currentLayer)
		-- set focus for gamepad
		luis.restoreFocus(luis.currentLayer)
        return luis.currentLayer
    end
    return false
end

-- Enable a layer
function luis.enableLayer(layerName)
    if luis.layers[layerName] then
        luis.enabledLayers[layerName] = true
    end
end

-- Disable a layer
function luis.disableLayer(layerName)
    if luis.layers[layerName] then
        -- Store the last focused widget before disabling the layer
        luis.updateLastFocusedWidget(layerName)
        luis.enabledLayers[layerName] = false
    end
end

-- Toggle a layer's enabled state
function luis.toggleLayer(layerName)
    if luis.layers[layerName] then
        luis.enabledLayers[layerName] = not luis.enabledLayers[layerName]
    end
end

-- Check if a layer is enabled
function luis.isLayerEnabled(layerName)
    return luis.enabledLayers[layerName] == true
end


--==============================================
-- Widget handling
--==============================================

function luis.createElement(layerName, elementType, ...)
    if not luis.elements[layerName] then
        luis.elements[layerName] = {}
    end

    local element
    if elementType == "FlexContainer" and type((...)) == "table" and (...).type == "FlexContainer" then
        -- If it's a pre-existing FlexContainer, use it directly
        element = (...)
    else
        -- Otherwise, create a new element as before
        element = luis["new" .. elementType](...)
    end

    -- Add default z-index
    element.zIndex = element.zIndex or 1

    table.insert(luis.elements[layerName], element)
    
    -- Initialize state for stateful elements (unchanged)
    if elementType == "Slider" or
       elementType == "Switch" or
       elementType == "CheckBox" or
       elementType == "RadioButton" or
       elementType == "DropDown" or
	   elementType == "ProgressBar" or
       elementType == "TextInput" then
        if not luis.elementStates[layerName] then
            luis.elementStates[layerName] = {}
        end
        luis.elementStates[layerName][#luis.elements[layerName]] = element.value
    end
    
    return element
end

function luis.setElementState(layerName, index, value)
    if not luis.elementStates[layerName] then
        luis.elementStates[layerName] = {}
    end
    luis.elementStates[layerName][index] = value
    
    -- Update the actual element's value
    if luis.elements[layerName] and luis.elements[layerName][index] then
        luis.elements[layerName][index].value = value
    end
end

function luis.getElementState(layerName, index)
    if luis.elementStates[layerName] and luis.elementStates[layerName][index] then
        return luis.elementStates[layerName][index]
    end
    return nil
end

--==============================================
-- Theme handling
--==============================================

function luis.updateElementTheme(theme)
    for _, layer in pairs(luis.elements) do
        for _, element in ipairs(layer) do
            if element.type == "Button" and element ~= luis.currentFocus then
                local buttonTheme = theme.button
				element.colorR = buttonTheme.color[1]
				element.colorG = buttonTheme.color[2]
				element.colorB = buttonTheme.color[3]
				element.colorA = buttonTheme.color[4]
            end
       end
    end
end

-- Set a new theme
function luis.setTheme(newTheme)
    for category, styles in pairs(newTheme) do
        if luis.theme[category] then
            for property, value in pairs(styles) do
                luis.theme[category][property] = value
            end
        end
    end
	luis.updateElementTheme(newTheme)
end

--==============================================
-- Core functionality
--==============================================

function luis.setGridSize(gridSize)
	if gridSize then
		luis.gridSize = gridSize
	end
end

function luis.updateScale()
    local w, h = love.graphics.getDimensions()
    luis.scale = math.min(w / luis.baseWidth, h / luis.baseHeight)
end

local accumulator = 0
local mx = luis.baseWidth
local my = luis.baseHeight
function luis.update(dt)
    accumulator = accumulator + dt
    if accumulator >= 1/60 then
        luis.flux.update(accumulator)
        accumulator = 0
    end

    local mx, my = love.mouse.getPosition()
    mx, my = mx / luis.scale, my / luis.scale
    
    -- Joystick navigation
    local jx, jy = luis.getJoystickAxis('leftx'), luis.getJoystickAxis('lefty')
    if math.abs(jx) > luis.deadzone or math.abs(jy) > luis.deadzone then
        mx, my = mx + jx * 10, my + jy * 10  -- Adjust speed as needed
    end
    
    -- Check for joystick button presses for focus navigation
    if luis.joystickJustPressed('dpdown') then
        luis.moveFocus("next")
    elseif luis.joystickJustPressed('dpup') then
        luis.moveFocus("previous")
    end

    for layerName, enabled in pairs(luis.enabledLayers) do
        if enabled and luis.elements[layerName] then
            for i, element in ipairs(luis.elements[layerName]) do
                if element.update then
                    element:update(mx, my, dt)
                end
                -- Update state for stateful elements
                if element.type == "Slider" or
                   element.type == "Switch" or
                   element.type == "CheckBox" or
                   element.type == "RadioButton" or
                   element.type == "DropDown" or
                   element.type == "TextInput" then
                    luis.setElementState(layerName, i, element.value or element.text)
                end
            end
        end
    end

    -- Update focused element
	luis.updateFocusableElements()
	
    if luis.currentFocus and luis.currentFocus.updateFocus then
        luis.currentFocus:updateFocus(jx, jy)
    end
end

-- Element debug outlines
local function drawElementOutline(element)
    love.graphics.setColor(1, 1, 1, 0.5)
	local font_backup = love.graphics.getFont()
	local font = love.graphics.newFont(12, "mono")
	love.graphics.setFont(font)
	local text = element.position.x/luis.gridSize+1 .. " x "	-- we have to add +1 as the grid is indexed at 1,1 not 0,0 !!
	love.graphics.print(text, element.position.x+2, element.position.y)
	love.graphics.print(element.position.y/luis.gridSize+2, element.position.x+string.len(text)*4+12, element.position.y)

	love.graphics.print(element.width/luis.gridSize, element.position.x+element.width-22, element.position.y)
	love.graphics.print(element.height/luis.gridSize, element.position.x+element.width-22, element.position.y+element.height-16)

    love.graphics.rectangle("line", element.position.x, element.position.y, element.width, element.height)
	love.graphics.setFont(font_backup)
end

function luis.draw()
    love.graphics.push()
    love.graphics.scale(luis.scale, luis.scale)
    love.graphics.setBackgroundColor(luis.theme.background.color)

    -- Draw enabled layers
	--[[
    for layerName, enabled in pairs(luis.enabledLayers) do
        if enabled and luis.elements[layerName] then
            for _, element in ipairs(luis.elements[layerName]) do
                element:draw()
                if luis.showElementOutlines then
                    drawElementOutline(element)
                end
            end
        end
    end
	]]--
    -- Sort by z_index and Draw enabled layers
    for layerName, enabled in pairs(luis.enabledLayers) do
        if enabled and luis.elements[layerName] then
            -- Sort elements by z-index
            local sortedElements = {}
            for _, element in ipairs(luis.elements[layerName]) do
                table.insert(sortedElements, element)
            end
            table.sort(sortedElements, function(a, b) return a.zIndex < b.zIndex end)

            for _, element in ipairs(sortedElements) do
                element:draw()
                if luis.showElementOutlines then
                    drawElementOutline(element)
                end
            end
        end
    end

    -- Draw grid if enabled
    if luis.showGrid then
        love.graphics.setColor(luis.theme.grid.color)
        for i = 0, luis.baseWidth, luis.gridSize do
            love.graphics.line(i, 0, i, luis.baseHeight)
        end
        for j = 0, luis.baseHeight, luis.gridSize do
            love.graphics.line(0, j, luis.baseWidth, j)
        end
    end

    if luis.showLayerNames then
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.setFont(luis.theme.text.font)
		local counter = 0
        for layerName, enabled in pairs(luis.enabledLayers) do
            if enabled then
                local layerWidth = luis.theme.text.font:getWidth(layerName)
                love.graphics.print(layerName, 10+layerWidth*counter, 10+20*counter)
				counter = counter +1
            end
        end
    end

    love.graphics.pop()
end

--==============================================
-- Input handling
--==============================================

-- Helper function to handle input for a single layer
local function handleLayerInput(layerName, x, y, inputFunction, ...)
    if luis.enabledLayers[layerName] and luis.elements[layerName] then
        -- Sort elements by z-index in descending order
        local sortedElements = {}
        for _, element in ipairs(luis.elements[layerName]) do
            table.insert(sortedElements, element)
        end
        table.sort(sortedElements, function(a, b) return a.zIndex > b.zIndex end)

        for _, element in ipairs(sortedElements) do
			-- handle mouse
            if element[inputFunction] and x and y and element[inputFunction](element, x, y, ...) then
                return true  -- Stop propagation if an element handled the input
			-- handle gamepad
            elseif element[inputFunction] and element[inputFunction](element, ...) then
				return true  -- Stop propagation if an element handled the input
			end
        end
    end
    return false
end

------------------------------------------------
-- Keyboard input handling
------------------------------------------------

function luis.keypressed(key)
    if key == "tab" then
        luis.showGrid = not luis.showGrid
        luis.showElementOutlines = not luis.showElementOutlines
		luis.showLayerNames = not luis.showLayerNames
    else
		for layerName, enabled in pairs(luis.enabledLayers) do
			if enabled and luis.elements[layerName] then
				for _, element in ipairs(luis.elements[layerName]) do
					--if (element.type == "TextInput" and element.active) or element.type == "FlexContainer" then
					if (element.type == "TextInput" and element.active) or element.keypressed then
						element:keypressed(key)
						return
					end
				end
			end
		end
	end
end

function luis.textinput(text)
    if luis.elements[luis.currentLayer] then
        for _, element in ipairs(luis.elements[luis.currentLayer]) do
			if (element.type == "TextInput" and element.active) or element.type == "FlexContainer" then
                element:textinput(text)
                return
            end
        end
    end
end

------------------------------------------------
-- Mouse input handling
------------------------------------------------
function luis.mousepressed(x, y, button, istouch)
    x, y = x / luis.scale, y / luis.scale
    for layerName, _ in pairs(luis.enabledLayers) do
        if handleLayerInput(layerName, x, y, "click", button, istouch) then
            return true
        end
    end
    return false
end

function luis.mousereleased(x, y, button, istouch)
    x, y = x / luis.scale, y / luis.scale
    for layerName, _ in pairs(luis.enabledLayers) do
        if handleLayerInput(layerName, x, y, "release", button, istouch) then
            return true
        end
    end
    return false
end

function luis.wheelmoved(x, y)
    for layerName, _ in pairs(luis.enabledLayers) do
        if handleLayerInput(layerName, nil, nil, "wheelmoved", x, y) then
            return true
        end
    end
    return false
end

------------------------------------------------
-- Focus handling for Joystick
------------------------------------------------
-- Function to update the last focused widget for a layer
function luis.updateLastFocusedWidget(layerName)
    if luis.elements[layerName] then
        for index, element in ipairs(luis.elements[layerName]) do
            if element.focusable and element.focused then
                luis.lastFocusedWidget[layerName] = index
                return
            end
        end
    end
    -- If no focused widget found, set to nil
    luis.lastFocusedWidget[layerName] = nil
end

-- Function to restore focus to the last focused widget of a layer
function luis.restoreFocus(layerName)
    local lastFocusedIndex = luis.lastFocusedWidget[layerName]
    if lastFocusedIndex and luis.elements[layerName][lastFocusedIndex] then
        local element = luis.elements[layerName][lastFocusedIndex]
        element.focused = true
        luis.currentFocus = element
    else
		-- Fall back to default focus behavior
		luis.updateFocusableElements()
    end
end

-- Update the list of focusable elements
function luis.updateFocusableElements()
	if not luis.activeJoystick then return end

    luis.focusableElements = {}
    for layerName, enabled in pairs(luis.enabledLayers) do
        if enabled and luis.elements[layerName] then
            for _, element in ipairs(luis.elements[layerName]) do
                if element.focusable then
                    table.insert(luis.focusableElements, element)
                end
            end
        end
    end
    -- Set initial focus if not set
	if not luis.currentFocus and #luis.focusableElements > 0 then
		luis.currentFocus = luis.focusableElements[1]
	end
	
	-- after focus change, update all button colors
	luis.updateElementTheme(luis.theme)
end

-- Move focus in a direction
function luis.moveFocus(direction)
    if #luis.focusableElements == 0 then return end

    local currentIndex = 1
    for i, element in ipairs(luis.focusableElements) do
        if element == luis.currentFocus then
            currentIndex = i
            break
        end
    end
    
    local newIndex
    if direction == "next" then
        newIndex = (currentIndex % #luis.focusableElements) + 1
    elseif direction == "previous" then
        newIndex = ((currentIndex - 2) % #luis.focusableElements) + 1
    else
        newIndex = 1 -- Default to first element if no direction specified
    end

    local newFocusElement = luis.focusableElements[newIndex]
    luis.setCurrentFocus(newFocusElement)
    
    -- If the new focus is a FlexContainer, activate its internal focus
    if newFocusElement.type == "FlexContainer" then
        newFocusElement:activateInternalFocus()
    end
    
    -- Update the last focused widget for the current layer
    luis.updateLastFocusedWidget(luis.currentLayer)
end

-- Update the setCurrentFocus function
function luis.setCurrentFocus(element)
    if luis.currentFocus then
        if luis.currentFocus.type == "FlexContainer" then
            luis.currentFocus:deactivateInternalFocus()
        end
        luis.currentFocus.focused = false
    end
    luis.currentFocus = element
    if luis.currentFocus then
        luis.currentFocus.focused = true
        if luis.currentFocus.type == "FlexContainer" then
            luis.currentFocus:activateInternalFocus()
        end
    end
end

-- Add a new function to handle exiting FlexContainer focus
function luis.exitFlexContainerFocus()
    if luis.currentFocus and luis.currentFocus.type == "FlexContainer" then
        luis.currentFocus:deactivateInternalFocus()
        -- Move focus to the next element
        luis.moveFocus("next")
    end
end

------------------------------------------------
-- Joystick input handling
------------------------------------------------

function luis.initJoysticks()
    luis.joysticks = love.joystick.getJoysticks()
    if #luis.joysticks > 0 then
        luis.activeJoystick = luis.joysticks[1]
    end
end

-- Set active joystick
function luis.setActiveJoystick(joystick)
    luis.activeJoystick = joystick
end

function luis.joystickJustPressed(button)
    local isPressed = luis.isJoystickPressed(button)
    local justPressed = isPressed and not luis.joystickButtonStates[button]
    luis.joystickButtonStates[button] = isPressed
    return justPressed
end

-- Check if a Joystick or Gamepad button is pressed
function luis.isJoystickPressed(button)
    return luis.activeJoystick and luis.activeJoystick:isGamepadDown(button)
end

-- Get Joystick or Gamepad axis value
function luis.getJoystickAxis(axis)
    if luis.activeJoystick then
        local value = luis.activeJoystick:getGamepadAxis(axis)
        return math.abs(value) > luis.deadzone and value or 0
    end
    return 0
end

function luis.setJoystickPos(x,y)
	mx=x
	my=y
end

function luis.getJoystickPos()
	return mx, my
end


-- Function for joystick button press
function luis.gamepadpressed(joystick, button)
    if joystick == luis.activeJoystick then
        -- First, check if the current focus is a FlexContainer
        if luis.currentFocus and luis.currentFocus.type == "FlexContainer" then
            if luis.currentFocus:gamepadpressed(button) then
                return true
            end
        end

        -- If FlexContainer didn't handle the input, check other elements
        for layerName, _ in pairs(luis.enabledLayers) do
            if handleLayerInput(layerName, nil, nil, "gamepadpressed", button) then
                return true
            end
        end
    end
    return false
end

-- Function for joystick button release
function luis.gamepadreleased(joystick, button)
    if joystick == luis.activeJoystick then
        -- First, check if the current focus is a FlexContainer
        if luis.currentFocus and luis.currentFocus.type == "FlexContainer" then
            if luis.currentFocus:gamepadreleased(button) then
                return true
            end
        end

        for layerName, _ in pairs(luis.enabledLayers) do
            if handleLayerInput(layerName, nil, nil, "gamepadreleased", button) then
                return true
            end
        end
    end
    return false
end


--==============================================
-- State Management
--==============================================

-- Helper function to convert all keys to strings
local function deepCopyWithStringKeys(t)
    if type(t) ~= 'table' then return t end
    local res = {}
    for k, v in pairs(t) do
        if type(v) == 'table' then
            v = deepCopyWithStringKeys(v)
        end
        res[tostring(k)] = v
    end
    return res
end

function luis.saveConfig(filename)
    local config = {}
    for layerName, elements in pairs(luis.elements) do
        config[layerName] = {}
        for i, element in ipairs(elements) do
            if element.type == "Slider" or
               element.type == "Switch" or
               element.type == "CheckBox" or
               element.type == "RadioButton" or
               element.type == "DropDown" or
               element.type == "TextInput" then
                config[layerName][i] = {
                    type = element.type,
                    value = element.value or element.text
                }
            end
        end
    end

    -- Convert elementStates to a new table with string keys
    local config = deepCopyWithStringKeys(config)

    local jsonString = json.encode(config)
    love.filesystem.write(filename, jsonString)
end

-- load configuration
function luis.loadConfig(filename)
    if love.filesystem.getInfo(filename) then
        local jsonString = love.filesystem.read(filename)
        local config = json.decode(jsonString)
        
        for layerName, elements in pairs(config) do
            if luis.elements[layerName] then
                for i, elementConfig in pairs(elements) do
                    local element = luis.elements[layerName][tonumber(i)]
                    if element and element.type == elementConfig.type then
                        if element.type == "Slider" or
							element.type == "Switch" or
							element.type == "CheckBox" then
                            element.value = elementConfig.value
                        elseif element.type == "RadioButton" then
                            element.value = elementConfig.value
                            -- Deselect other radio buttons in the same group
                            for _, otherElement in ipairs(luis.elements[layerName]) do
                                if otherElement.type == "RadioButton" and otherElement.group == element.group and otherElement ~= element then
                                    otherElement.value = false
                                end
                            end
                        elseif element.type == "DropDown" then
                            element:setValue(tonumber(elementConfig.value))
                        elseif element.type == "TextInput" then
                            element:setText(tostring(elementConfig.value or elementConfig.text))
                        end
                        
                        -- Update element state
                        luis.setElementState(layerName, i, elementConfig.value)
                    end
                end
            end
        end
    end
end

return luis
