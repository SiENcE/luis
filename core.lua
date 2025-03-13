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
luis.activeJoysticks = {}
luis.deadzone = 0.2
luis.dpadSpeed = 300
-- Variables for joystick navigation
luis.currentFocus = nil
luis.focusableElements = {}
luis.joystickButtonStates = {}

-- mouse
luis.clickCooldown = 0

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
	system = {
		font = love.graphics.newFont(14)
	},
    background = {
        color = {0.1, 0.1, 0.1},
    },
    text = {
        color = {1, 1, 1},
        font = love.graphics.newFont(14, "normal"),
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
        padding = 0,
        handleSize = 20,
        handleColor = {0.5, 0.5, 0.5, 1}
	},
	node = {
		textColor = {1,1,1},
		backgroundColor = {0.1, 0.1, 0.1},
		borderColorHover = {0.25, 0.25, 0.25, 1},
		borderColor = {0.25, 0.25, 0.25, 1},
		inputPortColor = {0,1,0},
		outputPortColor = {1,0,0},
		connectionColor = {0,1,0},
		connectingColor = {0.7,0.7,0.7},
	},
	colorpicker = {
		cornerRadius = 4,
		backgroundColor = {0.2, 0.2, 0.2, 0.8},
		borderColor = {0.3, 0.3, 0.3, 1},
		font = love.graphics.newFont(8, "normal"),
	},
	dialogueWheel = {
		backgroundColor = {0.2, 0.2, 0.2, 0.8},
        highlightColor = {0.4, 0.4, 0.8, 0.9},
        disabledColor = {0.3, 0.3, 0.3, 0.8},
        textColor = {1, 1, 1, 1},
		font = love.graphics.newFont(24, "normal"),
        disabledTextColor = {0.5, 0.5, 0.5, 1},
        selectedColor = {0.6, 0.6, 1, 0.9},
        focusColor = {1, 1, 1, 0.5}
    }
}

--==============================================
-- Layer handling
--==============================================

function luis.newLayer(layerName)
    if luis.layers[layerName] then
        print("Warning: Layer '" .. layerName .. "' already exists.")
        return false
    end
    local layer = {
        name = layerName,
        elements = {}
    }
    luis.layers[layerName] = layer
    luis.elements[layerName] = {}
    luis.elementStates[layerName] = {}
    if luis.currentLayer == nil then
        luis.currentLayer = layerName
    end
    table.insert(luis.layerStack, layerName)
    --print("Layer '" .. layerName .. "' created successfully.")
    return true
end

function luis.setCurrentLayer(layerName)
    if not luis.layers[layerName] then
        print("Error: Layer '" .. layerName .. "' does not exist.")
        return false
    end
    luis.updateLastFocusedWidget(luis.currentLayer)
    luis.disableLayer(luis.currentLayer)
    luis.currentLayer = layerName
    luis.enableLayer(layerName)
    luis.restoreFocus(layerName)
    -- Update layer stack
    for i, layer in ipairs(luis.layerStack) do
        if layer == layerName then
            table.remove(luis.layerStack, i)
            break
        end
    end
    table.insert(luis.layerStack, layerName)
    --print("Current layer set to '" .. layerName .. "'.")
    return true
end

