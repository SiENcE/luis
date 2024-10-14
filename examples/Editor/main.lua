local initLuis = require("luis.init")
-- Direct this to your widgets folder.
local luis = initLuis("examples/complex_ui/widgets")

-- register flux in luis, because the widgets of complex_ui need this
luis.flux = require("examples.3rdparty.flux")

local alternativeTheme = require("examples.complex_ui.assets.themes.alternativeTheme")
alternativeTheme.text.font = love.graphics.newFont("examples/complex_ui/assets/fonts/Monocraft.ttf", 18)

local editor = {
    currentLayer = "main",
    selectedWidget = nil,
    placingWidget = false,
    resizingWidget = false,
    movingWidget = false,
    widgets = {},
    widgetTypes = {"Button", "Label", "Icon", "Slider", "Switch", "CheckBox", "RadioButton", "DropDown", "TextInput", "TextInputMultiLine", "ProgressBar"},
    gridSize = 20,
    startX = 0,
    startY = 0
}

function love.load()
    love.window.setMode(1280, 720, {resizable=true, vsync=true})
    luis.setGridSize(editor.gridSize)
    luis.newLayer(editor.currentLayer)
    luis.enableLayer(editor.currentLayer)

    -- Create toolbar buttons
    for i, widgetType in ipairs(editor.widgetTypes) do
        luis.createElement(editor.currentLayer, "Button", widgetType, 100/luis.gridSize, 30/luis.gridSize, function()
            editor.selectedWidget = widgetType
            editor.placingWidget = true
        end, function() end, 10, (10 + (i-1) * 6) )
    end
end

function love.update(dt)
    luis.updateScale()

    luis.update(dt)

    local mx, my = love.mouse.getPosition()
    mx, my = mx / luis.scale, my / luis.scale

    if editor.placingWidget and editor.selectedWidget then
        if love.mouse.isDown(1) then
            local gridX = math.floor(mx / editor.gridSize) * editor.gridSize /2
            local gridY = math.floor(my / editor.gridSize) * editor.gridSize /2
            local widgetWidth = editor.gridSize * 5
            local widgetHeight = editor.gridSize * 2
            
            local widget
            if editor.selectedWidget == "Button" then
                widget = luis.createElement(editor.currentLayer, "Button", editor.selectedWidget, widgetWidth / luis.gridSize, widgetHeight / luis.gridSize, function() end, function() end, gridX / luis.gridSize + 1, gridY / luis.gridSize + 1)
            elseif editor.selectedWidget == "Label" then
                widget = luis.createElement(editor.currentLayer, "Label", editor.selectedWidget, widgetWidth / luis.gridSize, widgetHeight / luis.gridSize, gridX / luis.gridSize + 1, gridY / luis.gridSize + 1, "left")
            elseif editor.selectedWidget == "Icon" then
                widget = luis.createElement(editor.currentLayer, "Icon", "examples/complex_ui/assets/images/icon.png", widgetWidth / luis.gridSize, gridX / luis.gridSize + 1, gridY / luis.gridSize + 1)
            elseif editor.selectedWidget == "Slider" then
                widget = luis.createElement(editor.currentLayer, "Slider", 0, 100, 50, widgetWidth / luis.gridSize, widgetHeight / luis.gridSize, function(value) end, gridX / luis.gridSize + 1, gridY / luis.gridSize + 1)
            elseif editor.selectedWidget == "Switch" then
                widget = luis.createElement(editor.currentLayer, "Switch", false, widgetWidth / luis.gridSize, widgetHeight / luis.gridSize, function(state) end, gridX / luis.gridSize + 1, gridY / luis.gridSize + 1)
            elseif editor.selectedWidget == "CheckBox" then
                widget = luis.createElement(editor.currentLayer, "CheckBox", false, widgetWidth / luis.gridSize, function(state) end, gridX / luis.gridSize + 1, gridY / luis.gridSize + 1)
            elseif editor.selectedWidget == "RadioButton" then
                widget = luis.createElement(editor.currentLayer, "RadioButton", "group1", false, widgetWidth / luis.gridSize, function(state) end, gridX / luis.gridSize + 1, gridY / luis.gridSize + 1)
            elseif editor.selectedWidget == "DropDown" then
                widget = luis.createElement(editor.currentLayer, "DropDown", {"Option 1", "Option 2", "Option 3"}, 1, widgetWidth / luis.gridSize+3, widgetHeight / luis.gridSize, function(selectedItem) end, gridX / luis.gridSize + 1, gridY / luis.gridSize + 1, 2)
            elseif editor.selectedWidget == "TextInput" then
                widget = luis.createElement(editor.currentLayer, "TextInput", widgetWidth / luis.gridSize, widgetHeight / luis.gridSize, "Input text", function(text) end, gridX / luis.gridSize + 1, gridY / luis.gridSize + 1)
            elseif editor.selectedWidget == "TextInputMultiLine" then
                widget = luis.createElement(editor.currentLayer, "TextInputMultiLine", widgetWidth / luis.gridSize, widgetHeight / luis.gridSize, "Input multiline text", function(text) end, gridX / luis.gridSize + 1, gridY / luis.gridSize + 1)
            elseif editor.selectedWidget == "ProgressBar" then
                widget = luis.createElement(editor.currentLayer, "ProgressBar", 0.75, widgetWidth / luis.gridSize, widgetHeight / luis.gridSize, gridX / luis.gridSize + 1, gridY / luis.gridSize + 1)
            end
            
            if widget then
				widget.click = function() end
				widget.release = function() end

                table.insert(editor.widgets, widget)
            end
            editor.placingWidget = false
            editor.selectedWidget = nil
        end
    elseif editor.movingWidget then
        local gridX = math.floor(mx / editor.gridSize) * editor.gridSize
        local gridY = math.floor(my / editor.gridSize) * editor.gridSize
        editor.movingWidget.position.x = gridX
        editor.movingWidget.position.y = gridY
    elseif editor.resizingWidget then
        local gridX = math.floor(mx / editor.gridSize) * editor.gridSize
        local gridY = math.floor(my / editor.gridSize) * editor.gridSize
        editor.resizingWidget.width = math.max(editor.gridSize, gridX - editor.resizingWidget.position.x)
        editor.resizingWidget.height = math.max(editor.gridSize, gridY - editor.resizingWidget.position.y)
    end
	luis.setTheme(alternativeTheme)
