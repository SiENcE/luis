# LUIS (Love UI System) API Documentation

LUIS (Love User Interface System) is a flexible GUI framework for LÖVE (Love2D). It provides tools to create dynamic, grid-centric, layered user interfaces for games and applications.

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
11. [Debugging](#debugging)
12. [Usage Example](#usage-example)
13. [Advanced Techniques with Layers and Grid-Based Layout](#advanced-techniques-with-layers-and-grid-based-layout)

## Initialization

```lua
local initLuis = require("luis.init")

local luis = initLuis()
```

or

```lua
-- Direct this to your widgets folder.
local luis = require("luis.init")("widgets")
```

or

```lua
local initLuis = require("luis.init")

-- Direct this to your widgets folder.
local luis = initLuis("examples/complex_ui/widgets")
```

Initialize LUIS by providing the path to the widget directory. If not specified, it defaults to "widgets".

## Layer Management

### Creating a Layer

```lua
luis.newLayer(layerName)
luis.removeLayer(layerName)
```
- `layerName`: string - The name of the new layer

Creates and Remove a layer with the given name.

### Enabling/Disabling Layers

```lua
luis.enableLayer(layerName)
luis.disableLayer(layerName)
luis.toggleLayer(layerName)
```
- `layerName`: string - The name of the layer to enable, disable, or toggle

Enable, disable, or toggle the visibility of a layer.

### Checking Layer Status

```lua
luis.isLayerEnabled(layerName)
```
- `layerName`: string - The name of the layer to check
- Returns: boolean - Whether the layer is enabled

### Working with the LayerStack

```lua
luis.setCurrentLayer(layerName)
luis.popLayer()
```
- `layerName`: string - The name of the layer to set as current

Sets the specified layer as the active layer and adds it to the LayerStack. When using popLayer, the current layer is removed from the LayerStack and deactivated (the layer itself is not deleted). The layer at the top of the LayerStack then becomes the new active layer and is enabled.

NOTE: It can be used as an alternative to, or in combination with, enableLayer, disableLayer, and toggleLayer. Refer to the complex_ui sample for an example.

## Element Management

### Creating an Element

```lua
luis.createElement(layerName, widgetType, ...)
```
- `layerName`: string - The name of the layer to add an element to
- `widgetType`: string - The widget type of the element to create (e.g., "Button", "Slider")
- `...`: Additional parameters specific to the element type

Creates a new Element (Instance) of the specified Widget type in the given layer.

Note: An element is an instance of a widget.

### Removing an Element

```lua
luis.removeElement(layerName, elementToRemove)
```
- `layerName`: string - The name of the layer containing the element
- `elementToRemove`: table - The element object to remove

Removes the specified element from the given layer.

### Getting/Setting Element State

```lua
luis.getElementState(layerName, index)
luis.setElementState(layerName, index, value)
```
- `layerName`: string - The name of the layer containing the element
- `index`: number - The index of the element in the layer
- `value`: any - The new state value to set

Get or set the state of an element at the specified index in a layer.

## Input Handling

### Mouse & Keyboard Support
```lua
luis.mousepressed(x, y, button, istouch, presses)
luis.mousereleased(x, y, button, istouch, presses)
luis.wheelmoved(x, y)
luis.keypressed(key, scancode, isrepeat)
luis.keyreleased(key, scancode)
luis.textinput(text)
```

These functions should be called from the corresponding LÖVE callbacks to handle input events.

### Joystick and Gamepad Support

```lua
luis.initJoysticks()
luis.removeJoystick(joystick)
luis.setActiveJoystick(id, joystick)
luis.getActiveJoystick(id)
luis.gamepadpressed(joystick, button)
luis.gamepadreleased(joystick, button)
```
- `id`: number - The ID of the joystick
- `button`: string - The button to check
- `joystick`: the joystick object itself

These functions provide support for joystick and gamepad input.

```lua
luis.isJoystickPressed(id, button)
```
- `id`: number - The ID of the joystick
- `button`: string - The button to check
- Returns: boolean - Whether the button is currently pressed

```lua
luis.joystickJustPressed(id, button)
```
- `id`: number - The ID of the joystick
- `button`: string - The button to check
- Returns: boolean - Whether the button was just pressed

Checks if a joystick button was just pressed in the current frame.

```lua
luis.getJoystickAxis(id, axis)
```
- `id`: number - The ID of the joystick
- `axis`: string - The axis to check (e.g., 'leftx', 'lefty')
- Returns: number - The current value of the axis


### Example

Here's a simple example to add joystick and gamepad support:

```lua
function love.update(dt)
    -- Check for joystick button presses for focus navigation
    if luis.joystickJustPressed(1, 'dpdown') then
        luis.moveFocus("next")
    elseif luis.joystickJustPressed(1, 'dpup') then
        luis.moveFocus("previous")
    end
end

function love.joystickadded(joystick)
    luis.initJoysticks()  -- Reinitialize joysticks when a new one is added
end

function love.joystickremoved(joystick)
	luis.removeJoystick(joystick)
end

function love.gamepadpressed(joystick, button)
    luis.gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
    luis.gamepadreleased(joystick, button)
end
```

optionally initialize the joysticks and gamepads in love.load()

```lua
	luis.initJoysticks()  -- Initialize joysticks

	if luis.activeJoysticks then
		for id, activeJoystick in pairs(luis.activeJoysticks) do
			local name = activeJoystick:getName()
			local index = activeJoystick:getConnectedIndex()
			print(string.format("Active joystick #%d '%s'.", index, name))
		end
	end
```

## Focus Management

```lua
luis.setCurrentFocus(element)
```
- `element`: element we want to have the focus

Use `luis.setCurrentFocus(element)` to set the gamepad or joystick focus to the specified element.

```lua
luis.updateLastFocusedWidget(layerName)
```
- `layerName`: string - The name of the layer to update

Updates the last focused widget for the specified layer.

```lua
luis.restoreFocus(layerName)
```
- `layerName`: string - The name of the layer to restore focus to

Restores focus to the last focused widget of the specified layer.

```lua
luis.updateFocusableElements()
```

Updates the list of focusable elements across all enabled layers.

```lua
luis.moveFocus(direction)
```
- `direction`: string - The direction to move focus ("next" or "previous")

Moves the focus to the next or previous focusable element.

```lua
luis.exitFlexContainerFocus()
```

Exits the focus from the current FlexContainer and moves focus to the next element.

## Rendering

```lua
luis.draw()
```

Renders all enabled layers and their elements. Call this in your `love.draw()` function.

## Theme Management

```lua
luis.setTheme(newTheme)
```
- `newTheme`: table - A table containing theme properties to update

Updates the current theme with the provided theme table.

## State Management

```lua
local config = luis.getConfig()
luis.setConfig(config)
```

`getConfig()` returns the current configuration of all UI elements. `setConfig(config)` applies the provided configuration to all UI elements.

## the Grid

```lua
luis.setGridSize(gridSize)
luis.setGridSize(gridSize)
```
- `gridSize`: number - The size of the grid for element positioning

Set the grid size for positioning and laying out elements. You can use it for more advanced features later.

Set the gridSize only once and before creating a Layer or Element! You can change it later, but every new Element will use the updated gridSize. All previously created Elements will retain the gridSize they were created with.

NOTE: The grid is index at 1,1 and NOT 0,0 !

## Scaling

```lua
luis.updateScale()
```

For window dimensions, update `luis.baseWidth` and `luis.baseHeight`, and use these values to set your window mode.

Then use `luis.updateScale` in the `love.update` callback to automatically scale the UI and Mosue and Touch input.

```lua
function love.load()
	love.window.setMode( luis.baseWidth, luis.baseHeight, { resizable=true } )
end

function love.update(dt)
	luis.updateScale()

    luis.update(dt)
end
```

## Widget System

LUIS supports custom widgets through a plugin system. Widgets are loaded dynamically from the specified widget directory.

### Supported Widget Types

LUIS supports various widget types, including:

- Button

`button.new(text, width, height, onClick, onRelease, row, col, customTheme)`

- Slider

`slider.new(min, max, value, width, height, onChange, row, col, customTheme)`

- Switch

`switch.new(value, width, height, onChange, row, col, customTheme)`

- Icon

`icon.new(iconPath, size, row, col, customTheme)`

- CheckBox

`checkBox.new(value, size, onChange, row, col, customTheme)`

- RadioButton

`radioButton.new(group, value, size, onChange, row, col, customTheme)`

- Label

`label.new(text, width, height, row, col, align, customTheme)`

- DropDown

`dropDown.new(items, value, width, height, onChange, row, col, maxVisibleItems, customTheme)`

- TextInput

`textInput.new(width, height, placeholder, onChange, row, col, customTheme)`

- TextInputMultiLine

`textInputMultiLine.new(width, height, placeholder, onChange, row, col, customTheme)`

- FlexContainer

`flexContainer.new(width, height, row, col, customTheme, containerName)`

- ProgressBar

`progressBar.new(value, width, height, row, col, customTheme)`

- Custom

`custom.new(drawFunc, width, height, row, col, customTheme)`

Each element (widget) type has specific properties and methods.

- `width` and `height`: Dimensions specified in `gridSize`.
- `row` and `col`: Position of the element (widget) on the grid, anchored at the top-left corner.
- `placeholder`: Placeholder text to display when no input is provided.
- `onChange`: Function that is executed when the element's (widget's) state changes.
- `onClick`: Function that is executed when the button is pressed.
- `onRelease`: Function that is executed when the button is released.
- `text`: Text displayed on the element (widget), applicable to buttons and labels.
- `align`: Alignment of the displayed text.
- `value`: Initial value for the element (widget).
- `group`: Group name for a radio button group.
- `min` and `max`: Minimum and maximum values for sliders.
- `customTheme`: Custom theme values for this widget type.
- `drawFunc`: Custom drawing function to be implemented and executed for the widget.
- `containerName`: Optional name for the container element.
- `items`: List of strings to display in a dropdown element (widget).
- `maxVisibleItems`: Maximum number of visible items in the dropdown list.
- `iconPath`: Path to an image (jpg, png) for the icon element (widget).

### Creating Custom Widgets

To create a custom widget:

1. Create a new Lua file in the widgets directory.
2. Define a table with a `new` function that creates and returns the widget.
3. Implement the following methods for the widget:
   - `update(self, mx, my, dt)`
   - `draw(self)`
   - `click(self, x, y, button, istouch, presses)`
   - `release(self, x, y, button, istouch, presses)`
   - `wheelmoved(self, mx, my)`
   - `gamepadpressed(self, button)` (for gamepad support)
   - `gamepadreleased(self, button)` (for gamepad support)

### Widget Interaction with Core

Widgets can interact with the core LUIS library through the following functions:

- `luis.theme`: Accessing the current theme
- `luis.gridSize`: Accessing the current grid size
- `luis.scale`: Accessing the current UI scale
- `luis.isJoystickPressed(button)`: Checking joystick button state
- `luis.getJoystickAxis(axis)`: Getting joystick axis values

Widgets should be designed to work with the LUIS theming system and respond to input events as defined in the core library.


### Example

Here's a simple example to create a button widget yourself and use it (press 'TAB' for debug view):

main.lua
```lua
local initLuis = require("luis.init")

-- Direct this to your widgets folder.
local luis = initLuis()

-- Create a Button widget
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

-- Register the Button Widget to the LUIS core, create an Instance and us it
-- NOTE: The default method is to load them automatically by specifying a folder!
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

## Debugging

```lua
luis.showGrid = true/false
```

`luis.showGrid` is a boolean value. Setting it to `true` will render the grid, which is useful for debugging and layout purposes.

```lua
luis.showElementOutlines = true/false
```

`luis.showElementOutlines` is a boolean value. When set to `true`, it renders the outlines of all elements.

```lua
luis.showLayerNames = true/false
```

When set to `true`, displays the names of enabled layers and the list of focusable elements with their current focus state.

## Advanced Techniques with Layers and Grid-Based Layout

LUIS's layer system and grid-based layout provide powerful tools for creating flexible, responsive, and organized user interfaces. Here are some advanced techniques and creative uses for these features:

### 1. Dynamic UI Compositions with Layers

Layers in LUIS allow you to create complex, multi-layered interfaces that can be manipulated independently:

- **Modal Dialogs**: Create a separate layer for modal dialogs that can be easily shown or hidden without affecting the main UI.
- **HUD Elements**: Use layers to manage different parts of a game HUD, allowing easy toggling of different information displays.
- **Menu Systems**: Implement multi-level menu systems where each menu level is a separate layer, making navigation and state management more straightforward.
- **Tooltips and Overlays**: Create a top-level layer for tooltips or informational overlays that can be displayed above all other UI elements.

Example:
```lua
luis.newLayer("background")
luis.newLayer("gameUI")
luis.newLayer("pauseMenu")
luis.newLayer("modal")
luis.newLayer("tooltip")

-- Enable only the layers you need
luis.enableLayer("background")
luis.enableLayer("gameUI")

-- When pausing the game
luis.enableLayer("pauseMenu")
luis.disableLayer("gameUI")
```

### 2. Responsive Layouts with Grid-Based Positioning

The grid system in LUIS facilitates creating responsive layouts that adapt to different screen sizes:

- **Automatic Scaling**: Use the grid to position elements relative to each other, allowing the entire UI to scale proportionally with different screen resolutions.
- **Dynamic Rearrangement**: Adjust the grid size dynamically to rearrange UI elements based on available space or orientation changes.
- **Consistent Spacing**: Utilize the grid to maintain consistent spacing between elements, enhancing the visual appeal of your UI.

Example:
```lua
-- Set a 12x9 grid for a 16:9 aspect ratio
luis.setGridSize(love.graphics.getWidth() / 12)

-- Position elements using grid coordinates
luis.createElement("main", "Button", 1, 1, 2, 1, "Menu")  -- Top-left corner
luis.createElement("main", "ProgressBar", 10, 8, 2, 1)   -- Bottom-right corner
```

### 3. Combining Layers and Grid for Advanced UIs

By leveraging both layers and the grid system, you can create sophisticated UI layouts:

- **Mini-maps**: Create a mini-map on a separate layer, using the grid for precise positioning of map elements.
- **Inventory Systems**: Design an inventory system where each category is on a different layer, and items are arranged using the grid.
- **Customizable UIs**: Allow players to customize their UI by moving elements between predefined grid positions and layers.

### 4. Performance Optimization with Layers

Layers can be used to optimize rendering performance:

- **Selective Updating**: Only update and redraw layers that have changed, reducing unnecessary rendering.
- **Level of Detail**: Use layers to implement a level-of-detail system for UI, showing more detailed UI elements in closer layers and simpler versions in distant layers.

### 5. Accessibility Features

Utilize layers and grid layout to implement accessibility features:

- **High Contrast Mode**: Create an alternative high-contrast UI layer that can be easily toggled for users with visual impairments.
- **Scalable UI**: Use the grid system to create a scalable UI that can be easily resized for users who need larger interface elements.

Example:
```lua
luis.newLayer("standardUI")
luis.newLayer("highContrastUI")

function toggleHighContrastMode()
    if luis.isLayerEnabled("standardUI") then
        luis.disableLayer("standardUI")
        luis.enableLayer("highContrastUI")
    else
        luis.enableLayer("standardUI")
        luis.disableLayer("highContrastUI")
    end
end
```

### 6. Animated UI Transitions

Combine layers and grid positioning to create smooth UI transitions:

- **Sliding Menus**: Animate layers to slide in and out of view for menu transitions.
- **Grid-Based Animations**: Use the grid to create precise keyframes for UI animations, ensuring consistent movement and alignment.

By mastering these advanced techniques, you can create dynamic, responsive, and visually appealing user interfaces that enhance the overall user experience of your LÖVE applications and games. The combination of layers and grid-based layout in LUIS provides a powerful toolkit for UI design, allowing for both creativity and precision in your interface implementations.


This documentation provides an overview of the LUIS API. For more detailed information on specific functions and their parameters, refer to the source code and comments within the LUIS core library.

Remember to implement all necessary LÖVE callbacks and forward them to LUIS for proper input handling and rendering.
