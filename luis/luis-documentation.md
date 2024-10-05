# LUIS (Love2D UI System) Documentation

## Table of Contents

1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Core Concepts](#core-concepts)
   - [Layers](#layers)
   - [Widgets](#widgets)
   - [Theming](#theming)
4. [Basic Usage](#basic-usage)
5. [Widget Gallery](#widget-gallery)
6. [Advanced Features](#advanced-features)
7. [API Reference](#api-reference)
8. [Examples](#examples)
9. [Troubleshooting](#troubleshooting)

## Introduction

LUIS (Love2D UI System) is a flexible and extensible UI library for the LÖVE2D framework. It provides a comprehensive set of tools for creating complex user interfaces in your LÖVE2D games and applications.

Key features:
- Layer-based UI management
- Customizable theming system
- Responsive layout options
- Comprehensive input handling (mouse, keyboard, gamepad)
- Easy-to-use widget system

## Getting Started

### Installation

1. Download the LUIS library and place it in your LÖVE2D project directory.
2. Require the library in your `main.lua` file:

```lua
local luis = require("luis")
```

### Basic Setup

Here's a minimal setup to get LUIS running in your LÖVE2D project:

```lua
local luis = require("luis")

function love.load()
    luis.init()
    luis.newLayer("main")
    luis.enableLayer("main")
    
    luis.newButton("main", {
        text = "Click me!",
        x = 100,
        y = 100,
        width = 200,
        height = 50,
        onClick = function()
            print("Button clicked!")
        end
    })
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
```

## Core Concepts

### Layers

LUIS uses a layer-based system for organizing UI elements. Layers can be enabled, disabled, or toggled, allowing for easy management of complex UI hierarchies.

```lua
luis.newLayer("menu")
luis.enableLayer("menu")
luis.disableLayer("menu")
luis.toggleLayer("menu")
```

### Widgets

Widgets are the building blocks of your UI. LUIS provides a variety of pre-built widgets like buttons, sliders, and text inputs. You can also create custom widgets.

```lua
luis.newButton("main", {
    text = "Click me!",
    x = 100,
    y = 100,
    width = 200,
    height = 50,
    onClick = function()
        print("Button clicked!")
    end
})
```

### Theming

LUIS includes a powerful theming system that allows you to customize the look and feel of your UI.

```lua
luis.setTheme({
    button = {
        color = {0.2, 0.6, 0.8},
        textColor = {1, 1, 1},
        cornerRadius = 5
    }
})
```

## Basic Usage

Here's a more comprehensive example showcasing basic LUIS usage:

```lua
local luis = require("luis")

function love.load()
    luis.init()
    luis.newLayer("main")
    luis.enableLayer("main")
    
    luis.newButton("main", {
        text = "Click me!",
        x = 100,
        y = 100,
        width = 200,
        height = 50,
        onClick = function()
            print("Button clicked!")
        end
    })
    
    luis.newSlider("main", {
        x = 100,
        y = 200,
        width = 200,
        height = 20,
        min = 0,
        max = 100,
        value = 50,
        onChange = function(value)
            print("Slider value: " .. value)
        end
    })
    
    luis.newCheckBox("main", {
        x = 100,
        y = 250,
        width = 20,
        height = 20,
        text = "Check me",
        onChange = function(checked)
            print("Checkbox " .. (checked and "checked" or "unchecked"))
        end
    })
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
```

## Widget Gallery

LUIS provides a variety of pre-built widgets:

- Button
- Slider
- Checkbox
- Radio Button
- Text Input
- Dropdown
- Progress Bar
- Image
- Label
- Panel

Each widget has its own set of properties and events. Refer to the API Reference for detailed information on each widget.

## Advanced Features

### Custom Widgets

You can create custom widgets by defining a new widget module:

```lua
local CustomWidget = {}

function CustomWidget.new(layer, options)
    -- Implementation here
end

function CustomWidget:update(dt)
    -- Update logic here
end

function CustomWidget:draw()
    -- Draw logic here
end

return CustomWidget
```

### Layout Management

LUIS provides a FlexContainer for creating flexible layouts:

```lua
luis.newFlexContainer("main", {
    x = 100,
    y = 100,
    width = 400,
    height = 300,
    direction = "column",
    spacing = 10
})
```

### State Management

LUIS allows you to save and load UI states:

```lua
luis.saveConfig("ui_config.json")
luis.loadConfig("ui_config.json")
```

## API Reference

(Detailed API reference would go here, documenting all functions, widgets, and their properties)

## Examples

### Creating a Simple Menu

```lua
local luis = require("luis")

function love.load()
    luis.init()
    luis.newLayer("menu")
    luis.enableLayer("menu")
    
    luis.newButton("menu", {
        text = "Start Game",
        x = 300,
        y = 200,
        width = 200,
        height = 50,
        onClick = function()
            print("Starting game...")
        end
    })
    
    luis.newButton("menu", {
        text = "Options",
        x = 300,
        y = 275,
        width = 200,
        height = 50,
        onClick = function()
            print("Opening options...")
        end
    })
    
    luis.newButton("menu", {
        text = "Quit",
        x = 300,
        y = 350,
        width = 200,
        height = 50,
        onClick = function()
            love.event.quit()
        end
    })
end

-- (Include update, draw, and input handling functions as before)
```

## Troubleshooting

Common issues and their solutions:

1. **Widgets not appearing**: Ensure that you've created and enabled the correct layer.
2. **Input not working**: Make sure you're calling the appropriate LUIS input functions in your LÖVE2D callbacks.
3. **Styling issues**: Check your theme settings and make sure they're applied correctly.

For more help, please refer to the LUIS GitHub repository or community forums.

