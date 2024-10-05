local initLuis = require("luis.init")
-- point this to your widgets folder
local luis = initLuis("examples/basic_ui/widgets")

local RetroMenu = {}

-- Retro-style color palette
local colors = {
    background = {0.1, 0.1, 0.2},
    text = {0.9, 0.9, 1},
    highlight = {1, 0.5, 0},
    button = {0.2, 0.2, 0.4},
    buttonHover = {0.3, 0.3, 0.5}
}

-- Custom retro font (you'll need to provide this font file)
local retroFont = love.graphics.newFont(32)

-- Initialize the menu
function RetroMenu.init()
    luis.setTheme({
        background = { color = colors.background },
        text = { color = colors.text, font = retroFont, align = "center" },
        button = {
            color = colors.button,
            hoverColor = colors.buttonHover,
            textColor = colors.text,
            cornerRadius = 0,
        }
    })

    RetroMenu.createMainMenu()
    RetroMenu.createOptionsMenu()
    RetroMenu.createHighScoresMenu()

    luis.enableLayer("main_menu")
end

-- Create main menu
function RetroMenu.createMainMenu()
    luis.newLayer("main_menu")
    
    local centerX = love.graphics.getWidth() / 2
    local startY = 200
    local buttonWidth = 300
    local buttonHeight = 60
    local spacing = 20

    luis.createElement("main_menu", "Label", centerX - 150, 100, "RETRO GAME", 300)

    luis.createElement("main_menu", "Button", centerX - buttonWidth/2, startY, buttonWidth, buttonHeight, "Start Game", function() print("Start Game") end)
    luis.createElement("main_menu", "Button", centerX - buttonWidth/2, startY + buttonHeight + spacing, buttonWidth, buttonHeight, "Options", function() RetroMenu.showOptions() end)
    luis.createElement("main_menu", "Button", centerX - buttonWidth/2, startY + (buttonHeight + spacing) * 2, buttonWidth, buttonHeight, "High Scores", function() RetroMenu.showHighScores() end)
    luis.createElement("main_menu", "Button", centerX - buttonWidth/2, startY + (buttonHeight + spacing) * 3, buttonWidth, buttonHeight, "Quit", function() love.event.quit() end)
end

-- Create options menu
function RetroMenu.createOptionsMenu()
    luis.newLayer("options_menu")
    
    local centerX = love.graphics.getWidth() / 2
    local startY = 200
    local width = 300
    local height = 60
    local spacing = 20

    luis.createElement("options_menu", "Label", centerX - 150, 100, "OPTIONS", 300)

    luis.createElement("options_menu", "Label", centerX - 150, startY, "Music Volume", 300)
    luis.createElement("options_menu", "Slider", centerX - width/2, startY + 40, width, 0, 100, 50, function(value) print("Music volume:", value) end)

    luis.createElement("options_menu", "Label", centerX - 150, startY + 120, "Sound Effects", 300)
    luis.createElement("options_menu", "Slider", centerX - width/2, startY + 160, width, 0, 100, 75, function(value) print("SFX volume:", value) end)

    luis.createElement("options_menu", "Label", centerX - width/2, startY + 230, "Fullscreen", 300)
    luis.createElement("options_menu", "CheckBox", centerX - width/2, startY + 240, 30, false, function(value) print("Fullscreen:", value) end)

    luis.createElement("options_menu", "Button", centerX - width/2, startY + 320, width, height, "Back", function() RetroMenu.showMainMenu() end)
end

-- Create high scores menu
function RetroMenu.createHighScoresMenu()
    luis.newLayer("high_scores_menu")
    
    local centerX = love.graphics.getWidth() / 2
    local startY = 200
    local width = 300
    local height = 60

    luis.createElement("high_scores_menu", "Label", centerX - 150, 100, "HIGH SCORES", 300)

    -- Dummy high scores (replace with actual high scores logic)
    local highScores = {
        {name = "AAA", score = 1000},
        {name = "BBB", score = 900},
        {name = "CCC", score = 800},
        {name = "DDD", score = 700},
        {name = "EEE", score = 600},
    }

    for i, score in ipairs(highScores) do
        luis.createElement("high_scores_menu", "Label", centerX - 150, startY + (i-1) * 40, string.format("%d. %s - %d", i, score.name, score.score), 300)
    end

    luis.createElement("high_scores_menu", "Button", centerX - width/2, startY + 300, width, height, "Back", function() RetroMenu.showMainMenu() end)
end

-- Helper functions to switch between menus
function RetroMenu.showMainMenu()
    luis.disableLayer("options_menu")
    luis.disableLayer("high_scores_menu")
    luis.enableLayer("main_menu")
end

function RetroMenu.showOptions()
    luis.disableLayer("main_menu")
    luis.disableLayer("high_scores_menu")
    luis.enableLayer("options_menu")
end

function RetroMenu.showHighScores()
    luis.disableLayer("main_menu")
    luis.disableLayer("options_menu")
    luis.enableLayer("high_scores_menu")
end

return RetroMenu
