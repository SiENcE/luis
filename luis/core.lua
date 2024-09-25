local json = require("luis.3rdparty.json")

local luis = {}

-- UI elements storage
luis.layers = {}
luis.elements = {}  -- Store all created elements
luis.elementStates = {}  -- Store states of stateful elements
luis.currentLayer = nil
luis.layerStack = {}
luis.enabledLayers = {}  -- Store enabled layers

-- Scaling
luis.baseWidth, luis.baseHeight = 1920, 1080
luis.scale = 1

-- Grid settings
luis.gridSize = 20
luis.showGrid = false
luis.showElementOutlines = false
luis.showLayerNames = false

--[[
love.graphics.newFont(fontsize, hinting mode)

normal - Default hinting. Should be preferred for typical antialiased fonts.
light - Results in fuzzier text but can sometimes preserve the original glyph shapes of the text better than normal hinting.
mono - Results in aliased / unsmoothed text with either full opacity or completely transparent pixels. Should be used when antialiasing is not desired for the font.
none - Disables hinting for the font. Results in fuzzier text.
]]--

-- Default theme
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

-- configuration
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
                    value = element.value or element.selectedIndex or element.text
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
                        if element.type == "Slider" then
                            element.value = elementConfig.value
                        elseif element.type == "Switch" or element.type == "CheckBox" then
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
                            element:setSelectedIndex(tonumber(elementConfig.value))
                        elseif element.type == "TextInput" then
                            element:setText(tostring(elementConfig.value))
                        end
                        
                        -- Update element state
                        luis.setElementState(layerName, i, elementConfig.value)
                    end
                end
            end
        end
    end
end

function luis.updateButtonsTheme(newTheme)
    for _, layer in pairs(luis.elements) do
        for _, element in ipairs(layer) do
            if element.type == "Button" then
                local buttonTheme = newTheme.button
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
	luis.updateButtonsTheme(newTheme)
end

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

-- Set currentLayer function
function luis.setCurrentLayer(layerName)
    if luis.layers[layerName] then
        -- Remove the layer if it's already in the stack
        for i, layer in ipairs(luis.layerStack) do
            if layer == layerName then
                table.remove(luis.layerStack, i)
                break
            end
        end
        -- Add the layer to the top of the stack
        table.insert(luis.layerStack, layerName)
        luis.currentLayer = layerName
        -- Ensure the current layer is also enabled
        luis.enabledLayers[layerName] = true
    end
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
        luis.enabledLayers[layerName] = false
    end
end

-- Check if a layer is enabled
function luis.isLayerEnabled(layerName)
    return luis.enabledLayers[layerName] == true
end

-- Toggle a layer's enabled state
function luis.toggleLayer(layerName)
    if luis.layers[layerName] then
        luis.enabledLayers[layerName] = not luis.enabledLayers[layerName]
    end
end

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

    table.insert(luis.elements[layerName], element)
    
    -- Initialize state for stateful elements (unchanged)
    if elementType == "Slider" or
       elementType == "Switch" or
       elementType == "CheckBox" or
       elementType == "RadioButton" or
       elementType == "DropDown" or
       elementType == "TextInput" then
        if not luis.elementStates[layerName] then
            luis.elementStates[layerName] = {}
        end
        luis.elementStates[layerName][#luis.elements[layerName]] = element.value
    end
    
    return element
end

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

    table.insert(luis.elements[layerName], element)
    
    -- Initialize state for stateful elements (unchanged)
    if elementType == "Slider" or
       elementType == "Switch" or
       elementType == "CheckBox" or
       elementType == "RadioButton" or
       elementType == "DropDown" or
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

local accumulator = 0
function luis.update(dt)
    accumulator = accumulator + dt
    if accumulator >= 1/60 then
        luis.flux.update(accumulator)
        accumulator = 0
    end

    local mx, my = love.mouse.getPosition()
    mx, my = mx / luis.scale, my / luis.scale
    
    for layerName, enabled in pairs(luis.enabledLayers) do
        if enabled and luis.elements[layerName] then
            for i, element in ipairs(luis.elements[layerName]) do
                if element.update then
                    element:update(mx, my)
                end
                -- Update state for stateful elements
                if element.type == "Slider" or
                   element.type == "Switch" or
                   element.type == "CheckBox" or
                   element.type == "RadioButton" or
                   element.type == "DropDown" or
                   element.type == "TextInput" then
                    luis.setElementState(layerName, i, element.value or element.selectedIndex or element.text)
                end
            end
        end
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

function luis.popLayer()
    if #luis.layerStack > 1 then
        table.remove(luis.layerStack)
        luis.currentLayer = luis.layerStack[#luis.layerStack]
		luis.toggleLayer(luis.currentLayer)
        return luis.currentLayer
    end
    return false
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

function luis.mousepressed(x, y, button, istouch)
    if button == 1 then  -- Left mouse button
        x, y = x / luis.scale, y / luis.scale
        for layerName, enabled in pairs(luis.enabledLayers) do
            if enabled and luis.elements[layerName] then
                for _, element in ipairs(luis.elements[layerName]) do
                    if element.click and element:click(x, y, button, istouch) then
                        return
                    end
                end
            end
        end
    end
end

function luis.mousereleased(x, y, button, istouch)
    if button == 1 then  -- Left mouse button
        x, y = x / luis.scale, y / luis.scale
        for layerName, enabled in pairs(luis.enabledLayers) do
            if enabled and luis.elements[layerName] then
                for _, element in ipairs(luis.elements[layerName]) do
                    if element.release then
                        element:release(x, y, button, istouch)
                    end
                end
            end
        end
    end
end

function luis.wheelmoved(x, y)
    local mx, my = love.mouse.getPosition()
    mx, my = mx / luis.scale, my / luis.scale
    for layerName, enabled in pairs(luis.enabledLayers) do
        if enabled and luis.elements[layerName] then
            for _, element in ipairs(luis.elements[layerName]) do
                if element.wheelmoved and element:wheelmoved(x, y) then
                    return
                end
            end
        end
    end
end

function luis.keypressed(key)
    if key == "tab" then
        luis.showGrid = not luis.showGrid
        luis.showElementOutlines = not luis.showElementOutlines
		luis.showLayerNames = not luis.showLayerNames
    else
		for layerName, enabled in pairs(luis.enabledLayers) do
			if enabled and luis.elements[layerName] then
				for _, element in ipairs(luis.elements[layerName]) do
					if (element.type == "TextInput" and element.active) or element.type == "FlexContainer" then
						element:keypressed(key)
						return
					end
				end
			end
		end
	end
end

function luis.updateScale()
    local w, h = love.graphics.getDimensions()
    luis.scale = math.min(w / luis.baseWidth, h / luis.baseHeight)
end

return luis
