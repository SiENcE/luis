local initLuis = require("luis.init")
local luis = initLuis("examples/complex_ui/widgets")
luis.flux = require("examples.3rdparty.flux")
local json = require("examples.3rdparty.json")
local utils = require("examples.3rdparty.utils")

local alternativeTheme = require("examples.complex_ui.assets.themes.alternativeTheme")
alternativeTheme.text.font = love.graphics.newFont("examples/complex_ui/assets/fonts/Monocraft.ttf", 18)

local materialTheme = require("examples.complex_ui.assets.themes.materialTheme")

local editor = {
    currentLayer = "main",
    selectedWidget = nil,
    mode = "edit", -- "use", "edit" modes
    placingWidget = false,
    resizingWidget = false,
    movingWidget = false,
    widgets = {},
    widgetTypes = {"FlexContainer","Button", "Label", "Icon", "Slider", "Switch", "CheckBox", "RadioButton", "DropDown", "TextInput", "TextInputMultiLine", "ProgressBar"},
    gridSize = 20,
    startX = 0,
    startY = 0
}

-- Function to save the current layout
local function saveLayout(filename)
    local layout = {
        widgets = {}
    }
    for _, widget in ipairs(editor.widgets) do
        local widgetData = {
            type = widget.type,
            x = widget.position.x,
            y = widget.position.y,
            width = widget.width,
            height = widget.height,
            -- Save additional properties based on widget type
            properties = {}
        }
		print(widgetData.x,widgetData.y)
			
        -- Save type-specific properties
        if widget.type == "Button" or widget.type == "Label" then
            widgetData.properties.text = widget.text
        elseif widget.type == "Icon" then
			-- nothing
        elseif widget.type == "Slider" then
            widgetData.properties.min = widget.min
            widgetData.properties.max = widget.max
            widgetData.properties.value = widget.value
        elseif widget.type == "Switch" or widget.type == "CheckBox" then
            widgetData.properties.value = widget.value
		elseif widget.type == "RadioButton" then
			widgetData.properties.value = widget.value
        elseif widget.type == "DropDown" then
            widgetData.properties.items = widget.items
            widgetData.properties.selectedIndex = widget.selectedIndex
		elseif widget.type == "TextInput" then
			widgetData.properties.text = widget.text
		elseif widget.type == "TextInputMultiLine" then
			widgetData.properties.lines = widget.lines
		elseif widget.type == "ProgressBar" then
			widgetData.properties.value = widget.value
		--elseif widget.type == "FlexContainer" then
		--	widgetData.properties.children = widget.children
		end
        
        table.insert(layout.widgets, widgetData)
    end
    
    local success, message = love.filesystem.write(filename, json.encode(layout))
    if not success then
        print("Failed to save layout:", message)
    end
end

