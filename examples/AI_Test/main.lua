-- Import LUIS library
local initLuis = require("luis.init")
-- Direct this to your widgets folder.
local luis = initLuis("examples/complex_ui/widgets")

-- register flux in luis, because the widgets of complex_ui need this
luis.flux = require("examples.3rdparty.flux")

-- Layers for different menu states
local mainMenuLayer = "MainMenu"
local settingsLayer = "Settings"
local creditsLayer = "Credits"

-- Initialize the menu
function love.load()
    -- Set the grid size (e.g., 16x16 grid for layout)
    luis.setGridSize(16)

    -- Create layers for different menus
    luis.newLayer(mainMenuLayer)
    luis.newLayer(settingsLayer)
    luis.newLayer(creditsLayer)

    -- Main menu buttons
    luis.createElement(mainMenuLayer, "Button", "Start Game", 4, 2, startGame, nil, 6, 4)
    luis.createElement(mainMenuLayer, "Button", "Settings", 4, 2, openSettings, nil, 6, 8)
    luis.createElement(mainMenuLayer, "Button", "Credits", 4, 2, showCredits, nil, 6, 12)
    luis.createElement(mainMenuLayer, "Button", "Exit", 4, 2, love.event.quit, nil, 6, 16)

    -- Settings menu (back Button and options)
    luis.createElement(settingsLayer, "Button", "Back", 4, 2, returnToMainMenu, nil, 6, 16)
    luis.createElement(settingsLayer, "Label", "Sound: ", 4, 1, 6, 6)
    luis.createElement(settingsLayer, "ProgressBar", 0.5, 4, 2, 8, 6)
    luis.createElement(settingsLayer, "Label", "Graphics: ", 4, 1, 6, 10)
    luis.createElement(settingsLayer, "DropDown", {"Low", "Medium", "High"}, 1, 4, 2, nil, 8, 10)

    -- Credits menu
    luis.createElement(creditsLayer, "Label", "Game by XYZ Studios", 8, 1, 4, 8)
    luis.createElement(creditsLayer, "Button", "Back", 4, 2, returnToMainMenu, nil, 6, 16)

    -- Start with main menu active
    luis.setCurrentLayer(mainMenuLayer)
end

-- Update the UI elements
function love.update(dt)
    luis.update(dt)
end

-- Draw the UI elements
function love.draw()
    luis.draw()
end

-- Input handling for the UI
function love.mousepressed(x, y, button, istouch, presses)
    luis.mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    luis.mousereleased(x, y, button, istouch, presses)
end

-- Switch to the game
function startGame()
    print("Starting the game...")
end

-- Switch to the settings menu
function openSettings()
    luis.setCurrentLayer(settingsLayer)
end

-- Show credits
function showCredits()
    luis.setCurrentLayer(creditsLayer)
end

-- Return to main menu
function returnToMainMenu()
    luis.setCurrentLayer(mainMenuLayer)
end