function luis.popLayer()
    if #luis.layerStack <= 1 then
        print("Error: Cannot remove the last layer.")
        return false
    end
    local removedLayer = table.remove(luis.layerStack)
    luis.updateLastFocusedWidget(removedLayer)
    luis.disableLayer(removedLayer)
    luis.currentLayer = luis.layerStack[#luis.layerStack]
    luis.enableLayer(luis.currentLayer)
    luis.restoreFocus(luis.currentLayer)
    --print("Top layer '" .. removedLayer .. "' removed.")
    return removedLayer
end

function luis.enableLayer(layerName)
    if not luis.layers[layerName] then
        print("Error: Layer '" .. layerName .. "' does not exist.")
        return false
    end
    luis.enabledLayers[layerName] = true
    --print("Layer '" .. layerName .. "' enabled.")
    return true
end

function luis.disableLayer(layerName)
    if not luis.layers[layerName] then
        print("Error: Layer '" .. layerName .. "' does not exist.")
        return false
    end
    luis.updateLastFocusedWidget(layerName)
    luis.enabledLayers[layerName] = false
    --print("Layer '" .. layerName .. "' disabled.")
    return true
end

function luis.toggleLayer(layerName)
    if not luis.layers[layerName] then
        print("Error: Layer '" .. layerName .. "' does not exist.")
        return false
    end
    luis.enabledLayers[layerName] = not luis.enabledLayers[layerName]
    --local status = luis.enabledLayers[layerName] and "enabled" or "disabled"
    --print("Layer '" .. layerName .. "' " .. status .. ".")
    return true
end

function luis.isLayerEnabled(layerName)
    if not luis.layers[layerName] then
        print("Error: Layer '" .. layerName .. "' does not exist.")
        return false
    end
    return luis.enabledLayers[layerName] == true
end

function luis.removeLayer(layerName)
    if not luis.layers[layerName] then
        print("Error: Layer '" .. layerName .. "' does not exist.")
        return false
    end

    luis.layers[layerName] = nil
    luis.elements[layerName] = nil
    luis.elementStates[layerName] = nil
    luis.enabledLayers[layerName] = nil

    for i, layer in ipairs(luis.layerStack) do
        if layer == layerName then
            table.remove(luis.layerStack, i)
            break
        end
    end

    if luis.currentLayer == layerName then
        if #luis.layerStack > 0 then
            luis.currentLayer = luis.layerStack[#luis.layerStack]
        else
            luis.currentLayer = nil
        end
    end

    luis.updateFocusableElements()
    --print("Layer '" .. layerName .. "' removed successfully.")
    return true
end

--==============================================
-- Widget handling
--==============================================

function luis.createElement(layerName, widgetType, ...)
    if not luis.elements[layerName] then
        luis.elements[layerName] = {}
    end

    local element
    if widgetType == "FlexContainer" and type((...)) == "table" and (...).type == "FlexContainer" then
        -- If it's a pre-existing FlexContainer, use it directly
        element = (...)
	else
		if luis["new" .. widgetType] then
			-- Otherwise, create a new element as before
			element = luis["new" .. widgetType](...)
		else
			print("ERROR: no widgetType with the following name registered:", widgetType)
			return false
		end
    end

    luis.insertElement(layerName, element)
	print('createElement:', layerName, #luis.elements[layerName], widgetType)
    
    return element
end

function luis.setElementState(layerName, index, value)
    -- Update the actual element's value
    if luis.elements[layerName] and luis.elements[layerName][index] then
        luis.elements[layerName][index].value = value
    else
		if not luis.elements[layerName] then
			print("ERROR: cannot setElementState - layername not found - ", layerName, index, value)
		elseif not luis.elements[layerName][index] then
			print("ERROR: cannot setElementState - widget index not found - ", layerName, index, value)
		else
			print("ERROR: cannot setElementState ", layerName, index, value)
		end
	end
end

function luis.getElementState(layerName, index)
    if luis.elementStates[layerName] and luis.elementStates[layerName][index] then
        return luis.elementStates[layerName][index]
    end
    return nil
end

function luis.insertElement(layerName, element)
    if not luis.elements[layerName] then
        luis.elements[layerName] = {}
    end

    -- Add default z-index
    element.zIndex = element.zIndex or 1

    table.insert(luis.elements[layerName], element)

    -- Initialize state for stateful elements
    local widgetType = element.type
    if widgetType == "Slider" or
       widgetType == "Switch" or
       widgetType == "CheckBox" or
	   widgetType == "DialogueWheel" or
       widgetType == "RadioButton" or
       widgetType == "DropDown" or
       widgetType == "TextInput" or
       widgetType == "TextInputMultiLine" or
	   widgetType == "ProgressBar" then
        if not luis.elementStates[layerName] then
            luis.elementStates[layerName] = {}
        end
        luis.elementStates[layerName][#luis.elements[layerName]] = element.value
    end
end

function luis.removeElement(layerName, elementToRemove)
    if not luis.elements[layerName] then
        print("Error: Layer '" .. layerName .. "' does not exist.")
        return false
    end

    for i, element in ipairs(luis.elements[layerName]) do
        if element == elementToRemove then
            -- Remove the element from the elements table
            table.remove(luis.elements[layerName], i)

            -- Remove the element's state if it exists
            if luis.elementStates[layerName] then
                table.remove(luis.elementStates[layerName], i)
            end

            -- Update focusable elements if necessary
            luis.updateFocusableElements()

            -- If the removed element was focused, move focus to the next element
            if luis.currentFocus == elementToRemove then
                luis.moveFocus("next")
            end

            print("Element removed successfully from layer '" .. layerName .. "'.")
            return true
        end
    end

    print("Error: Element not found in layer '" .. layerName .. "'.")
    return false
end

-- Function to check if an element exists in a layer
function luis.elementExists(layerName, element)
	-- Check if the layer exists
    if not luis.elements[layerName] then
        return false
    end

    -- If element is nil, return false
    if not element then
        return false
    end

	-- Check for direct reference match
    for _, existingElement in ipairs(luis.elements[layerName]) do
        if existingElement == element then
            return true
        end
    end

    return false
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

function luis.getGridSize()
	return luis.gridSize
end

function luis.updateScale()
    local w, h = love.graphics.getDimensions()
    luis.scale = math.min(w / luis.baseWidth, h / luis.baseHeight)
end

function luis.update(dt)
    if luis.clickCooldown > 0 then
        luis.clickCooldown = math.max(0, luis.clickCooldown - dt)
    end

    local mx, my = love.mouse.getPosition()
    mx, my = mx / luis.scale, my / luis.scale

    -- Joystick navigation
    local jx, jy = luis.getJoystickAxis(1, 'leftx'), luis.getJoystickAxis(1, 'lefty')
    if math.abs(jx) > luis.deadzone or math.abs(jy) > luis.deadzone then
        mx, my = mx + jx * 10, my + jy * 10  -- Adjust speed as needed
    end

--[[
	=> this must be now implemented in the main program!

    -- Check for joystick button presses for focus navigation
    if luis.joystickJustPressed(1, 'dpdown') then
        luis.moveFocus("next")
    elseif luis.joystickJustPressed(1, 'dpup') then
        luis.moveFocus("previous")
    end
]]--

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
				   element.type == "DialogueWheel" or
                   element.type == "RadioButton" or
                   element.type == "DropDown" or
                   element.type == "TextInput" or
                   element.type == "TextInputMultiLine" or
				   element.type == "ProgressBar" then
                    luis.setElementState(layerName, i, element.value or element.text)
                end
            end
        end
    end

    -- Update focused element
    luis.updateFocusableElements()
    
	-- Update the focus of all elements that have implemented the updateFocus() method
    if luis.currentFocus and luis.currentFocus.updateFocus then
        luis.currentFocus:updateFocus(jx, jy)
    end
end

-- Element debug outlines
function luis.drawElementOutline(element)
    love.graphics.setColor(1, 1, 1, 0.7)
	local font_backup = love.graphics.getFont()
	local font = love.graphics.newFont(12, "mono")
	love.graphics.setFont(font)
	local text = element.position.x/luis.gridSize+1 .. " x "	-- we have to add +1 as the grid is indexed at 1,1 not 0,0 !!
	love.graphics.print(text, element.position.x+2, element.position.y)
	love.graphics.print(element.position.y/luis.gridSize+1, element.position.x+string.len(text)*4+12, element.position.y)

	love.graphics.print(element.width/luis.gridSize, element.position.x+element.width-22, element.position.y)
	love.graphics.print(element.height/luis.gridSize, element.position.x+element.width-22, element.position.y+element.height-16)

    love.graphics.rectangle("line", element.position.x, element.position.y, element.width, element.height)
	love.graphics.setFont(font_backup)
end

-- draw, z-ordering, debug-view
function luis.draw()
    love.graphics.push()
    love.graphics.scale(luis.scale, luis.scale)
    love.graphics.setBackgroundColor(luis.theme.background.color)

    -- Create a flat list of all elements from enabled layers
    local allElements = {}
    for layerName, enabled in pairs(luis.enabledLayers) do
        if enabled and luis.elements[layerName] then
            for _, element in ipairs(luis.elements[layerName]) do
                -- Include layer information with the element for debugging
                table.insert(allElements, {
                    element = element,
                    layer = layerName
                })
            end
        end
    end

    -- Sort all elements by z-index, regardless of layer
    table.sort(allElements, function(a, b)
        local aIndex = a.element.zIndex or 1
        local bIndex = b.element.zIndex or 1
        return aIndex < bIndex
    end)

    -- Draw all elements in z-index order
    for _, item in ipairs(allElements) do
        item.element:draw()
        
        -- Draw element outlines if enabled (DebugView)
        if luis.showElementOutlines then
            luis.drawElementOutline(item.element)
        end
    end

    -- Draw grid if enabled (DebugView)
    if luis.showGrid then
        love.graphics.setColor(luis.theme.grid.color)
        for i = 0, luis.baseWidth, luis.gridSize do
            love.graphics.line(i, 0, i, luis.baseHeight)
        end
        for j = 0, luis.baseHeight, luis.gridSize do
            love.graphics.line(0, j, luis.baseWidth, j)
        end
    end

    -- Draw layer names (DebugView)
    if luis.showLayerNames then
        local font_backup = love.graphics.getFont()
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.setFont(luis.theme.system.font)
        local counter = 0
        for layerName, enabled in pairs(luis.enabledLayers) do
            if enabled then
                local layerWidth = luis.theme.system.font:getWidth(layerName)
                love.graphics.print(layerName, 10+layerWidth*counter, 10+20*counter)
                counter = counter + 1
            end
        end

        for i, element in ipairs(luis.focusableElements) do
            local text = (element.text or element.type) .. " (" .. i .. ")"
            if element == luis.currentFocus then
                text = text .. " <-- current"
            end
            love.graphics.print(text, 10, 50+i*luis.theme.system.font:getHeight())
        end
        love.graphics.setFont(font_backup)
    end

    love.graphics.pop()
end

--==============================================
-- Input handling
--==============================================

-- generic Input handling for "Mouse (click/release)" and "Gamepad (gamepadpressed/gamepadreleased)"
-- this Inputs are not pushed recursivly like keypressed/keyreleased & textinput!!
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
			if (inputFunction == "click" or inputFunction == "release" or inputFunction == "wheelmoved") and
				element[inputFunction] and x and y and element[inputFunction](element, x, y, ...) then
                return true  -- Stop propagation if an element handled the input
			-- handle gamepad
			elseif (inputFunction == "gamepadpressed" or inputFunction == "gamepadreleased") and
			   element[inputFunction] and element[inputFunction](element, ...) then
				return true  -- Stop propagation if an element handled the input
			elseif (inputFunction == "keypressed" or inputFunction == "keyreleased") and
			   element[inputFunction] and element[inputFunction](element, ...) then
				return true  -- Stop propagation if an element handled the input
			else
				--print("ERROR: unhandled Input", layerName, x, y, inputFunction)
			end
        end
    end
    return false
end

------------------------------------------------
-- Keyboard input handling
------------------------------------------------

-- keypressed pushes recursiv across all widgets
function luis.keypressed(key, scancode, isrepeat)
	local function handleKeyPressed(elements)
		for _, element in ipairs(elements) do
			if element.type == "FlexContainer" then
				if handleKeyPressed(element.children) then
					return true
				end
			elseif (element.keypressed and element.active) or element.keypressed then
				element:keypressed(key, scancode, isrepeat)
				return true
			end
		end
		return false
	end

	for layerName, enabled in pairs(luis.enabledLayers) do
--		if enabled and luis.elements[layerName] then
--			if handleKeyPressed(luis.elements[layerName]) then
--				return
--			end
--		end
		if handleLayerInput(layerName, nil, nil, "keypressed", key, scancode, isrepeat) then
			return true
		end
	end
	return false
end

function luis.keyreleased( key, scancode )
	local function handleKeyReleased(elements)
		for _, element in ipairs(elements) do
			if element.type == "FlexContainer" then
				if handleKeyReleased(element.children) then
					return true
				end
			elseif (element.keyreleased and element.active) or element.keyreleased then
				element:keyreleased( key, scancode )
				return true
			end
		end
		return false
	end

	for layerName, enabled in pairs(luis.enabledLayers) do
--		if enabled and luis.elements[layerName] then
--			if handleKeyReleased(luis.elements[layerName]) then
--				return
--			end
--		end
		if handleLayerInput(layerName, nil, nil, "keyreleased", key, scancode, isrepeat) then
			return true
		end
	end
	return false
end

-- textinput pushes recursiv across all widgets
function luis.textinput(text)
    local function handleTextInput(elements)
        for _, element in ipairs(elements) do
            if element.type == "FlexContainer" then
                if handleTextInput(element.children) then
                    return true
                end
            elseif element.textinput and element.active then
                element:textinput(text)
                return true
            end
        end
        return false
    end

    for layerName, enabled in pairs(luis.enabledLayers) do
        if enabled and luis.elements[layerName] then
            if handleTextInput(luis.elements[layerName]) then
                return
            end
        end
    end
end

------------------------------------------------
-- Mouse input handling
------------------------------------------------
--[[
function luis.mousepressed(x, y, button, istouch, presses)
    x, y = x / luis.scale, y / luis.scale
    for layerName, _ in pairs(luis.enabledLayers) do
        if handleLayerInput(layerName, x, y, "click", button, istouch, presses) then
            return true
        end
    end
    return false
end
]]--
--[[
function luis.mousepressed(x, y, button, istouch, presses)
    x, y = x / luis.scale, y / luis.scale
    if luis.clickCooldown > 0 then return false end
    
    for layerName, _ in pairs(luis.enabledLayers) do
        if handleLayerInput(layerName, x, y, "click", button, istouch, presses) then
            luis.clickCooldown = 0.2  -- 200ms cooldown
            return true
        end
    end
    return false
end
]]--

-- Note: It's a common problem in UI frameworks where elements like text inputs and dropdowns need to deactivate when clicking elsewhere.
-- Thanks why you need to implement this 'onGlobalClick' function in your dropDown or textInput widgets!
function luis.handleGlobalClick(x, y, button, istouch, presses)
    -- Notify all elements across all enabled layers that a click occurred
    for layerName, enabled in pairs(luis.enabledLayers) do
        if enabled and luis.elements[layerName] then
            for _, element in ipairs(luis.elements[layerName]) do
                if element.onGlobalClick then
                    element:onGlobalClick(x, y, button, istouch, presses)
                end
            end
        end
    end
end

function luis.mousepressed(x, y, button, istouch, presses)
    x, y = x / luis.scale, y / luis.scale
    if luis.clickCooldown > 0 then return false end
    
    -- First, allow all elements to respond to the global click event
    luis.handleGlobalClick(x, y, button, istouch, presses)
    
    -- Then process regular click handling with z-index priority preserved
    for layerName, _ in pairs(luis.enabledLayers) do
        if handleLayerInput(layerName, x, y, "click", button, istouch, presses) then
            luis.clickCooldown = 0.2  -- 200ms cooldown
            return true
        end
    end
    return false
end

function luis.mousereleased(x, y, button, istouch, presses)
    x, y = x / luis.scale, y / luis.scale
    for layerName, _ in pairs(luis.enabledLayers) do
        if handleLayerInput(layerName, x, y, "release", button, istouch, presses) then
            return true
        end
    end
    return false
end

function luis.wheelmoved(x, y)
    for layerName, _ in pairs(luis.enabledLayers) do
        if handleLayerInput(layerName, x, y, "wheelmoved") then
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
		luis.setCurrentFocus(element)
    else
		-- Fall back to default focus behavior
		luis.setCurrentFocus(nil)	-- set currentFocus to nil, if to focus to restore
		luis.updateFocusableElements()
    end
end

-- Update the list of focusable elements
function luis.updateFocusableElements()
	if (#luis.activeJoysticks == 0) then return end

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
		luis.setCurrentFocus(luis.focusableElements[1])
	end
	
	-- after focus change, update all button colors
	luis.updateElementTheme(luis.theme)
end

-- Move focus in a direction
function luis.moveFocus(direction)
    if (#luis.activeJoysticks == 0) then return end
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
-- Joystick/Gamepad input handling
------------------------------------------------

-- initJoysticks function
function luis.initJoysticks()
    local joysticks = love.joystick.getJoysticks()
    for i, joystick in ipairs(joysticks) do
        luis.activeJoysticks[i] = joystick
    end

    -- If there are no joysticks, reset focus-related variables
    if #joysticks == 0 then
        luis.setCurrentFocus(nil)
        luis.focusableElements = {}
        for layerName, _ in pairs(luis.layers) do
            luis.lastFocusedWidget[layerName] = nil
        end
    end
end

-- just to cleanup the focus
function luis.removeJoystick(joystick)
    luis.initJoysticks()  -- Reinitialize joysticks when one is removed
    
    -- Check if the removed joystick was the active one
    local removedId
    for id, activeJoystick in pairs(luis.activeJoysticks) do
        if joystick == activeJoystick then
            removedId = id
            break
        end
    end
    
    if removedId then
        luis.activeJoysticks[removedId] = nil
        
        -- If there are no more active joysticks, remove focus and clean up
        if next(luis.activeJoysticks) == nil then
            luis.setCurrentFocus(nil)
            luis.updateFocusableElements()
            
            -- Clean up luis.lastFocusedWidget
            for layerName, _ in pairs(luis.layers) do
                luis.lastFocusedWidget[layerName] = nil
            end
        end
    end
end

-- Set active joystick
function luis.setActiveJoystick(id, joystick)
    luis.activeJoysticks[id] = joystick
end

function luis.getActiveJoystick(id)
    return luis.activeJoysticks[id]
end

-- joystick-related functions to use joystick ID
function luis.joystickJustPressed(id, button)
    local isPressed = luis.isJoystickPressed(id, button)
    local justPressed = isPressed and not luis.joystickButtonStates[id .. button]
    luis.joystickButtonStates[id .. button] = isPressed
    return justPressed
end

-- Check if a Joystick or Gamepad button is pressed
function luis.isJoystickPressed(id, button)
    return luis.activeJoysticks[id] and luis.activeJoysticks[id]:isGamepadDown(button)
end

-- Get Joystick or Gamepad axis value
function luis.getJoystickAxis(id, axis)
    if luis.activeJoysticks[id] then
        local value = luis.activeJoysticks[id]:getGamepadAxis(axis)
        return math.abs(value) > luis.deadzone and value or 0
    end
    return 0
end

function luis.gamepadpressed(joystick, button)
print('luis.gamepadpressed',joystick, button)
    for id, activeJoystick in pairs(luis.activeJoysticks) do
        if joystick == activeJoystick then
			-- First, check if the current focus is a FlexContainer
            if luis.currentFocus and luis.currentFocus.gamepadpressed and (luis.currentFocus.type == "FlexContainer" or luis.currentFocus.type == "DropDown") then
                if luis.currentFocus:gamepadpressed(id, button) then
                    return true
                end
            end

			-- If FlexContainer didn't handle the input, check other elements
            for layerName, _ in pairs(luis.enabledLayers) do
                if handleLayerInput(layerName, nil, nil, "gamepadpressed", id, button) then
                    return true
                end
            end
        end
    end
    return false
end

-- Function for joystick button release
function luis.gamepadreleased(joystick, button)
    for id, activeJoystick in pairs(luis.activeJoysticks) do
        if joystick == activeJoystick then
			-- First, check if the current focus is a FlexContainer
            if luis.currentFocus and luis.currentFocus.gamepadreleased and (luis.currentFocus.type == "FlexContainer" or luis.currentFocus.type == "DropDown") then
                if luis.currentFocus:gamepadreleased(id, button) then
                    return true
                end
            end

			-- If FlexContainer didn't handle the input, check other elements
            for layerName, _ in pairs(luis.enabledLayers) do
                if handleLayerInput(layerName, nil, nil, "gamepadreleased", id, button) then
                    return true
                end
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

function luis.getConfig()
    local config = {}
    for layerName, elements in pairs(luis.elements) do
        config[layerName] = {}
        for i, element in ipairs(elements) do
            if element.type == "Slider" or
               element.type == "Switch" or
               element.type == "CheckBox" or
			   element.type == "DialogueWheel" or
               element.type == "RadioButton" or
               element.type == "DropDown" or
               element.type == "TextInput" or
               --element.type == "TextInputMultiLine" or
               element.type == "ProgressBar" then  -- Added ProgressBar
                config[layerName][i] = {
                    type = element.type,
                    value = tostring(element.value or false),
                }
            end
        end
    end

    -- Convert elementStates to a new table with string keys
    local config = deepCopyWithStringKeys(config)
	return config
end

local function toboolean(str)
    local bool = false
    if str == "true" then
        bool = true
    end
    return bool
end

function luis.setConfig(config)
	for layerName, elements in pairs(config) do
		if luis.elements[layerName] then
			for i, elementConfig in pairs(elements) do
				local element = luis.elements[layerName][tonumber(i)]
				
				if element and element.type == elementConfig.type then
					if element.type == "Slider" then					    -- works!
						element.value = tonumber(elementConfig.value)
						element:setValue(tonumber(elementConfig.value))
					elseif element.type == "Switch" then					-- works!
						element.value = toboolean(elementConfig.value)
						element:setValue(toboolean(elementConfig.value))
					elseif element.type == "CheckBox" then					-- works!
						element.value = toboolean(elementConfig.value)
						element:setValue(toboolean(elementConfig.value))
					elseif element.type == "DialogueWheel" then				-- works!
						element.value = tonumber(elementConfig.value)
						element:setValue(tonumber(elementConfig.value))
					elseif element.type == "RadioButton" then
						element.value = toboolean(elementConfig.value)
						if element.value then
							element:setValue(element.value)
						end
					elseif element.type == "DropDown" then				    -- works!
						element.value = tonumber(elementConfig.value)
						element:setValue(tonumber(elementConfig.value))
					elseif element.type == "TextInput" then				    -- works!
						element.value = tostring(elementConfig.value)
						element:setText(tostring(elementConfig.value))
					--elseif element.type == "TextInputMultiLine" then
					--	element:setText(tostring(elementConfig.value))
					elseif element.type == "ProgressBar" then				-- works!
						element.value = tonumber(elementConfig.value)+0.0
						element:setValue(tonumber(elementConfig.value)+0.0)
					end
					
					-- Update element state
					if element.value then
						luis.setElementState(layerName, tonumber(i), element.value)
					end
				end
			end
		end
	end
end

return luis
