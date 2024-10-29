
local Gspot = require 'Gspot'

local currentScreen = "mainMenu"

local buttons = {
    newGame = {text = "New Game"},
    settings = {text = "Settings"},
    highscore = {text = "Highscore"},
    quit = {text = "Quit"},
    -- Settings submenu buttons
    sound = {text = "Sound: ON"},
    display = {text = "Display: Fullscreen"},
    back = {text = "Back to Main Menu"}
}

local retroFont
local screenWidth, screenHeight
local gspot -- Gspot instance
local soundOn = true
local fullscreen = false

-- Function to initialize Gspot elements for settings menu
function initSettingsMenu()
    gspot = Gspot() -- Reinitialize Gspot for the settings menu

    local y = 300
    local gap = 50

    gspot:button(buttons.sound.text, {x = screenWidth / 2 - 50, y = y, w = 300, h = 50}).click = function()
        soundOn = not soundOn
        buttons.sound.text = soundOn and "Sound: ON" or "Sound: OFF"
        initSettingsMenu() -- Reinitialize to update the button label
    end
    y = y + gap

    gspot:button(buttons.display.text, {x = screenWidth / 2 - 50, y = y, w = 300, h = 50}).click = function()
        fullscreen = not fullscreen
        buttons.display.text = fullscreen and "Display: Fullscreen" or "Display: Windowed"
        love.window.setFullscreen(fullscreen)
        initSettingsMenu() -- Reinitialize to update the button label
    end
    y = y + gap

    gspot:button(buttons.back.text, {x = screenWidth / 2 - 50, y = y, w = 300, h = 50}).click = function()
        currentScreen = "mainMenu"
        initMainMenu()
    end
end

-- Function to initialize Gspot elements for main menu
function initMainMenu()
    gspot = Gspot() -- Create a new Gspot instance

    local y = 300
    local gap = 50

    gspot:button(buttons.newGame.text, {x = screenWidth / 2 - 50, y = y, w = 300, h = 50}).click = function()
        print("Starting a New Game!")
    end
    y = y + gap

    gspot:button(buttons.settings.text, {x = screenWidth / 2 - 50, y = y, w = 300, h = 50}).click = function()
        currentScreen = "settings"
        initSettingsMenu()
    end
    y = y + gap

    gspot:button(buttons.highscore.text, {x = screenWidth / 2 - 50, y = y, w = 300, h = 50}).click = function()
        print("Displaying Highscores!")
    end
    y = y + gap

    gspot:button(buttons.quit.text, {x = screenWidth / 2 - 50, y = y, w = 300, h = 50}).click = function()
        love.event.quit()
    end
end

-- Love2D callback functions
function love.load()
    retroFont = love.graphics.newFont("retroFont.ttf", 32) -- Load a retro font here
    love.graphics.setFont(retroFont)

    screenWidth, screenHeight = love.graphics.getDimensions()
    initMainMenu() -- Initialize the main menu
end

function love.update(dt)
    gspot:update(dt)
end

function love.draw()
    gspot:draw()
end

function love.mousepressed(x, y, button)
    gspot:mousepress(x, y, button)
end

function love.mousereleased(x, y, button)
    gspot:mouserelease(x, y, button)
end

