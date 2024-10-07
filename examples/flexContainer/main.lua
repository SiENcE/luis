local initluis = require("luis.init")
-- point this to your widgets folder
local luis = initluis("examples/complex_ui/widgets")

-- register flux in luis, because the widgets of complex_ui need this
luis.flux = require("examples.3rdparty.flux")

function love.load()
	-- we set the container paddig to gridSize (default is 0)
	luis.theme.flexContainer.padding = luis.gridSize
	
	luis.theme.text.font = love.graphics.newFont(10, "normal")
	
	local container = luis.createElement("main", "FlexContainer", (luis.baseWidth/luis.gridSize)-32, (luis.baseHeight/luis.gridSize)-2, 1, 1, nil, "main" )

	-- Create sub-containers (header, nav, main, aside, footer)
	local header = luis.newFlexContainer( 62, 4, 1,1, nil, "header")
	local nav = luis.newFlexContainer( 9,38, 2,8, nil, "nav")
	local body = luis.newFlexContainer( 45,38, 12,8, nil, "body")
	local aside = luis.newFlexContainer( 6,38,58,8, nil, "aside")
	local footer = luis.newFlexContainer( 62,5,2,47, nil, "footer")

	-- if you don't want to resize the container manually, disable this
	body.release = function() end
	body.click = function() end

	-- Add sub-containers to the main container
	container:addChild(header)
	container:addChild(nav)
	container:addChild(body)
	container:addChild(aside)
	container:addChild(footer)

	-- Now you can add widgets to these containers
	nav:addChild(luis.createElement("main", "Button", "Menu Item 1", 7, 2, function() print('click 1') end, function() print('release 1') end, 1, 1))
	body:addChild(luis.createElement("main", "Label", "Main Content", 5, luis.gridSize, 1, 1))
	aside:addChild(luis.createElement("main", "Button", "Sidebar Item", 4, 2, function() print('click 2') end, function() print('release 2') end, 1, 1))

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

function love.keypressed(key)
    if key == "escape" then
        if luis.currentLayer == "main" then
            love.event.quit()
        end
    elseif key == "tab" then -- Debug View
        luis.keypressed(key)
    end
end