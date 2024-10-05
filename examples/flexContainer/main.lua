local initluis = require("luis.init")
-- point this to your widgets folder
local luis = initluis("examples/complex_ui/widgets")

-- register flux in luis, because the widgets of complex_ui need this
luis.flux = require("examples.3rdparty.flux")

function love.load()
	-- Create a FlexContainer
	local container = luis.newFlexContainer(20, 20, 10, 10)

	-- Add some widgets to the container
	local button1 = luis.newButton("Button 1", 15, 3, function() print("Button 1 clicked!") end, function() print("Button 1 released!") end, 5, 2)
	local button2 = luis.newButton("Button 2", 15, 3, function() print("Button 2 clicked!") end, function() print("Button 2 released!") end, 5, 2)
	local slider = luis.newSlider(0, 100, 50, 10, 2, function(value)
		print('change Slider')
	end, 10, 2)

	container:addChild(button1)
	container:addChild(button2)
	container:addChild(slider)

	luis.newLayer("main", 96, 54)
	luis.setCurrentLayer("main")
	
	-- Add the container to your luis layer
	luis.createElement(luis.currentLayer, "FlexContainer", container)

	love.window.setMode(1280, 1024)
end

-- In your main update function
function love.update(dt)
	luis.update(dt)
end

-- In your main draw function
function love.draw()
	luis.draw()
end

-- Input handling
function love.mousepressed(x, y, button, istouch)
    luis.mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    luis.mousereleased(x, y, button, istouch)
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