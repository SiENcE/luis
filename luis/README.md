# LUIS: LUIS User Interface System

**LUIS** (LUIS User Interface System) is a lightweight and flexible graphical user interface (GUI) framework built on top of the [Löve2D](https://love2d.org/) game engine. Designed for ease of use, LUIS provides developers with the tools to create dynamic, grid centric, layered user interfaces for games and applications.

## Features

- **Layer Management**
   - Create and manage multiple layers
   - Enable/disable layers
   - Set current active layer
   - Layer stack for easy navigation

- **Theming**
   - Customizable theme for all UI elements
   - Ability to set and update themes dynamically

- **Scaling**
   - Automatic UI scaling based on screen dimensions
   - Maintains consistent look across different resolutions

- **Grid System**
   - Configurable grid for precise element placement
   - Option to show/hide grid for development purposes

- **State Management**
   - Tracks and persists element states
   - Ability to save and load configurations

- **Debug Features**
   - Toggle element outlines for easy visualization
   - Display layer names for debugging

## Functionality

### UI Elements

The library supports various UI elements, including:

1. Buttons
2. Sliders
3. Switches
4. Checkboxes
5. Radio buttons
6. Dropdowns
7. Text inputs
8. Progress bars
9. Label
10. Icons
11. Flex containers
12. Custom
13. .. you can easily add more by yourself

### Flex Container

A notable feature is the FlexContainer, which provides:

- Dynamic arrangement of child elements
- Drag-and-drop functionality
- Resizable container
- Automatic child repositioning on container resize

### Input Handling

- Mouse input (click, release, wheel)
- Keyboard input
- Touch input support

### Rendering

- Efficient drawing system
- Proper z-ordering based on layers

### Animation

- Integration with Flux library for smooth animations and transitions

### Extensibility

- Modular design allowing easy addition of new widgets
- Dynamic loading of widget modules

### Configuration

- Save and load UI configurations
- Persist element states across sessions

### Accessibility

- Customizable fonts with various hinting modes

### Vector Operations

- Built-in Vector2D class for position calculations



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

## Example

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

## Dependencies

- Löve2D: The game framework used for rendering and managing game objects.
- UTF8, Flux, JSON: Additional libraries for managing text encoding, animations, and data serialization.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
