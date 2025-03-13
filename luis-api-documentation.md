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
11. [FlexContainers](#flexcontainers)
12. [Decorator System](#decorator-system)
13. [Debugging](#debugging)
14. [Usage Example](#usage-example)
15. [Advanced Techniques with Layers and Grid-Based Layout](#advanced-techniques-with-layers-and-grid-based-layout)

## Initialization

```lua
-- Default initialization
local initLuis = require("luis.init")

local luis = initLuis()
```

or

```lua
-- Default initialization (looks for "widgets" directory)
local luis = require("luis.init")("luis/widgets")
```

or

```lua
-- Two-step initialization
local initLuis = require("luis.init")

-- Direct this to your widgets folder.
local luis = initLuis("luis/widgets")
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

### Inserting and Removing an Element

```lua
luis.insertElement(layerName, element)
luis.removeElement(layerName, element)
```
- `layerName`: string - The name of the layer containing the element
- `element`: table - The element object to insert or remove

Inserts or removes the specified element from the given layer.

### Checking if an Element already exists within a layer
```lua
luis.elementExists(layerName, element)
```
- `layerName`: string - The name of the layer containing the element
- `element`: table - The element object to insert or remove
- Returns: boolean - Whether the layer already contains element

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

LUIS includes built-in gamepad support with focus-based navigation:

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
function love.load()
    -- Initialize gamepad support
    luis.initJoysticks()
    
    -- Optional: Check connected gamepads
    if luis.activeJoysticks then
        for id, joystick in pairs(luis.activeJoysticks) do
            print(string.format("Gamepad #%d: %s", id, joystick:getName()))
        end
    end
end

-- Required callbacks for gamepad support
function love.joystickadded(joystick)
    luis.initJoysticks()
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

-- Handle navigation in your update function
function love.update(dt)
    -- Example: D-pad navigation between elements
    if luis.joystickJustPressed(1, 'dpdown') then
        luis.moveFocus("next")
    elseif luis.joystickJustPressed(1, 'dpup') then
        luis.moveFocus("previous")
    end
end
```

Focusable elements (like buttons, checkboxes, etc.) can be navigated using the D-pad, and activated using the 'A' button by default. The currently focused element will show a visual indicator.

**Note**: When using FlexContainers with gamepad support, use `luis.exitFlexContainerFocus()` to leave container focus and move to the next element.

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

## Scaling System

LUIS includes a built-in scaling system for resolution independence.

For window dimensions, update `luis.baseWidth` and `luis.baseHeight`, and use these values to set your window mode.

Then use `luis.updateScale` in the `love.update` callback to automatically scale the UI and Mosue and Touch input.

```lua
function love.load()
    -- Set your base resolution
    luis.baseWidth = 1920  
    luis.baseHeight = 1080
    
    -- Set window mode using these dimensions
    love.window.setMode(luis.baseWidth, luis.baseHeight, { resizable=true })
end

function love.update(dt)
    -- Update scaling (handles window resizing)
    luis.updateScale()

    luis.update(dt)
end
```

## Grid System

LUIS uses a grid-based layout system where:

- Grid positions start at (1,1), not (0,0)
- Grid size should be set before creating any elements:

```lua
-- Set grid size (defaults to 20 if not set)
luis.setGridSize(32)  

-- Create elements using grid coordinates
local button = luis.newButton("Click me", 4, 2, onClick, onRelease, 1, 1)
-- Width: 4 grid units
-- Height: 2 grid units
-- Position: Row 1, Column 1
```

**Important**: While grid size can be changed later, existing elements will retain their original grid size. Only new elements will use the updated size.

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

`dropDown.new(items, value, width, height, onChange, row, col, maxVisibleItems, customTheme, title)`

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

- ColorPicker

`colorPicker.new(width, height, row, col, onChange, customTheme)`

- Node

`node.new(title, width, height, row, col, func, customTheme)`

- DialogueWheel

`dialogueWheel.new(options, width, height, onChange, row, col, customTheme)`


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
- `func`: function that processes input to output when node is connected to other nodes
- `containerName`: Optional name for the container element.
- `items`: List of strings to display in a dropdown element (widget).
- `maxVisibleItems`: Maximum number of visible items in the dropdown list.
- `title`: The dropdown will behave differently based on whether a title is provided or not (see desc. above)
  - With a `title`: The title is always displayed when closed, and only the items can be selected when open.
  - Without a `title`: The selected item is displayed when closed, matching the original behavior.
- `iconPath`: Path to an image (jpg, png) for the icon element (widget).
- `options`: List of options to choose from.


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
        luis.showGrid = not luis.showGrid
        luis.showElementOutlines = not luis.showElementOutlines
        luis.showLayerNames = not luis.showLayerNames
    end
    luis.keypressed(key)
end
```

## FlexContainers

The FlexContainer is a powerful widget that allows for creating dynamic, flexible layouts. It acts as a container for other widgets, automatically arranging them in a flow layout and providing features like dragging, resizing, and visibility control.

### Creating a FlexContainer

```lua
-- Basic creation
local container = luis.newFlexContainer(width, height, row, col)

-- With custom theme
local container = luis.newFlexContainer(width, height, row, col, customTheme)

-- With name (useful for debugging and managing multiple containers)
local container = luis.newFlexContainer(width, height, row, col, customTheme, "MainMenu")
```

- `width` and `height`: Dimensions specified in `gridSize`.
- `row` and `col`: Position of the container on the grid, anchored at the top-left corner.
- `customTheme`: Optional custom theme values for this container.
- `containerName`: Optional name for the container element.

### Adding and Managing Child Elements

```lua
-- Add child elements
local button = luis.newButton("Click me", 10, 3, onClick, onRelease, 1, 1)
local slider = luis.newSlider(0, 100, 50, 15, 2, onValueChange, 1, 1)
container:addChild(button)
container:addChild(slider)

-- Remove child elements
container:removeChild(button)

-- Check if a child exists in the container
local exists = container:hasChild(button)
```

Child elements are automatically positioned within the container, reflowing as needed.

### Container Layout and Sizing

```lua
-- Manually resize the container
container:resize(newWidth, newHeight)

-- Container automatically calculates minimum size based on children
local minWidth = container.minWidth
local minHeight = container.minHeight
```

The FlexContainer automatically arranges its children in a left-to-right, top-to-bottom flow layout, wrapping elements to new rows when they would exceed the container's width.

### Dragging and Resizing

FlexContainers can be dragged and resized at runtime by default:

- To drag a container, click and drag on any empty area within the container.
- To resize a container, click and drag the resize handle in the bottom-right corner.

### Visibility Control

FlexContainers include built-in visibility control that allows you to hide and show containers without removing them from the UI structure:

```lua
-- Hide a container
container:hide()

-- Show a container
container:show()

-- Toggle visibility
container:toggleVisibility()

-- Set visibility directly
container:setVisible(true)  -- Show
container:setVisible(false) -- Hide

-- Check if container is visible
if container:isVisible() then
    -- Container is visible
end
```

When a container is hidden:
- It won't be drawn on screen
- It won't respond to user interactions
- It maintains its state and all of its children
- It remains in memory and in the UI hierarchy

This is ideal for UI screens or panels that need to be temporarily hidden and then shown again later.

### Focus Management

FlexContainers support gamepad/keyboard focus navigation between focusable child elements:

```lua
-- Activate internal focus (focus on first child element)
container:activateInternalFocus()

-- Deactivate internal focus
container:deactivateInternalFocus()

-- Move focus between child elements
container:moveFocus("next")     -- Focus next child
container:moveFocus("previous") -- Focus previous child
```

### Applying Decorators

Like other widgets, FlexContainers support decorators for visual styling:

```lua
-- Apply a glow effect
container:setDecorator("GlowDecorator", {1, 0.5, 0, 0.5}, 15)

-- Apply a glassmorphism effect
container:setDecorator("GlassmorphismDecorator", {
    opacity = 0.6,
    blur = 15,
    borderRadius = 12,
    backgroundColor = {1, 1, 1, 0.15}
})
```

### Example

Here's a complete example of creating and using a FlexContainer:

```lua
-- Create a FlexContainer
local container = luis.newFlexContainer(20, 15, 5, 5)

-- Add child elements
local title = luis.newLabel("Settings", 18, 2, 1, 1)
local button1 = luis.newButton("Audio", 10, 3, onAudioClick, nil, 1, 1)
local button2 = luis.newButton("Video", 10, 3, onVideoClick, nil, 1, 1)
local button3 = luis.newButton("Controls", 10, 3, onControlsClick, nil, 1, 1)
local slider = luis.newSlider(0, 100, 50, 15, 2, onVolumeChange, 1, 1)

container:addChild(title)
container:addChild(button1)
container:addChild(button2)
container:addChild(button3)
container:addChild(slider)

-- Add the container to a layer
luis.createElement("menu", "FlexContainer", container)

-- Show/hide based on game state
function showSettings()
    container:show()
end

function hideSettings()
    container:hide()
end
```

This creates a settings menu container with a title, three buttons, and a slider, which can be shown or hidden as needed.

## Decorator System

LUIS implements the Decorator pattern to allow dynamic modification of widget appearance. The decorator system enables you to add visual effects to widgets without modifying their core functionality.

### Using Decorators

Every widget in LUIS supports decorators through these methods:

```lua
-- Set a decorator
widget:setDecorator(decoratorType, ...)

-- Remove a decorator (widget returns to default appearance)
widget:setDecorator(nil)
```

### Available Decorators

#### GlowDecorator

Adds a customizable glow effect around the widget.

```lua
widget:setDecorator("GlowDecorator", glowColor, glowSize)
```

Parameters:
- `glowColor`: Table containing RGBA values (e.g., {1, 0, 0, 0.5} for semi-transparent red)
- `glowSize`: Number specifying the size of the glow effect in pixels

Example:
```lua
local button = LUIS.newButton("Glowing", 10, 3, onClick, onRelease, 5, 2)
button:setDecorator("GlowDecorator", {1, 0.5, 0, 0.5}, 15)  -- Orange glow
```

#### Slice9Decorator

Implements 9-slice scaling for widgets with borders or complex backgrounds.

```lua
widget:setDecorator("Slice9Decorator", image, left, right, top, bottom)
```

Parameters:
- `image`: LÖVE Image object containing the border/background
- `left`: Width of the left border in pixels
- `right`: Width of the right border in pixels
- `top`: Height of the top border in pixels
- `bottom`: Height of the bottom border in pixels

Example:
```lua
local borderImage = love.graphics.newImage("border.png")
local button = LUIS.newButton("Bordered", 10, 3, onClick, onRelease, 5, 2)
button:setDecorator("Slice9Decorator", borderImage, 10, 10, 10, 10)
```

### Creating Custom Decorators

You can create custom decorators by extending the BaseDecorator:

```lua
local CustomDecorator = setmetatable({}, {__index = BaseDecorator})
CustomDecorator.__index = CustomDecorator

function CustomDecorator.new(widget, ...additional_params)
    local self = setmetatable(BaseDecorator.new(widget), CustomDecorator)
    -- Initialize additional parameters
    return self
end

function CustomDecorator:draw()
    -- Add custom drawing logic here
    -- Call the widget's default draw method when needed:
    self.widget:defaultDraw()
end

decorators.CustomDecorator = CustomDecorator
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
