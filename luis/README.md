# LUIS: LUIS User Interface System

**LUIS** (LUIS User Interface System) is a flexible graphical user interface (GUI) framework built on top of the [Löve2D](https://love2d.org/). LUIS provides developers with the tools to create dynamic, grid centric, layered user interfaces for games and applications.

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

## LUIS UI Library Documentation

The LUIS UI library uses a grid-based positioning system and supports theming. It's built on top of the LÖVE framework and includes features like scaling, joystick support, and state management. The library provides a variety of widgets for creating user interfaces, including labels, icons, progress bars, buttons, checkboxes, custom elements, and flexible containers for layout management.

1. Label
2. Icon
3. ProgressBar
4. Button
5. CheckBox
6. Custom
7. FlexContainer
8. RadioButton
9. Slider
10. Switch
11. DropDown
12. TextInput

## Function Reference

### Core Functions

#### luis.newLayer(name)
Creates a new layer for organizing UI elements.
- Signature: `function luis.newLayer(name) -> layerName`
- Parameter: `name`: String identifier for the layer

#### luis.setCurrentLayer(layerName)
Sets the specified layer as the current active layer.
- Signature: `function luis.setCurrentLayer(layerName)`
- Parameter: `layerName`: String identifier of the layer to set as current

#### luis.enableLayer(layerName)
Enables a specific layer, making its elements visible and interactive.
- Signature: `function luis.enableLayer(layerName)`
- Parameter: `layerName`: String identifier of the layer to enable

#### luis.disableLayer(layerName)
Disables a specific layer, hiding its elements and making them non-interactive.
- Signature: `function luis.disableLayer(layerName)`
- Parameter: `layerName`: String identifier of the layer to disable

#### luis.isLayerEnabled(layerName)
Checks if a specific layer is currently enabled.
- Signature: `function luis.isLayerEnabled(layerName) -> boolean`
- Parameter: `layerName`: String identifier of the layer to check

#### luis.toggleLayer(layerName)
Toggles the enabled state of a specific layer.
- Signature: `function luis.toggleLayer(layerName)`
- Parameter: `layerName`: String identifier of the layer to toggle

#### luis.popLayer()
Removes the topmost layer from the layer stack.
- Signature: `function luis.popLayer() -> layerName or false`

#### luis.createElement(layerName, elementType, ...)
Creates a new UI element and adds it to the specified layer.
- Signature: `function luis.createElement(layerName, elementType, ...) -> element`
- Parameters:
  - `layerName`: String identifier of the layer to add the element to
  - `elementType`: String specifying the type of element to create
  - `...`: Additional parameters specific to the element type

#### luis.setTheme(newTheme)
Updates the global theme with new style settings.
- Signature: `function luis.setTheme(newTheme)`
- Parameter: `newTheme`: Table containing theme properties to update

#### luis.update(dt)
Updates all UI elements, handling input and animations.
- Signature: `function luis.update(dt)`
- Parameter: `dt`: Delta time since last frame

#### luis.draw()
Renders all visible UI elements.
- Signature: `function luis.draw()`

#### luis.saveConfig(filename)
Saves the current state of UI elements to a file.
- Signature: `function luis.saveConfig(filename)`
- Parameter: `filename`: String specifying the file to save the configuration to

#### luis.loadConfig(filename)
Loads and applies a saved UI configuration from a file.
- Signature: `function luis.loadConfig(filename)`
- Parameter: `filename`: String specifying the file to load the configuration from


### Widget-specific Functions

### Label

#### label.new
Creates a new Label widget for displaying text.

**Signature:**
```lua
label.new(text, width, height, row, col, align, customTheme)
```

**Parameters:**
- `text`: The text content of the label
- `width`: Width of the label in grid units
- `height`: Height of the label in grid units
- `row`: Row position of the label in the grid
- `col`: Column position of the label in the grid
- `align`: Text alignment (optional)
- `customTheme`: Custom theme settings (optional)

### Icon

#### icon.new
Creates a new Icon widget for displaying images.

**Signature:**
```lua
icon.new(iconPath, size, row, col, customTheme)
```

**Parameters:**
- `iconPath`: File path to the icon image
- `size`: Size of the icon in grid units
- `row`: Row position of the icon in the grid
- `col`: Column position of the icon in the grid
- `customTheme`: Custom theme settings (optional)

### ProgressBar

#### progressBar.new
Creates a new ProgressBar widget for displaying progress.

**Signature:**
```lua
progressBar.new(value, width, height, row, col, customTheme)
```

**Parameters:**
- `value`: Initial value of the progress bar (between 0 and 1)
- `width`: Width of the progress bar in grid units
- `height`: Height of the progress bar in grid units
- `row`: Row position of the progress bar in the grid
- `col`: Column position of the progress bar in the grid
- `customTheme`: Custom theme settings (optional)

### Button

#### button.new
Creates a new Button widget for user interaction.

**Signature:**
```lua
button.new(text, width, height, onClick, onRelease, row, col, customTheme)
```

**Parameters:**
- `text`: The text displayed on the button
- `width`: Width of the button in grid units
- `height`: Height of the button in grid units
- `onClick`: Function to be called when the button is clicked
- `onRelease`: Function to be called when the button is released
- `row`: Row position of the button in the grid
- `col`: Column position of the button in the grid
- `customTheme`: Custom theme settings (optional)

### CheckBox

#### checkBox.new
Creates a new CheckBox widget for boolean input.

**Signature:**
```lua
checkBox.new(value, size, onChange, row, col, customTheme)
```

**Parameters:**
- `value`: Initial state of the checkbox (true or false)
- `size`: Size of the checkbox in grid units
- `onChange`: Function to be called when the checkbox state changes
- `row`: Row position of the checkbox in the grid
- `col`: Column position of the checkbox in the grid
- `customTheme`: Custom theme settings (optional)

### Custom

#### custom.new
Creates a new Custom widget for custom drawing.

**Signature:**
```lua
custom.new(drawFunc, width, height, row, col, customTheme)
```

**Parameters:**
- `drawFunc`: Function that defines custom drawing logic
- `width`: Width of the custom widget in grid units
- `height`: Height of the custom widget in grid units
- `row`: Row position of the custom widget in the grid
- `col`: Column position of the custom widget in the grid
- `customTheme`: Custom theme settings (optional)

### FlexContainer

#### flexContainer.new
Creates a new FlexContainer widget for flexible layout of child elements.

**Signature:**
```lua
flexContainer.new(width, height, row, col, customTheme)
```

**Parameters:**
- `width`: Width of the container in grid units
- `height`: Height of the container in grid units
- `row`: Row position of the container in the grid
- `col`: Column position of the container in the grid
- `customTheme`: Custom theme settings (optional)

**Methods:**
- `addChild(child)`: Adds a child element to the container
- `removeChild(child)`: Removes a child element from the container
- `arrangeChildren()`: Arranges child elements within the container
- `resize(newWidth, newHeight)`: Resizes the container

### RadioButton

#### radioButton.new
Creates a new radio button element.

**Signature:**
```lua
radioButton.new(group, value, size, onChange, row, col, customTheme)
```

**Parameters:**
- `group`: String identifier for the radio button group
- `value`: Boolean initial state of the radio button
- `size`: Number specifying the size of the radio button
- `onChange`: Function to call when the radio button state changes
- `row`, `col`: Numbers specifying the grid position
- `customTheme`: Optional table with custom theme properties

**Methods:**

### Slider

#### slider.new
Creates a new slider element.

**Signature:**
```lua
slider.new(min, max, value, width, height, onChange, row, col, customTheme)
```

**Parameters:**
- `min`, `max`: Numbers specifying the range of the slider
- `value`: Number initial value of the slider
- `width`, `height`: Numbers specifying the dimensions of the slider
- `onChange`: Function to call when the slider value changes
- `row`, `col`: Numbers specifying the grid position
- `customTheme`: Optional table with custom theme properties

**Methods:**

### Switch

#### switch.new
Creates a new switch element.

**Signature:**
```lua
switch.new(value, width, height, onChange, row, col, customTheme)
```

**Parameters:**
- `value`: Boolean initial state of the switch
- `width`, `height`: Numbers specifying the dimensions of the switch
- `onChange`: Function to call when the switch state changes
- `row`, `col`: Numbers specifying the grid position
- `customTheme`: Optional table with custom theme properties

**Methods:**

### DropDown

#### dropDown.new
Creates a new dropdown element.

**Signature:**
```lua
dropDown.new(items, selectedIndex, width, height, onChange, row, col, maxVisibleItems, customTheme)
```

**Parameters:**
- `items`: Table of strings representing the dropdown options
- `selectedIndex`: Number indicating the initially selected item index
- `width`, `height`: Numbers specifying the dimensions of the dropdown
- `onChange`: Function to call when the selected item changes
- `row`, `col`: Numbers specifying the grid position
- `maxVisibleItems`: Number specifying the maximum number of visible items when the dropdown is open
- `customTheme`: Optional table with custom theme properties

**Methods:**
- `dropDownElement:setItems(newItems)`: Updates the items in the dropdown.
- `dropDownElement:setSelectedIndex(newIndex)`: Sets the selected item in the dropdown.

### TextInput

#### textInput.new
Creates a new text input element.

**Signature:**
```lua
textInput.new(text, width, height, onChange, row, col, customTheme)
```

**Parameters:**
- `text`: String initial text in the input field
- `width`, `height`: Numbers specifying the dimensions of the text input
- `onChange`: Function to call when the text changes
- `row`, `col`: Numbers specifying the grid position
- `customTheme`: Optional table with custom theme properties

**Methods:**
- `textInputElement:setText(newText)`: Sets the text in the input field.
- `textInputElement:getText()`: Gets the current text in the input field.

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
