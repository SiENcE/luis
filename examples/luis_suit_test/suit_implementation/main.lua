local suit = require 'suit'
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

-- State variable to keep track of settings options
local soundOn = true
local fullscreen = false

-- Function for handling main menu button actions
local function handleMainMenuClick(button)
    if button == buttons.newGame then
        print("Starting a New Game!")
    elseif button == buttons.settings then
        currentScreen = "settings"
    elseif button == buttons.highscore then
        print("Displaying Highscores!")
    elseif button == buttons.quit then
        love.event.quit()
    end
end

-- Function for handling settings menu button actions
local function handleSettingsClick(button)
    if button == buttons.sound then
        soundOn = not soundOn
        buttons.sound.text = "Sound: " .. (soundOn and "ON" or "OFF")
        print("Sound toggled to", buttons.sound.text)
    elseif button == buttons.display then
        fullscreen = not fullscreen
        love.window.setFullscreen(fullscreen)
        buttons.display.text = "Display: " .. (fullscreen and "Fullscreen" or "Windowed")
        print("Display toggled to", buttons.display.text)
    elseif button == buttons.back then
        currentScreen = "mainMenu"
    end
end

function love.load()
    screenWidth, screenHeight = love.graphics.getDimensions()
    retroFont = love.graphics.newFont("retroFont.ttf", 32) -- Load a retro font here
    love.graphics.setFont(retroFont)

    -- Retro color scheme
    suit.theme.color = {
        normal = {bg = {0.1, 0.1, 0.3}, fg = {0.9, 0.9, 0.6}},
        hovered = {bg = {0.4, 0.4, 0.8}, fg = {1, 1, 0}},
        active = {bg = {0.2, 0.2, 0.5}, fg = {1, 0.6, 0.6}},
    }
end

function love.update(dt)
    suit.layout:reset(screenWidth / 2 - 150, screenHeight / 2 - 100)

    if currentScreen == "mainMenu" then
        -- Main menu buttons
        if suit.Button(buttons.newGame.text, suit.layout:row(300, 50)).hit then
            handleMainMenuClick(buttons.newGame)
        end

        if suit.Button(buttons.settings.text, suit.layout:row(300, 50)).hit then
            handleMainMenuClick(buttons.settings)
        end

        if suit.Button(buttons.highscore.text, suit.layout:row(300, 50)).hit then
            handleMainMenuClick(buttons.highscore)
        end

        if suit.Button(buttons.quit.text, suit.layout:row(300, 50)).hit then
            handleMainMenuClick(buttons.quit)
        end

    elseif currentScreen == "settings" then
        -- Settings menu buttons
        if suit.Button(buttons.sound.text, suit.layout:row(300, 50)).hit then
            handleSettingsClick(buttons.sound)
        end

        if suit.Button(buttons.display.text, suit.layout:row(300, 50)).hit then
            handleSettingsClick(buttons.display)
        end

        if suit.Button(buttons.back.text, suit.layout:row(300, 50)).hit then
            handleSettingsClick(buttons.back)
        end
    end
end

function love.draw()
    love.graphics.setBackgroundColor(0.05, 0.05, 0.15) -- Dark retro background color

    if currentScreen == "mainMenu" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Main Menu", 0, screenHeight / 2 - 180, screenWidth, "center")
    elseif currentScreen == "settings" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Settings Menu", 0, screenHeight / 2 - 180, screenWidth, "center")
    end

    suit.draw()
end