-- Function to load a layout
local function loadLayout(filename)
    if not love.filesystem.getInfo(filename) then
        print("Layout file not found:", filename)
        return
    end
    
    local content = love.filesystem.read(filename)
    if not content then
        print("Failed to read layout file")
        return
    end
    
    local layout = json.decode(content)
    if not layout then
        print("Failed to parse layout file")
        return
    end
    
    -- Clear existing widgets
    for i = #editor.widgets, 1, -1 do
        luis.removeElement(editor.currentLayer, editor.widgets[i])
    end
    editor.widgets = {}
    
    -- Create new widgets from layout
    for _, widgetData in ipairs(layout.widgets) do
        local widget
		print(widgetData.type, widgetData.x,widgetData.y)
        local x = widgetData.x / luis.gridSize + 1
		local y = widgetData.y / luis.gridSize + 1
        local width, height = widgetData.width/luis.gridSize, widgetData.height/luis.gridSize
        local props = widgetData.properties
		
        --if widgetData.type == "FlexContainer" then
			-- (width, height, row, col, customTheme, containerName)
        --    widget = luis.createElement(editor.currentLayer, "FlexContainer", width, height, y, x, nil, "FlexContainer" + love.math.random(1,1000) )
        --else
		if widgetData.type == "Button" then
            widget = luis.createElement(editor.currentLayer, "Button", props.text or "Button", 
                width, height, function() end, function() end, y, x)
        elseif widgetData.type == "Label" then
            widget = luis.createElement(editor.currentLayer, "Label", props.text or "Label", 
                width, height, y, x, "left")
		elseif widgetData.type == "Icon" then
			widget = luis.createElement(editor.currentLayer, "Icon", "examples/complex_ui/assets/images/icon.png", width, y, x)
        elseif widgetData.type == "Slider" then
            widget = luis.createElement(editor.currentLayer, "Slider", 
                props.min or 0, props.max or 100, props.value or 50,
                width, height, function() end, y, x)
		elseif widgetData.type == "Switch" then
			widget = luis.createElement(editor.currentLayer, "Switch", false, width, height, function(state) end, y, x)
		elseif widgetData.type == "CheckBox" then
			widget = luis.createElement(editor.currentLayer, "CheckBox", false, width, function(state) end, y, x)
		elseif widgetData.type == "RadioButton" then
			widget = luis.createElement(editor.currentLayer, "RadioButton", "group1",  props.value or false, width, function(state) end, y, x)
		elseif widgetData.type == "DropDown" then
			widget = luis.createElement(editor.currentLayer, "DropDown", {"Option 1", "Option 2", "Option 3"}, 1, width, height, function(selectedItem) end, y, x, 2)
		elseif widgetData.type == "TextInput" then
			widget = luis.createElement(editor.currentLayer, "TextInput", width, height, props.text or "Input text", function(text) end, y, x)
		elseif widgetData.type == "TextInputMultiLine" then
			widget = luis.createElement(editor.currentLayer, "TextInputMultiLine", width, height, props.text or "Input multiline text", function(text) end, y, x)
		elseif widgetData.type == "ProgressBar" then
			widget = luis.createElement(editor.currentLayer, "ProgressBar", props.value or 0.75, width, height, y, x)
        end
        
        if widget then
            table.insert(editor.widgets, widget)
        end
    end

	if editor.mode == "edit" then
		for i, widget in ipairs(editor.widgets) do
			if widget then
				print(i, widget.type, 'deactivate click&release')
				if not widget.click_ and widget.click then
					widget.click_ = widget.click
					widget.click = function() end
				elseif not widget.release_ and widget.release then
					widget.release_ = widget.release
					widget.release = function() end
				end
			end
		end
	else
		for i, widget in ipairs(editor.widgets) do
			if widget then
				print(i, widget.type, 'activate click&release')
				if widget.click_ then
					widget.click = widget.click_
					widget.click_ = nil
				elseif widget.release_ then
					widget.release = widget.release_
					widget.release_ = nil
				end
			end
		end
	end
end

