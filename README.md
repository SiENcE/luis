# **LUIS** (LUIS User Interface System - Sample Application)

LUIS is a flexible and feature-rich UI system for the LÖVE (Love2D) framework. It provides an easy-to-use set of widgets and containers for creating interactive user interfaces in your Love2D games and applications.

## Features

| Feature | Description |
|---------|-------------|
| Flexible Layout | Uses a grid-based system and FlexContainers for easy UI arrangement |
| Customizable Theming | Easily change the look and feel of your UI elements |
| Multiple Layers | Support for multiple UI layers with enable/disable functionality |
| Responsive Design | Automatically scales UI elements based on window size |
| Widget Library | Includes buttons, sliders, switches, checkboxes, and more |
| Event Handling | Built-in support for mouse and keyboard interactions |
| Debug Mode | Toggle grid and element outlines for easy development |

## Unique Selling Points

- **Love2D Integration**: Seamlessly integrates with the Love2D framework
- **Flexible Containers**: Use FlexContainers for dynamic and responsive layouts
- **Easy Customization**: Modify themes and individual widget properties during runtime
- **Lightweight**: Minimal external dependencies for easy integration into your project
- **Extensible**: Create custom widgets to suit your specific needs

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
9. **Icon**: Display graphical icons
10. **FlexContainer**: Special container for flexible layouts

### FlexContainer

The FlexContainer is a powerful widget that allows for dynamic and responsive layouts:

- **Drag and Resize**: Containers can be moved and resized at runtime
- **Auto-arranging**: Child elements are automatically arranged within the container
- **Nested Containers**: Create complex layouts by nesting FlexContainers
- **Padding Control**: Adjust spacing between child elements

Example usage:

```lua
local container = LUIS.newFlexContainer(30, 30, 10, 10)
local button1 = LUIS.newButton("Button 1", 15, 3, function() print("Button 1 clicked!") end, 5, 2)
local button2 = LUIS.newButton("Button 2", 15, 3, function() print("Button 2 clicked!") end, 5, 2)

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

## Installation

1. Copy the `luis` folder into your Love2D project directory.
2. Require the library in your `main.lua` file:

```lua
local LUIS = require("luis")
```

## Quick Start

Here's a simple example to get you started:

```lua
local LUIS = require("luis")

function love.load()
    -- Create a new layer
    LUIS.newLayer("main")
    LUIS.setCurrentLayer("main")

    -- Create a button
    local button = LUIS.newButton("Click me!", 10, 3, function()
        print("Button clicked!")
    end, 5, 2)

    -- Add the button to the current layer
    LUIS.createElement(LUIS.currentLayer, "Button", button)
end

function love.update(dt)
    LUIS.update(dt)
end

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
    LUIS.keypressed(key)
end
```

## Documentation

(Include links or brief descriptions of where to find more detailed documentation)

## Dependencies

- LÖVE (Love2D) framework
- flux (included in the `3rdparty` folder)
- json (included in the `3rdparty` folder)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- Thanks to the Love2D community for inspiration and support
- flux library by rxi (https://github.com/rxi/flux)

