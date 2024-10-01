# LUIS: LUIS User Interface System

**LUIS** (LUIS User Interface System) is a flexible graphical user interface (GUI) framework built on top of the [Löve2D](https://love2d.org/). LUIS provides developers with the tools to create dynamic, grid centric, layered user interfaces for games and applications.

## Overview

- **Löve2D Integration**: Seamlessly integrates with the Löve2D framework
- **Flexible Containers**: Use FlexContainers for dynamic and responsive layouts
- **Theming**: Add/Modify themes and individual widget properties during runtime
- **Lightweight**: Minimal external dependencies for easy integration into your project
- **Extensible**: Create custom widgets to suit your specific needs

## Features

| Feature | Description |
|---------|-------------|
| Flexible Layout | Uses a grid-based system and FlexContainers for easy UI layout |
| Layer Management | Support for multiple UI layers with show/hide functionality |
| Customizable Theming | Easily change the look and feel of your UI elements |
| Widget Library | Includes buttons, sliders, switches, checkboxes, dropdown, textinput and more |
| Event Handling | Built-in support for mouse, touch and keyboard interactions |
| Responsive Design | Automatically scales UI elements and Interaction based on screen dimensions |
| State Management | Tracks and persists element states to save and load configurations |
| Animation | Integration with Flux library for smooth animations and transitions |
| Extensibility | Modular design allowing easy addition of new widgets |
| Debug Mode | Toggle grid and element outlines for easy development |

## Widget Types

LUIS provides a variety of built-in widgets to create rich user interfaces:

1. **Button**: Interactive clickable elements
2. **Slider**: Adjustable value selector
3. **Switch**: Toggle between two states
4. **CheckBox**: Select multiple options
5. **RadioButton**: Select one option from a group
6. **DropDown**: Select from a list of options
7. **TextInput**: User text entry field
8. **ProgressBar**: Display progress or loading status
9. **Label**: Display a text label
10. **Icon**: Display graphical icons
11. **FlexContainer**: Special container for flexible layouts
12. **Custom**: add your own custom draw function (can be used as game view)

### FlexContainer

The FlexContainer is a powerful widget that allows for dynamic and responsive layouts:

- **Drag and Resize**: Containers can be moved and resized at runtime
- **Auto-arranging**: Child elements are automatically arranged within the container
- **Nested Containers**: Create complex layouts by nesting FlexContainers
- **Padding Control**: Adjust spacing between child elements

Example usage:

```lua
local container = LUIS.newFlexContainer(30, 30, 10, 10)
local button1 = LUIS.newButton("Button 1", 15, 3, function() print("Button 1 clicked!") end, function() print("Button 1 released!") end, 5, 2)
local button2 = LUIS.newButton("Button 2", 15, 3, function() print("Button 2 clicked!") end, function() print("Button 2 released!") end, 5, 2)

container:addChild(button1)
container:addChild(button2)

LUIS.createElement(LUIS.currentLayer, "FlexContainer", container)
```

## Custom Widgets

LUIS supports the creation of custom widgets to extend its functionality:

1. Create a new Lua file in the `luis/widgets` directory
2. Define your widget's properties and methods
3. Implement the required functions: `new()`, `update()`, `draw()`, and `click()`
4. Use the `setluis()` function to access the core LUIS library

Example of a custom widget:

```lua
local customWidget = {}

local luis
function customWidget.setluis(luisObj)
    luis = luisObj
end

function customWidget.new(width, height, row, col)
    local widget = {
        type = "CustomWidget",
        width = width * luis.gridSize,
        height = height * luis.gridSize,
        position = luis.Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        
        update = function(self, mx, my)
            -- Update logic here
        end,
        
        draw = function(self)
            -- Drawing logic here
        end,
        
        click = function(self, x, y)
            -- Click handling logic here
        end
    }
    return widget
end

return customWidget
```

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

Here's a simple example to create a flexContainer with two buttons and a slider (press 'TAB' for debug view):

main.lua
```lua
local LUIS = require("luis")

function love.load()
	-- Create a FlexContainer
	local container = LUIS.newFlexContainer(20, 20, 10, 10)

	-- Add some widgets to the container
	local button1 = LUIS.newButton("Button 1", 15, 3, function() print("Button 1 clicked!") end, function() print("Button 1 released!") end, 5, 2)
	local button2 = LUIS.newButton("Button 2", 15, 3, function() print("Button 2 clicked!") end, function() print("Button 2 released!") end, 5, 2)
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

(Include links to /luis/README.MD)

## Dependencies

- Löve2D: The game framework used for rendering and managing game objects.
- flux (included in the `3rdparty` folder)
- json (included in the `3rdparty` folder)

## known Problems

- DropDownBox: when selecting, the an underlying ui element is also executed (Button i.e.)
- DropBox, selection doesn't work with gamepad
- checkbox saved nicht
- checkbox checked nicht
- man muss per gamepad oder maus doppelt auf checkbox klicken, zumindest im video menü
- InputText: when adding a character in the middle of a text, the text behind is removed
- FlexContainer: the initial width or height limits the arrangement of child widgets


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