function love.load()
	luis.baseWidth = 1280
	luis.baseHeight = 1024
	love.window.setMode(luis.baseWidth, luis.baseHeight)
    love.graphics.setDefaultFilter('nearest', 'nearest')

    luis.setGridSize(editor.gridSize)

    luis.newLayer(editor.currentLayer)
    luis.enableLayer(editor.currentLayer)
    luis.setTheme(alternativeTheme)

    -- Create menu bar items
    -- File menu dropdown
    local fileMenuItems = {"New", "Load Layout", "Save Layout", "Exit"}
    luis.createElement(editor.currentLayer, "DropDown",
        fileMenuItems, 1,
        8, 2,
        function(selectedItem, selectedID)
			print('selectedItem',selectedItem, selectedID)
            if fileMenuItems[selectedID] == "Load Layout" then
                loadLayout("layout.json")
            elseif fileMenuItems[selectedID] == "Save Layout" then
                saveLayout("layout.json")
            elseif fileMenuItems[selectedID] == "Exit" then
                love.event.quit()
            elseif fileMenuItems[selectedID] == "New" then
                -- Clear all widgets
                for i = #editor.widgets, 1, -1 do
                    luis.removeElement(editor.currentLayer, editor.widgets[i])
                end
                editor.widgets = {}
            end
        end, 1, 1, 4, materialTheme.dropDown, "File")

	-- Widgets dropdown
    luis.createElement(editor.currentLayer, "DropDown", 
        editor.widgetTypes, 1, 
        8, 2,
        function(selectedItem, selectedID)
			print('selectedItem',selectedItem, selectedID)
            if editor.mode == "edit" then
                editor.selectedWidget = editor.widgetTypes[selectedID]
                editor.placingWidget = true
            end
        end, 1, 9, 5, materialTheme.dropDown, "Widgets")

    -- Mode toggle button
    luis.createElement(editor.currentLayer, "Button", "Mode: Edit",
        8, 2,
        function(this)
            if editor.mode == "use" then
                editor.mode = "edit"
                this.text = "Mode: Edit"
				for i, widget in ipairs(editor.widgets) do
					if widget then
						print(i, widget.type, 'deactivate click&release')
						if not widget.click_ and widget.click then
							widget.click_ = widget.click
							widget.click = function() end
						elseif not widget.release_ and widget.release then
							widget.release_ = widget.release
							widget.release = function() end
						end
					end
				end
            else
                editor.mode = "use"
                this.text = "Mode: Use"
				for i, widget in ipairs(editor.widgets) do
					if widget then
						print(i, widget.type, 'activate click&release')
						if widget.click_ then
							widget.click = widget.click_
							widget.click_ = nil
						elseif widget.release_ then
							widget.release = widget.release_
							widget.release_ = nil
						end
					end
				end
            end
            -- Reset states
            editor.placingWidget = false
            editor.movingWidget = false
            editor.resizingWidget = false
            editor.selectedWidget = nil
        end,
        function() end,
        1,17, materialTheme.button)
end

local accumulator = 0
function love.update(dt)
    accumulator = accumulator + dt
    if accumulator >= 1/60 then
        luis.flux.update(accumulator)
        accumulator = 0
    end

    luis.updateScale()
    luis.update(dt)

    if editor.mode == "use" then return end

    local mx, my = love.mouse.getPosition()
    mx, my = mx / luis.scale, my / luis.scale

    if editor.mode == "edit" and editor.placingWidget and editor.selectedWidget then
        if love.mouse.isDown(1) then
            local gridX = math.floor(mx / editor.gridSize) * editor.gridSize
            local gridY = math.floor(my / editor.gridSize) * editor.gridSize
            local widgetWidth = editor.gridSize * 5
            local widgetHeight = editor.gridSize * 2
            
            local widget
			if editor.selectedWidget == "FlexContainer" then
				local mainContainer = luis.newFlexContainer(widgetWidth /luis.gridSize, widgetHeight /luis.gridSize, gridX /luis.gridSize+1, gridY /luis.gridSize+1, nil, "FlexContainer")
				widget = luis.createElement(editor.currentLayer, "FlexContainer", mainContainer)
            elseif editor.selectedWidget == "Button" then
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
				print(widget.type, 'deactivate click&release for new element')
				if widget.click then
					widget.click_ = widget.click
					widget.click = function() end
				elseif widget.release then
					widget.release_ = widget.release
					widget.release = function() end
				end

                table.insert(editor.widgets, widget)
            end
            editor.placingWidget = false
            editor.selectedWidget = nil
        end
    elseif editor.mode == "edit" then
        if editor.movingWidget then
            -- Snap to grid
            local gridX = math.floor(mx / luis.gridSize) * luis.gridSize
            local gridY = math.floor(my / luis.gridSize) * luis.gridSize
            
            -- Update widget position, accounting for initial click offset
            editor.movingWidget.position.x = gridX
            editor.movingWidget.position.y = gridY

			for i, widget in ipairs(editor.widgets) do
				if editor.movingWidget then
					local x,y = love.mouse.getPosition()
					if widget and widget.type == "FlexContainer" and widget:isInContainer(x,y) then
						if not widget:hasChild(editor.movingWidget) then
							widget:addChild(editor.movingWidget)
						end
					end
				end
			end
		
        elseif editor.resizingWidget then
            -- Calculate new dimensions based on mouse position
            local gridX = math.floor(mx / luis.gridSize) * luis.gridSize
            local gridY = math.floor(my / luis.gridSize) * luis.gridSize
            
            -- Calculate width and height in grid units
            local newWidth = math.max(luis.gridSize, gridX - editor.resizingWidget.position.x)
            local newHeight = math.max(luis.gridSize, gridY - editor.resizingWidget.position.y)
            
            -- Update widget dimensions
            editor.resizingWidget.width = newWidth
            editor.resizingWidget.height = newHeight
        end
    end
