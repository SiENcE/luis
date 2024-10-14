local initLuis = require("luis.init")
-- Direct this to your widgets folder.
local luis = initLuis("examples/complex_ui/widgets")

-- register flux in luis, because the widgets of complex_ui need this
luis.flux = require("examples.3rdparty.flux")

local canvases = {}
local layers = {"Layer1", "Layer2", "Layer3"}

-- Helper function to find index in a table
function table.indexOf(t, value)
    for k, v in ipairs(t) do
        if v == value then
            return k
        end
    end
    return nil
end

function love.load()
	love.window.setMode(1280, 720, {resizable=true, vsync=true})

	local buttonnames = { [1]={"Start Game", "Options", "Quit"}, [2]={"Continue", "New Game", "back"}, [3]={"Video Settings", "Sound Settings", "back"} }
    -- Set up layers and canvases
    for i, layerName in ipairs(layers) do
        luis.newLayer(layerName)
        luis.enableLayer(layerName)

        -- Create labels and icons for each layer
        luis.createElement(layerName, "Label", "This is " .. layerName, 14, 2, 2, 2)
        luis.createElement(layerName, "Icon", "examples/complex_ui/assets/images/icon.png", 2, 5, 2)
		luis.createElement(layerName, "Button", buttonnames[i][1], 10, 2, function() print("Start Game") end, function() end, 10, 10)
		luis.createElement(layerName, "Button", buttonnames[i][2], 10, 2, function() print("Start Game") end, function() end, 10+3, 10)
		luis.createElement(layerName, "Button", buttonnames[i][3], 10, 2, function() print("Start Game") end, function() end, 10+6, 10)

        -- Create a canvas for each layer
        canvases[layerName] = love.graphics.newCanvas(800, 600)
    end

    -- Set initial active layer
    luis.setCurrentLayer("Layer1")
end

function love.update(dt)
    luis.update(dt)
end

function love.resize(w, h)
    luis.updateScale()
end

-- draw only one layer to canvas
local function drawLayerToCanvas(layerName)
    love.graphics.setCanvas(canvases[layerName])
    love.graphics.clear()
    
    if layerName == luis.currentLayer then
        love.graphics.setColor(1, 1, 1, 1)
    else
        love.graphics.setColor(1, 1, 1, 0.7)
    end

    for layer, bool in pairs(luis.enabledLayers) do
		luis.disableLayer(layer)
    end
	luis.enableLayer(layerName)
	luis.draw()
    for layer, bool in pairs(luis.enabledLayers) do
		luis.enableLayer(layer)
    end

    love.graphics.setCanvas()
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)

    -- Draw each layer to its canvas
    for _, layerName in ipairs(layers) do
        drawLayerToCanvas(layerName)
    end

    -- Draw canvases in 3D space
    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    
    for i = #layers, 1, -1 do
        local layerName = layers[i]
        love.graphics.push()
        
        -- Apply 3D transformation
        local angle = math.rad(15)  -- 30-degree angle for perspective
        local offsetX = (i - 1) * 100
        local offsetY = (i - 1) * 50
        
        love.graphics.translate(-offsetX, -offsetY)
        love.graphics.rotate(-angle, 1, 0, 0)  -- Rotate around X-axis
        love.graphics.rotate(angle / 2, 0, 1, 0)  -- Slight rotation around Y-axis
        
        -- Draw the canvas
        love.graphics.setColor(1, 1, 1, layerName == luis.currentLayer and 1 or 0.2)
        love.graphics.draw(canvases[layerName], -400, -300)
        
        love.graphics.pop()
    end
    
    love.graphics.pop()
end

function love.keypressed(key, scancode, isrepeat)
    if key == "lctrl" then
        local currentIndex = table.indexOf(layers, luis.currentLayer)
        local nextIndex = (currentIndex % #layers) + 1
        luis.setCurrentLayer(layers[nextIndex])
    elseif key == "tab" then
        luis.showGrid = not luis.showGrid
        luis.showElementOutlines = not luis.showElementOutlines
        luis.showLayerNames = not luis.showLayerNames
    elseif key == "down" then
        luis.moveFocus("next")
    elseif key == "up" then
        luis.moveFocus("previous")
    else
        luis.keypressed(key, scancode, isrepeat)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    luis.mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    luis.mousereleased(x, y, button, istouch, presses)
end
