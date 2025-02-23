# LUIS: Love UI System

<p align="center">
 <a href="https://github.com/SiENcE/luis/blob/main/assets/logo_small.png">
  <img border="0" src="https://github.com/SiENcE/luis/blob/main/assets/logo_small.png">
 </a>
</p>

**LUIS** (Love User Interface System) is a flexible graphical user interface (GUI) framework built on top of the [Löve2D](https://love2d.org/) game framework. LUIS provides developers with the tools to create dynamic, grid-centric, layered user interfaces for games and applications.

## LUIS: Samples

Look at our [LUIS-Samples](https://github.com/SiENcE/luis_samples/)

<p align="center">
 <a href="https://github.com/SiENcE/luis_samples/blob/main/assets/recordings/Recording_2024-11-12_00.58.43.gif">
  <img border="0" style="max-width:100%; height:auto;" src="https://github.com/SiENcE/luis_samples/blob/main/assets/recordings/Recording_2024-11-12_00.58.43.gif">
 </a>
</p>
<p align="center">
 <em>A LUIS UI-Editor made with LUIS.</em>
</p>

## Features

| Feature | Description |
|---------|-------------|
| Flexible Layout | Uses a grid-based system and FlexContainers for easy UI layout |
| Layer Management | Support for multiple UI layers with show/hide functionality & Z-indexing for element layering |
| Theme Support | Global theme customization, Per-widget theme overrides |
| Customizable Theming | Easily change the look and feel of your UI elements |
| Widget API | Core system for loading and managing widgets (widgets themselves are optional and loaded dynamically) |
| Event Handling | Built-in support for mouse, touch, keyboard, and gamepad interactions & focus management |
| Responsive Design | Automatically scales UI elements and interaction based on screen dimensions |
| State Management | Tracks and persists element states to save and load configurations |
| Extensibility | Modular design allowing easy addition of new widgets or removing unneeded widgets (see Widget Types section) |
| Debug Mode | Toggle grid and element outlines for easy development |

**Note**: These features are all part of the LUIS core library (`core.lua`), which has **zero dependencies**! You can use the core library on its own and implement your own widgets for a lightweight UI system for [Löve2D](https://love2d.org/) without any additional dependencies.

## Widget Types

LUIS comes with a variety of pre-built widgets to create rich user interfaces. While the following widgets are included, they are **completely optional** and are only loaded when you specify a widget folder during initialization. This modular approach allows you to use only the widgets you need or create your own custom widgets:

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
12. **ColorPicker**: Choose and Select a color
13. **Node**: A node to build an interactive NodeGraph
14. **DialogueWheel**: Circular interface that presents selectable options in a radial format
15. **Custom**: Add your own drawing function
16. **FlexContainer**: Special container for flexible layouts

## Getting Started

1. **Install Löve2D**: You can download Löve2D from [here](https://love2d.org/).
2. **Clone the LUIS Library into your project**:
    ```bash
    git clone https://github.com/SiENCE/LUIS.git
    ```
3. **Include LUIS in Your Löve2D Project**:
    ```lua
    -- Initialize LUIS
    local initLuis = require("luis.init")
    
    -- Direct this to your widgets folder.
    local luis = initLuis("luis/widgets")
    ```

4. **Create and Manage UI Elements**:
    Use LUIS functions to define layers, add UI elements, and manage their states.

## Example

Here's a simple example to create a FlexContainer with two buttons and a slider (press 'TAB' for debug view):

main.lua
```lua
local initLuis = require("luis.init")

-- Direct this to your widgets folder.
local luis = initLuis("luis/widgets")

-- register flux in luis, some widgets need it for animations
luis.flux = require("luis.3rdparty.flux")

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

local time = 0
function love.update(dt)
	time = time + dt
	if time >= 1/60 then	
		luis.flux.update(time)
		time = 0
	end

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

### FlexContainer

The FlexContainer is a powerful widget that allows for dynamic and responsive layouts:

- **Drag and Resize**: Containers can be moved and resized at runtime
- **Auto-arranging**: Child elements are automatically arranged within the container
- **Nested Containers**: Create complex layouts by nesting FlexContainers
- **Padding Control**: Adjust spacing between child elements

Example usage:

```lua
local container = luis.newFlexContainer(30, 30, 10, 10)
local button1 = luis.newButton("Button 1", 15, 3, function() print("Button 1 clicked!") end, function() print("Button 1 released!") end, 5, 2)
local button2 = luis.newButton("Button 2", 15, 3, function() print("Button 2 clicked!") end, function() print("Button 2 released!") end, 5, 2)

container:addChild(button1)
container:addChild(button2)

luis.createElement(luis.currentLayer, "FlexContainer", container)
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

## Widget Decorators

LUIS supports the Decorator pattern, allowing you to dynamically add visual effects and behaviors to widgets. Each widget includes built-in support for decorators that can modify their appearance without changing their core functionality.

Example usage:

```lua
-- Create a button with a glass morphism
local button = luis.newButton("Glassmorphism Button", 15, 3, onClick, onRelease, 5, 2)
button:setDecorator("GlassmorphismDecorator", {1, 0.5, 0, 0.5}, 15)  -- Glass morphism with size 15

-- Create a button with a glow effect
local button = luis.newButton("Glowing Button", 15, 3, onClick, onRelease, 5, 2)
button:setDecorator("GlowDecorator", {1, 0.5, 0, 0.5}, 15)  -- Orange glow with size 15

-- Create a button with a 9-slice border
local button2 = luis.newButton("Bordered Button", 15, 3, onClick, onRelease, 5, 2)
button2:setDecorator("Slice9Decorator", borderImage, 10, 10, 10, 10)  -- 10px borders
```

Available decorators:
- **GlassmorphismDecorator**: Implements a modern glassmorphism effect with customizable transparency, blur, borders, and shadows.
- **GlowDecorator**: Adds a customizable glow effect around the widget
- **Slice9Decorator**: Implements 9-slice scaling for bordered widgets

## Documentation

For more detailed information on the LUIS API, including layer management, input handling, theming, and state management, please refer to the [LUIS core documentation](/luis/luis-api-documentation.md).

## Dependencies

- Löve2D: The game framework used for rendering and managing game objects.
- The **core** library has **zero dependencies**, so you write your own widgets to have a lightweight ui system (see [basic_ui_sample](https://github.com/SiENcE/luis_samples/blob/main/samples/basic_ui) ).

## known Problems

- DropBox: Selection with the gamepad-analogstick works not for all choices
- FlexContainer - dropdown select is not possible via gamepad-analogstick
- TextInput - when changing Theme, we have to adjust the fontsize in TextInput widgets
- TextInputMultiLine not setConfig/getConfig

## License

This project is licensed under the MIT License with additional terms - see the [LICENSE](LICENSE) file for details.
**Important:** Use of this software for training AI or machine learning models is strictly prohibited. See the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