end

function love.draw()
    luis.draw()

    -- Draw widget outlines
    love.graphics.setColor(1, 1, 0, 0.5)
    for _, widget in ipairs(editor.widgets) do
        love.graphics.rectangle("line", widget.position.x * luis.scale, widget.position.y * luis.scale, widget.width * luis.scale, widget.height * luis.scale)
    end

    -- Draw placing preview
    if editor.placingWidget and editor.selectedWidget then
        local mx, my = love.mouse.getPosition()
        local gridX = math.floor(mx / editor.gridSize) * editor.gridSize
        local gridY = math.floor(my / editor.gridSize) * editor.gridSize
        love.graphics.setColor(0, 1, 0, 0.5)
        love.graphics.rectangle("fill", gridX, gridY, editor.gridSize * 5, editor.gridSize * 2)
    end

    -- Highlight selected widget
    if editor.movingWidget then
        love.graphics.setColor(0, 1, 1, 0.5)
        love.graphics.rectangle("line", 
            editor.movingWidget.position.x * luis.scale, 
            editor.movingWidget.position.y * luis.scale, 
            editor.movingWidget.width * luis.scale, 
            editor.movingWidget.height * luis.scale
        )
    elseif editor.resizingWidget then
        love.graphics.setColor(0, 1, 1, 0.5)
        love.graphics.rectangle("line", 
            editor.resizingWidget.position.x * luis.scale, 
            editor.resizingWidget.position.y * luis.scale, 
            editor.resizingWidget.width * luis.scale, 
            editor.resizingWidget.height * luis.scale
        )
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    x, y = x / luis.scale, y / luis.scale
    if not luis.mousepressed(x, y, button, istouch, presses) then
        for _, widget in ipairs(editor.widgets) do
            if x >= widget.position.x and x <= widget.position.x + widget.width and
               y >= widget.position.y and y <= widget.position.y + widget.height then
                if button == 1 then  -- Left mouse button
                    editor.movingWidget = widget
                    editor.startX = x - widget.position.x
                    editor.startY = y - widget.position.y
                elseif button == 2 then  -- Right mouse button
                    editor.resizingWidget = widget
                    editor.startX = x
                    editor.startY = y
                end
                break
            end
        end
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    x, y = x / luis.scale, y / luis.scale
    luis.mousereleased(x, y, button, istouch, presses)
    if button == 1 then
        editor.movingWidget = nil
    elseif button == 2 then
        editor.resizingWidget = nil
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        editor.placingWidget = false
        editor.selectedWidget = nil
        editor.movingWidget = nil
        editor.resizingWidget = nil
    elseif key == "delete" then
        for i = #editor.widgets, 1, -1 do
            local widget = editor.widgets[i]
            if widget == editor.movingWidget or widget == editor.resizingWidget then
                luis.removeElement(editor.currentLayer, widget)
                table.remove(editor.widgets, i)
                editor.movingWidget = nil
                editor.resizingWidget = nil
                break
            end
        end
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

function love.keyreleased(key)
    luis.keyreleased(key)
end

function love.textinput(text)
    luis.textinput(text)
end
