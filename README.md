# LUIS: Love UI System

**LUIS** (Love User Interface System) is a flexible graphical user interface (GUI) framework built on top of the [Löve2D](https://love2d.org/) game framework. LUIS provides developers with the tools to create dynamic, grid-centric, layered user interfaces for games and applications.

## Features

| Feature | Description |
|---------|-------------|
| Flexible Layout | Uses a grid-based system and FlexContainers for easy UI layout |
| Layer Management | Support for multiple UI layers with show/hide functionality |
| Customizable Theming | Easily change the look and feel of your UI elements |
| Widget Library | Includes a variety of pre-built widgets (see Widget Types section) |
| Event Handling | Built-in support for mouse, touch, keyboard, and gamepad interactions |
| Responsive Design | Automatically scales UI elements and interaction based on screen dimensions |
| State Management | Tracks and persists element states to save and load configurations |
| Extensibility | Modular design allowing easy addition of new widgets or removing unneeded widgets |
| Debug Mode | Toggle grid and element outlines for easy development |

## Widget Types

LUIS provides a variety of built-in widgets to create rich user interfaces:

1. **Button**: Interactive clickable elements
2. **Slider**: Adjustable value selector
3. **Switch**: Toggle between two states
4. **CheckBox**: Select multiple options
5. **RadioButton**: Select one option from a group
6. **DropDown**: Select from a list of options
7. **TextInput**: User text entry field (single-line)
8. **TextInputMultiLine**: Multi-line text entry
9. **ProgressBar**: Display progress or loading status
10. **Label**: Display a text label
11. **Icon**: Display graphical icons
12. **FlexContainer**: Special container for flexible layouts

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
    -- Initialize LUIS
    local initluis = require("luis.init")
    
    -- Direct this to your widgets folder.
    local luis = initluis("examples/complex_ui/widgets")
    ```

4. **Create and Manage UI Elements**:
    Use LUIS functions to define layers, add UI elements, and manage their states.

## Example

Here's a simple example to create a FlexContainer with two buttons and a slider (press 'TAB' for debug view):

main.lua
```lua
local initluis = require("luis.init")

-- Direct this to your widgets folder.
local luis = initluis("examples/complex_ui/widgets")

function love.load()
    -- Create a FlexContainer
    local container = luis.newFlexContainer(20, 20, 10, 10)

    -- Add some widgets to the container
    local button1 = luis.newButton("Button 1", 15, 3, function() print("Button 1 clicked!") end, function() print("Button 1 released!") end, 5, 2)
    local button2 = luis.newButton("Button 2", 15, 3, function() print("Button 2 clicked!") end, function() print("Button 2 released!") end, 5, 2)
    local slider = luis.newSlider(0, 100, 50, 10, 2, function(value)
        print('Slider value:', value)
    end, 10, 2)

    container:addChild(button1)
    container:addChild(button2)
    container:addChild(slider)

    luis.newLayer("main")
    luis.setCurrentLayer("main")
    
    -- Add the container to your LUIS layer
    luis.createElement(luis.currentLayer, "FlexContainer", container)

    love.window.setMode(1280, 1024)
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
    if key == "escape" then
        if luis.currentLayer == "main" then
            love.event.quit()
        end
    elseif key == "tab" then -- Debug View
        luis.showGrid = not luis.showGrid
        luis.showLayerNames = not luis.showLayerNames
        luis.showElementOutlines = not luis.showElementOutlines
    else
        luis.keypressed(key)
    end
end
```

## Documentation

For more detailed information on the LUIS API, including layer management, input handling, theming, and state management, please refer to the [LUIS core documentation](/luis/luis-api-documentation.md).

## Dependencies

- Löve2D: The game framework used for rendering and managing game objects.
- The core library has zero dependencies!

## known Problems

- DropBox: Selection with the gamepad works a bit
- Button Animations don't work when usign Gamepad & Mouse
- Checkboxes and radio buttons are currently not being saved.
- Sliders sometime not save; when using moue!?
- Some elements require double-clicking to activate, especially in the complex_menu sample.
- TextInput: Adding a character in the middle of the text deletes the following characters.
- FlexContainer: The initial width or height constrains the arrangement of child widgets.
- Rework State Management: to be more generic; add option to retrieve a specific document; get full state of widget

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
