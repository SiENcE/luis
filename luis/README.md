# LUIS: LUIS User Interface System

**LUIS** (LUIS User Interface System) is a lightweight and flexible graphical user interface (GUI) framework built on top of the [Löve2D](https://love2d.org/) game engine. Designed for ease of use, LUIS provides developers with the tools to create dynamic, grid centric, layered user interfaces for games and applications.

## Getting Started

1. **Install Löve2D**: You can download Löve2D from [here](https://love2d.org/).
2. **Clone the LUIS Library**:
    ```bash
    git clone https://github.com/SiENCE/LUIS.git
    ```
3. **Include LUIS in Your Löve2D Project**:
    ```lua
    local LUIS = require("luis")
    ```

4. **Create and Manage UI Elements**:
    Use LUIS functions to define layers, add UI elements, and manage their states.

## Quick Start

Create a flexible container housing two buttons and a slider, which can be easily moved or resized using the mouse. The widgets within the container automatically rearrange themselves to fit the new layout.

```lua
local LUIS = require("luis")

function love.load()
	-- Create a FlexContainer
	local container = LUIS.newFlexContainer(30, 30, 10, 10)

	-- Add some widgets to the container
	local button1 = LUIS.newButton("Button 1", 15, 3, function() print("Button 1 clicked!") end, 5, 2)
	local button2 = LUIS.newButton("Button 2", 15, 3, function() print("Button 2 clicked!") end, 5, 2)
	local slider = LUIS.newSlider(0, 100, 50, 10, 2, function(value)
		print('change Slider')
	end, 10, 2)

	container:addChild(button1)
	container:addChild(button2)
	container:addChild(slider)

	LUIS.newLayer("main", 96, 54)
	LUIS.setCurrentLayer("main")
	
	-- Add the container to your LUIS layer
	LUIS.createElement(LUIS.currentLayer, "FlexContainer", container)

	love.window.setMode(1280, 1024)
end

-- In your main update function
function love.update(dt)
	LUIS.update(dt)
end

-- In your main draw function
function love.draw()
	LUIS.draw()
end

-- Input handling
function love.mousepressed(x, y, button, istouch)
    LUIS.mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    LUIS.mousereleased(x, y, button, istouch)
end

function love.keypressed(key)
    if key == "escape" then
        if LUIS.currentLayer == "main" then
            love.event.quit()
        end
    elseif key == "tab" then -- Debug View
        LUIS.keypressed(key)
    end
end
```

## Documentation

(Include links or brief descriptions of where to find more detailed documentation)

## Dependencies

- Löve2D: The game framework used for rendering and managing game objects.
- flux (included in the `3rdparty` folder)
- json (included in the `3rdparty` folder)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- Thanks to the Löve2D community for inspiration and support
- flux library by rxi (https://github.com/rxi/flux)