end

function love.draw()
    luis.draw()

    -- Draw widget outlines only in edit mode
    if editor.mode == "edit" then
        love.graphics.setColor(1, 1, 0, 0.5)
        for _, widget in ipairs(editor.widgets) do
            love.graphics.rectangle("line", 
                widget.position.x * luis.scale, 
                widget.position.y * luis.scale, 
                widget.width * luis.scale, 
                widget.height * luis.scale)
        end
    end

    -- Draw placing preview
    if editor.mode == "edit" and editor.placingWidget and editor.selectedWidget then
        local mx, my = love.mouse.getPosition()
        local gridX = math.floor(mx / editor.gridSize) * editor.gridSize
        local gridY = math.floor(my / editor.gridSize) * editor.gridSize
        love.graphics.setColor(0, 1, 0, 0.5)
        love.graphics.rectangle("fill", gridX, gridY, editor.gridSize * 5, editor.gridSize * 2)
    end

    -- Highlight selected widget in edit mode
    if editor.mode == "edit" then
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
end

function love.mousepressed(x, y, button, istouch, presses)
    -- Convert mouse coordinates to grid space
    local gridX = x / luis.scale
    local gridY = y / luis.scale

    if not luis.mousepressed(gridX, gridY, button, istouch, presses) and editor.mode == "edit" then
        for _, widget in ipairs(editor.widgets) do
			local isOver = utils.pointInRect(x, y, widget.position.x, widget.position.y, widget.width, widget.height)
			if widget.type == "FlexContainer" and isOver then return end

            -- Calculate widget bounds in screen space
            local widgetX = widget.position.x
            local widgetY = widget.position.y
            local widgetWidth = widget.width
            local widgetHeight = widget.height
            
            -- Check if mouse is within widget bounds
            if gridX >= widgetX and 
               gridX <= (widgetX + widgetWidth) and
               gridY >= widgetY and 
               gridY <= (widgetY + widgetHeight) then
                
                if button == 1 then  -- Left mouse button for moving
                    editor.movingWidget = widget
                    editor.startX = gridX - widgetX
                    editor.startY = gridY - widgetY
                elseif button == 2 then  -- Right mouse button for resizing
                    editor.resizingWidget = widget
                    editor.startX = gridX
                    editor.startY = gridY
                end
                break
            end
        end
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    x, y = x / luis.scale, y / luis.scale
    luis.mousereleased(x, y, button, istouch, presses)
    if editor.mode == "edit" then
        if button == 1 then
            editor.movingWidget = nil
        elseif button == 2 then
            editor.resizingWidget = nil
        end
    end
end

function love.wheelmoved(x, y)
    luis.wheelmoved(x, y)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        editor.placingWidget = false
        editor.selectedWidget = nil
        editor.movingWidget = nil
        editor.resizingWidget = nil
    elseif key == "delete" and editor.mode == "edit" then
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