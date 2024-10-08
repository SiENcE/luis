local initluis = require("luis.init")
-- Direct this to your widgets folder.
local luis = initluis("examples/complex_ui/widgets")

-- register flux in luis, because the widgets of complex_ui need this
luis.flux = require("examples.3rdparty.flux")

function love.load()
	--luis.gridSize = 4
	-- we set the container paddig to gridSize (default is 0)
	luis.theme.flexContainer.padding = 0 --luis.gridSize
	
	luis.theme.text.font = love.graphics.newFont(10, "normal")
	
	--local container = luis.createElement("main", "FlexContainer", (luis.baseWidth/luis.gridSize)-32, (luis.baseHeight/luis.gridSize)-2, 1, 1, nil, "main" )
	local container = luis.createElement("main", "FlexContainer", 62, 60, 3, 2, nil, "main" )

	-- Create sub-containers (header, nav, main, aside, footer)
	local header = luis.newFlexContainer( 60, 4, 1,1, nil, "header")
	local nav = luis.newFlexContainer( 9,38, 2,8, nil, "nav")
	local body = luis.newFlexContainer( 45,38, 12,8, nil, "body")
	local aside = luis.newFlexContainer( 6,38,58,8, nil, "aside")
	local footer = luis.newFlexContainer( 60,5,2,47, nil, "footer")

	-- if you don't want to resize the container manually, disable this
	--body.release = function() end
	--body.click = function() end

	-- Add sub-containers to the main container
	container:addChild(header)
	container:addChild(nav)
	container:addChild(body)
	container:addChild(aside)
	container:addChild(footer)

	-- Now you can add widgets to these containers
	nav:addChild(luis.createElement("main", "Button", "Menu Item 1", 7, 2, function() print('Menu Item 1 - click') end, function() print('Menu Item 1 - release') end, 1, 1))
	nav:addChild(luis.createElement("main", "Button", "Menu Item 2", 7, 2, function() print('Menu Item 2 - click') end, function() print('Menu Item 2 - release') end, 1, 1))

	body:addChild(luis.createElement("main", "Label", "MultiLine Editor", body.width/luis.gridSize, 2, 1, 1))
	aside:addChild(luis.createElement("main", "Button", "Sidebar Item", 4, 2, function() print('Sidebar Item - click') end, function() print('Sidebar Item - release') end, 1, 1))

	-- Create a Menu
	local editItems = {"Edit", "Insert", "Copy", "Paste", "Comment", "Block", "Reset"}
	editFunc = function(self, item)
		print(item)
	end
	-- this DropDown is placed directly ont he "main" Layer. The last two prameter specify the grid position.
	local dropdownbox1 = luis.createElement("main", "DropDown", editItems, 1, 8, 2, editFunc, 1, 10, 4)

	local fileItems = {"File", "Load", "Save", "Exit"}
	fileFunc = function(self, item)
		if item == 4 then
			love.event.quit()
		end
	end
	-- this DropDown is added as Child to the "header" flexContainer. The grid position is not used here, as the flexContainer we have defined orders his childs dynamically!
	local dropdownbox2 = luis.createElement("main", "DropDown", fileItems, 1, 8, 2, fileFunc, 1, 1, 2)
	header:addChild(dropdownbox2)

	-- add a TextInput
	local textInput = luis.createElement("main", "TextInput", footer.width/luis.gridSize, 4, "Enter text here...", function(text) print(text) end, 1, 1)
	footer:addChild(textInput)

	-- add a TextInputMultiLine
	local textInputMultiLine = luis.createElement("gameplay", "TextInputMultiLine", body.width/luis.gridSize, 30, "Enter text here...", function(text) print(text) end, 1, 1)
	body:addChild(textInputMultiLine)
	
	love.keyboard.setKeyRepeat(true)
	luis.initJoysticks()  -- Initialize joysticks
	if luis.activeJoystick then
		local name = luis.activeJoystick:getName()
		local index = luis.activeJoystick:getConnectedIndex()
		print(string.format("Changing active joystick to #%d '%s'.", index, name))
		luis.setJoystickPos(luis.baseWidth/2,luis.baseHeight/2)
	end

	luis.newLayer("main", 96, 54)
	luis.setCurrentLayer("main")

	love.window.setMode(1280, 1024)
end

-- In your main update function
local accumulator = 0
function love.update(dt)
    accumulator = accumulator + dt
    if accumulator >= 1/60 then
        luis.flux.update(accumulator)
        accumulator = 0
    end
	luis.update(dt)
end

-- In your main draw function
function love.draw()
	luis.draw()
end

-- Input handling
function love.mousepressed(x, y, button, istouch, presses)
    luis.mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    luis.mousereleased(x, y, button, istouch, presses)
end

function love.wheelmoved(x, y)
    luis.wheelmoved(x, y)
end

function love.textinput(text)
    luis.textinput(text)
end

function love.keypressed( key, scancode, isrepeat )
    if key == "escape" then
        if luis.currentLayer == "main" then
            love.event.quit()
        end
    else
		luis.keypressed(key, scancode, isrepeat)
	end
end

function love.keyreleased( key, scancode )
	luis.keyreleased( key, scancode )
end

function love.joystickadded(joystick)
    luis.initJoysticks()  -- Reinitialize joysticks when a new one is added
end

function love.joystickremoved(joystick)
    luis.initJoysticks()  -- Reinitialize joysticks when one is removed
end

function love.gamepadpressed(joystick, button)
    luis.gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
    luis.gamepadreleased(joystick, button)
end
