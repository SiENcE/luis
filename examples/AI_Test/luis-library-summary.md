# LUIS Library Summary for LÖVE2D

## Core Functionality

- Layered UI system with z-index support
- Scaling and grid system
- Theming capabilities
- Support for mouse, keyboard, and gamepad input

## Main Components

1. Layers
2. UI Elements
3. Input Handling
4. Theming
5. State Management

## API Overview

### Layer Management

- `luis.newLayer(layerName)`
- `luis.setCurrentLayer(layerName)`
- `luis.popLayer()`
- `luis.enableLayer(layerName)`
- `luis.disableLayer(layerName)`
- `luis.toggleLayer(layerName)`
- `luis.isLayerEnabled(layerName)`
- `luis.removeLayer(layerName)`

### Element Creation and Management

- `luis.createElement(layerName, widgetType, ...)`
- `luis.setElementState(layerName, index, value)`
- `luis.getElementState(layerName, index)`
- `luis.removeElement(layerName, elementToRemove)`

### Theming

- `luis.setTheme(newTheme)`

### Core Functions

- `luis.setGridSize(gridSize)`
- `luis.getGridSize()`
- `luis.updateScale()`
- `luis.update(dt)`
- `luis.draw()`

### Input Handling

- `luis.mousepressed(x, y, button, istouch, presses)`
- `luis.mousereleased(x, y, button, istouch, presses)`
- `luis.wheelmoved(x, y)`
- `luis.keypressed(key, scancode, isrepeat)`
- `luis.keyreleased(key, scancode)`
- `luis.textinput(text)`

### Gamepad/Joystick Support

- `luis.initJoysticks()`
- `luis.removeJoystick(joystick)`
- `luis.setActiveJoystick(id, joystick)`
- `luis.getActiveJoystick(id)`
- `luis.joystickJustPressed(id, button)`
- `luis.isJoystickPressed(id, button)`
- `luis.getJoystickAxis(id, axis)`
- `luis.gamepadpressed(joystick, button)`
- `luis.gamepadreleased(joystick, button)`

### Focus Management

- `luis.updateFocusableElements()`
- `luis.moveFocus(direction)`
- `luis.setCurrentFocus(element)`
- `luis.exitFlexContainerFocus()`

### State Management

- `luis.getConfig()`
- `luis.setConfig(config)`

## UI Elements

The library supports various UI elements including:

- Button

`Button.new(text, width, height, onClick, onRelease, row, col, customTheme)`

- Slider

`Slider.new(min, max, value, width, height, onChange, row, col, customTheme)`

- Switch

`Switch.new(value, width, height, onChange, row, col, customTheme)`

- Icon

`Icon.new(iconPath, size, row, col, customTheme)`

- CheckBox

`CheckBox.new(value, size, onChange, row, col, customTheme)`

- RadioButton

`RadioButton.new(group, value, size, onChange, row, col, customTheme)`

- Label

`Label.new(text, width, height, row, col, align, customTheme)`

- DropDown

`DropDown.new(items, value, width, height, onChange, row, col, maxVisibleItems, customTheme, title)`

- TextInput

`TextInput.new(width, height, placeholder, onChange, row, col, customTheme)`

- TextInputMultiLine

`TextInputMultiLine.new(width, height, placeholder, onChange, row, col, customTheme)`

- FlexContainer

`FlexContainer.new(width, height, row, col, customTheme, containerName)`

- ProgressBar

`ProgressBar.new(value, width, height, row, col, customTheme)`

- Custom

`Custom.new(drawFunc, width, height, row, col, customTheme)`

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
- `title`: The dropdown will behave differently based on whether a title is provided or not (see desc. above)
  - With a `title`: The title is always displayed when closed, and only the items can be selected when open.
  - Without a `title`: The selected item is displayed when closed, matching the original behavior.
- `iconPath`: Path to an image (jpg, png) for the icon element (widget).

## Usage in LÖVE2D

1. Initialize LUIS in `love.load()`
2. Update LUIS in `love.update(dt)`
3. Draw LUIS in `love.draw()`
4. Handle input in respective LÖVE2D callbacks

## Notes

- The library uses a coordinate system based on a 1920x1080 resolution, which is then scaled to fit the actual window size.
- Ensure that the parameter order of the widgets created with "createElement" is correct.
- LUIS is a retained mode GUI system.
- Z-index is supported for layering elements within a single layer.
- Use layers when you need TABs.
- Use a flexContainer and a DropDown with title when yoou want to create a "Menu bar"
- Combine a Slider with a Label to show the Slider value in the Label.
- When you create a Radio Button, always create at least two and group them.
- The library includes built-in support for gamepads/joysticks, including focus navigation.
- State of UI elements can be saved and loaded using `getConfig()` and `setConfig()`.
