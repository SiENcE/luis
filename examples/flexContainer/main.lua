local initluis = require("luis.init")
-- Direct this to your widgets folder.
local luis = initluis("examples/complex_ui/widgets")

-- register flux in luis, because the widgets of complex_ui need this
luis.flux = require("examples.3rdparty.flux")

local plasmaBuffer
local colorPalette

function createColorPalette(size)
    local palette = {}
    for i = 0, size - 1 do
        local value = i / size
        local r = math.sin(value * 2 * math.pi + 0) * 0.5 + 0.5
        local g = math.sin(value * 2 * math.pi + 2 * math.pi / 3) * 0.5 + 0.5
        local b = math.sin(value * 2 * math.pi + 4 * math.pi / 3) * 0.5 + 0.5
        palette[i] = {r, g, b}
    end
    return palette
end

function love.load()
	luis.baseWidth = 1280
	luis.baseHeight = 1024
	love.window.setMode(luis.baseWidth, luis.baseHeight)

	-- we set the container paddig to gridSize (default is 0)
	luis.theme.flexContainer.padding = 0 --luis.gridSize
	
	luis.theme.text.font = love.graphics.newFont(10, "normal")

	-- first create a new Layer
	luis.newLayer("main")

	-- second create a FlexContainer and add it to the "main" Layer
	local container = luis.createElement("main", "FlexContainer", 62, 60, 3, 2, nil, "Main Container" )

	-- Create sub-containers (header, nav, main, aside, footer)
	local header = luis.newFlexContainer( 60, 4, 1,1, nil, "header")
	local nav = luis.newFlexContainer( 9,38, 2,8, nil, "nav")
	local body = luis.newFlexContainer( 45,38, 12,8, nil, "body")
	local aside = luis.newFlexContainer( 6,38,58,8, nil, "aside")
	local footer = luis.newFlexContainer( 60,5,2,47, nil, "footer")

	-- if you don't want to resize the container manually, disable click & release
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

    local node1 = luis.createElement("gameplay", "Node", "My Node 0", 8, 8, 10, 10)
    node1:addOutput("Output 1")
    node1:addOutput("Output 2")

    local node2 = luis.createElement("gameplay", "Node", "My Node 1", 8, 8, 5, 19)
    node2:addInput("Input 1")
    node2:addOutput("Output 1")

    local node3 = luis.createElement("gameplay", "Node", "My Node 2", 8, 8, 14, 19)
    node3:addInput("Input 1")
    node3:addInput("Input 2")

    node1:connect(1, node2, 1)
    node1:connect(2, node3, 1)
    node2:connect(1, node3, 2)

	body:addChild(node1)
	body:addChild(node2)
	body:addChild(node3)

	-- CustomView can be used to render gameplay
    plasmaBuffer = love.image.newImageData(body.width, body.height)
    colorPalette = createColorPalette(256)
	local customView = luis.createElement("main", "Custom", function(self)
		love.graphics.setColor(1, 0, 0)
		love.graphics.rectangle("line", 0, 0, self.width, self.height)
		for y = 0, self.height - 1, 2 do
			for x = 0, self.width - 1, 2 do
				local value = math.sin(x / 16.0)
							+ math.sin(y / 8.0)
							+ math.sin((x + y) / 16.0)
							+ math.sin(math.sqrt(x * x + y * y) / 8.0)
				
				value = math.abs(math.sin(value + love.timer.getTime() * 0.8)) * 255
				local index = math.floor(value) % 256
				
				plasmaBuffer:setPixel(x, y, colorPalette[index][1], colorPalette[index][2], colorPalette[index][3], 1)
			end
		end
		local plasmaImage = love.graphics.newImage(plasmaBuffer)
		love.graphics.draw(plasmaImage, 0, 0)
	end, 10, 10, 0, 0)
	body:addChild(customView)
	
	local sideBarBtn = luis.createElement("main", "Button", "Sidebar Item", 6, 2, function() print('Sidebar Item - click') end, function() print('Sidebar Item - release') end, 1, 1)
	aside:addChild(sideBarBtn)

	-- Create a Menu
	local editItems = {"Revert", "Insert", "Copy", "Paste", "Comment", "Block", "Reset"}
	editFunc = function(self, item)
		print(item)
	end
	-- this DropDown is placed directly ont he "main" Layer. The last two prameter specify the grid position.
	local dropdownbox1 = luis.createElement("main", "DropDown", editItems, 1, 8, 2, editFunc, 1, 10, 4, nil, "Edit")

	local fileItems = {"New", "Load", "Save", "Exit"}
	fileFunc = function(self, item)
		if item == 4 then
			love.event.quit()
		end
	end
	-- this DropDown is added as Child to the "header" flexContainer. The grid position is not used here, as the flexContainer we have defined orders his childs dynamically!
	local dropdownbox2 = luis.createElement("main", "DropDown", fileItems, 1, 8, 2, fileFunc, 1, 1, 4, nil, "File")
	header:addChild(dropdownbox2)

	-- add a TextInput
	local textInput = luis.createElement("main", "TextInput", footer.width/luis.gridSize, 4, "Enter text here...", function(text) print(text) end, 1, 1)
	footer:addChild(textInput)

	-- add a TextInputMultiLine
	local textInputMultiLine = luis.createElement("main", "TextInputMultiLine", 4, aside.height/luis.gridSize-sideBarBtn.height/luis.gridSize, "Enter MultiLine text here...", function(text) print(text) end, 1, 1)
	aside:addChild(textInputMultiLine)

	love.keyboard.setKeyRepeat(true)

	luis.setCurrentLayer("main")
end

-- In your main update function
local accumulator = 0
function love.update(dt)
    accumulator = accumulator + dt
    if accumulator >= 1/60 then
        luis.flux.update(accumulator)
        accumulator = 0
    end

	luis.updateScale()

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
    elseif key == "tab" then
        luis.showGrid = not luis.showGrid
        luis.showElementOutlines = not luis.showElementOutlines
        luis.showLayerNames = not luis.showLayerNames
	else
		luis.keypressed(key, scancode, isrepeat)
	end
end

function love.keyreleased( key, scancode )
	luis.keyreleased( key, scancode )
end
