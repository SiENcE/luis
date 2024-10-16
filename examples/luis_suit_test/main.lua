local initLuis = require("luis.init")
local luis = initLuis("examples/complex_ui/widgets")
luis.flux = require("examples.3rdparty.flux")

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
		luis.setCurrentLayer("mainMenu")
    elseif button == buttons.settings then
        currentScreen = "settings"
		luis.setCurrentLayer("settings")
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
		luis.setCurrentLayer("mainMenu")
    end
end

function love.load()
    screenWidth, screenHeight = love.graphics.getDimensions()
    retroFont = love.graphics.newFont("examples/luis_suit_test/retroFont.ttf", 32)
    love.graphics.setFont(retroFont)

    -- Initialize LUIS
    luis.setGridSize(10)  -- Assuming a 32x18 grid for 1920x1080 resolution

    -- Retro color scheme
    luis.setTheme({
		background = {
			color = {0.05, 0.05, 0.15}, -- Dark retro background color
		},
		text = {
			color = {1, 1, 1},
			font = retroFont,
			align = "left",
		},
		button = {
			color = {0.1, 0.1, 0.3, 1},
			hoverColor = {0.4, 0.4, 0.8, 1},
			pressedColor = {0.2, 0.2, 0.5, 1},
			textColor = {0.9, 0.9, 0.6, 1},
			align = "center",
			cornerRadius = 4,
			elevation = 0,
			elevationHover = 0,
			elevationPressed = 0,
			transitionDuration = 0,
		},
	})

    -- Create layers for each screen
    luis.newLayer("mainMenu")
    luis.newLayer("settings")

	-- Main menu buttons
	luis.createElement("mainMenu", "Button", buttons.newGame.text, 30, 5, function() handleMainMenuClick(buttons.newGame) end, nil, 20, 24)
	luis.createElement("mainMenu", "Button", buttons.settings.text, 30, 5, function() handleMainMenuClick(buttons.settings) end, nil, 25, 24)
	luis.createElement("mainMenu", "Button", buttons.highscore.text, 30, 5, function() handleMainMenuClick(buttons.highscore) end, nil, 30, 24)
	luis.createElement("mainMenu", "Button", buttons.quit.text, 30, 5, function() handleMainMenuClick(buttons.quit) end, nil, 35, 24)

	-- Settings menu buttons
	luis.createElement("settings", "Button", buttons.sound.text, 30, 5, function() handleSettingsClick(buttons.sound) end, nil, 20, 24)
	luis.createElement("settings", "Button", buttons.display.text, 30, 5, function() handleSettingsClick(buttons.display) end, nil, 25, 24)
	luis.createElement("settings", "Button", buttons.back.text, 30, 5, function() handleSettingsClick(buttons.back) end, nil, 30, 24)
	
	luis.setCurrentLayer("mainMenu")
end

local accumulator = 0
function love.update(dt)
    accumulator = accumulator + dt
    if accumulator >= 1/60 then
        luis.flux.update(accumulator)
        accumulator = 0
    end

    luis.update(dt)
end

function love.draw()
    if currentScreen == "mainMenu" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Main Menu", 0, screenHeight / 2 - 180, screenWidth, "center")
    elseif currentScreen == "settings" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Settings Menu", 0, screenHeight / 2 - 180, screenWidth, "center")
    end

    luis.draw()
end

function love.mousepressed(x, y, button, istouch, presses)
    luis.mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    luis.mousereleased(x, y, button, istouch, presses)
end
