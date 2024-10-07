# LUIS (Love UI System) API Documentation

**LUIS** (LUIS User Interface System) is a flexible graphical user interface (GUI) framework built on top of the [Löve2D](https://love2d.org/). LUIS provides developers with the tools to create dynamic, grid centric, layered user interfaces for games and applications. The core library provides a set of core functionalities and support for custom widgets.

## Table of Contents

1. [Initialization](#initialization)
2. [Layer Management](#layer-management)
3. [Element Management](#element-management)
4. [Input Handling](#input-handling)
5. [Rendering](#rendering)
6. [Theme Management](#theme-management)
7. [State Management](#state-management)
8. [Scaling and Grid](#scaling-and-grid)
9. [Joystick and Gamepad Support](#joystick-and-gamepad-support)
10. [Widget System](#widget-system)

## Initialization

```lua
local luis = require("luis.init")("widgets")
```

Initialize LUIS by providing the path to the widget directory. If not specified, it defaults to "widgets".

## Layer Management

Layers allow for organizing UI elements in a hierarchical structure.

### Creating a Layer

```lua
luis.newLayer(name)
```

Creates a new layer with the given name.

### Setting the Current Layer

```lua
luis.setCurrentLayer(layerName)
```

Sets the specified layer as the current active layer.

### Enabling/Disabling Layers

```lua
luis.enableLayer(layerName)
luis.disableLayer(layerName)
luis.toggleLayer(layerName)
```

Enable, disable, or toggle the visibility of a layer.

### Checking Layer Status

```lua
luis.isLayerEnabled(layerName)
```

Returns a boolean indicating whether the specified layer is enabled.

## Element Management

### Creating an Element

```lua
luis.createElement(layerName, elementType, ...)
```

Creates a new UI element of the specified type in the given layer.

### Removing an Element

```lua
luis.removeElement(layerName, element)
```

Removes the specified element from the given layer.

### Getting/Setting Element State

```lua
luis.getElementState(layerName, index)
luis.setElementState(layerName, index, value)
```

Get or set the state of an element at the specified index in a layer.

## Input Handling

LUIS provides functions to handle various input events:

```lua
luis.mousepressed(x, y, button, istouch, presses)
luis.mousereleased(x, y, button, istouch, presses)
luis.wheelmoved(x, y)
luis.keypressed(key)
luis.textinput(text)
```

These functions should be called from the corresponding LÖVE callbacks.

## Rendering

```lua
luis.draw()
```

Renders all enabled layers and their elements.

## Theme Management

### Setting a Theme

```lua
luis.setTheme(newTheme)
```

Updates the current theme with the provided theme table.

## State Management

### Getting Configuration

```lua
luis.getConfig()
```

Returns the current configuration of all UI elements.

### Setting Configuration

```lua
luis.setConfig(config)
```

Applies the provided configuration to all UI elements.

## Scaling and Grid

```lua
luis.setGridSize(gridSize)
luis.updateScale()
```

Set the grid size for element positioning and update the UI scale based on the window size.

## Joystick and Gamepad Support

```lua
luis.initJoysticks()
luis.setActiveJoystick(joystick)
luis.isJoystickPressed(button)
luis.getJoystickAxis(axis)
luis.gamepadpressed(joystick, button)
luis.gamepadreleased(joystick, button)
```

Functions for handling joystick and gamepad input.

## Widget System

LUIS supports custom widgets through a plugin system. Widgets are loaded dynamically from the specified widget directory.

### Supported Widget Types

LUIS supports various widget types, including:

- Button
- Slider
- Switch
- Checkbox
- RadioButton
- DropDown
- TextInput
- ProgressBar
- Icon
- FlexContainer
- any custom Widget ...

### Creating Custom Widgets

To create a custom widget:

1. Create a new Lua file in the widgets directory.
2. Define a table with a `new` function that creates and returns the widget.
3. Implement the following methods for the widget:
   - `update(self, mx, my, dt)`
   - `draw(self)`
   - `click(self, x, y, button, istouch, presses)`
   - `release(self, x, y, button, istouch, presses)`
   - `gamepadpressed(self, button)` (for gamepad support)
   - `gamepadreleased(self, button)` (for gamepad support)

### Widget Interaction with Core

Widgets can interact with the core LUIS library through the following functions:

- `luis.flux`: For creating animations
- `luis.theme`: Accessing the current theme
- `luis.gridSize`: Accessing the current grid size
- `luis.scale`: Accessing the current UI scale
- `luis.isJoystickPressed(button)`: Checking joystick button state
- `luis.getJoystickAxis(axis)`: Getting joystick axis values

Widgets should be designed to work with the LUIS theming system and respond to input events as defined in the core library.


## Example

Here's a simple example to create a button widget yourself and use it (press 'TAB' for debug view):

main.lua
```lua
local initLuis = require("luis.init")

-- point this to your widgets folder
local luis = initLuis()

-- create a Button widget
local CustomButtonWidget = {}
function CustomButtonWidget.new(x, y, width, height, text, onClick)
    local self = {
        type = "CustomButtonWidget", position = {x=x, y=y},
		width = width, height = height, text = text,
		onClick = onClick, hovered = false, pressed = false
    }
    function self:update(mx, my)
        self.hovered = mx > self.position.x and mx < self.position.x + self.width and
                       my > self.position.y and my < self.position.y + self.height
    end
    function self:draw()
        love.graphics.setColor(self.pressed and {0.3,0.3,0.3} or {0.7,0.7,0.7})
        love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height, 3)
        love.graphics.setColor(1,1,1)
        love.graphics.print(self.text, self.position.x, self.position.y)
    end
    function self:click(_, _, button)
        if button == 1 and self.hovered then
            self.pressed = true
            if self.onClick then self.onClick() end
            return true
        end
        return false
    end
    function self:release(_, _, button)
        if button == 1 and self.pressed then
            self.pressed = false
            return true
        end
        return false
    end

    return self
end

-- add it manually to the luis library (the default way is to load them automatically)
CustomButtonWidget.luis = luis
luis.widgets["CustomButtonWidget"] = CustomButtonWidget
luis["newCustomButtonWidget"] = CustomButtonWidget.new

function love.load()
    luis.newLayer("main")
    luis.enableLayer("main")
    
	luis.createElement("main", "CustomButtonWidget", 100, 200, 100, 50, "Click me!", function() print("Button clicked!") end)
end

function love.update(dt)
    luis.update(dt)
end

function love.draw()
    luis.draw()
end

function love.mousepressed(x, y, button, istouch)
    luis.mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    luis.mousereleased(x, y, button, istouch)
end

function love.keypressed(key)
    if key == "tab" then -- Debug View
        luis.keypressed(key)
    end
end
```

This documentation provides an overview of the LUIS API. For more detailed information on specific functions and their parameters, refer to the source code and comments within the LUIS core library.
