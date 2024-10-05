local initLuis = require("luis.init")
-- point this to your widgets folder
local luis = initLuis("examples/complex_ui/widgets")

-- register flux in luis, because the widgets of complex_ui need this
luis.flux = require("examples.3rdparty.flux")

-- widgets
local textInput
local healthBar
local healthBar_label
local manaBar
local manaBar_label
local enemyHealthBar

-- Variables for health and mana animation
local healthValue = 1
local manaValue = 1
local healthDirection = -1
local manaDirection = -1

-- Initialize the luis
function love.load()
	love.window.setMode(1920, 1080)
	luis.baseWidth, luis.baseHeight = 1920, 1080
	luis.updateScale()

	-- Create a new layer for our game interface
	luis.newLayer("game")	-- create new Layer
	luis.setGridSize(48)  -- 48x48 grid for the whole gui
	luis.setCurrentLayer("game") -- make game the currentLayer

	luis.theme.text.font = love.graphics.newFont(18, "normal")

	local progressBar = {
        backgroundColor = {0.15, 0.15, 0.15, 1},
        fillColor = {0.1, 0.5, 0.8, 1},
        borderColor = {1, 1, 1, 1},
    }

	-- Player stats (top-left corner)
	healthBar = luis.createElement("game", "ProgressBar", 1, 10, 1, 1, 1, progressBar)
	healthBar_label = luis.createElement("game", "Label", "HP: 100/100", 5, 1, 1, 2)
	manaBar = luis.createElement("game", "ProgressBar", 1, 10, 1, 2, 1, progressBar)
	manaBar_label = luis.createElement("game", "Label", "MP: 100/100", 5, 1, 2, 2)

	-- Character info (top-left, under stats)
	luis.createElement("game", "Label", "Character: Hero", 8, 1, 4, 4)
	luis.createElement("game", "Label", "Level: 5", 8, 1, 5, 4)
	luis.createElement("game", "Label", "EXP: 450/1000", 8, 1, 6, 4)

	-- Inventory (left side, middle)
	local inventoryItems = {"Potion", "Sword", "Shield", "Magic Scroll"}
	local dropdownbox = luis.createElement("game", "DropDown", inventoryItems, 1, 8, 2, function(item) print("Selected item: " .. item) end, 1, 12)

	-- Action buttons (bottom-left corner)
	luis.createElement("game", "Button", "Attack", 4, 2, function() print("Attack!") end, function() end, 15, 3)
	luis.createElement("game", "Button", "Defend", 4, 2, function() print("Defend!") end, function() end, 15, 8)
	luis.createElement("game", "Button", "Use Item", 4, 2, function() print("Use Item!") end, function() end, 15, 13)
	luis.createElement("game", "Button", "Change", 4, 2, function()
																-- Die Elemente eines Dropdowns aktualisieren
																dropdownbox:setItems({"Helmet", "Armor", "Boots"})
																dropdownbox:setValue(2)
															end, function() end, 15, 18)

	-- Enemy info (top-right corner)
	enemyHealthBar = luis.createElement("game", "ProgressBar", 1, 8, 1, 1, 21, progressBar)
	enemyHealthBar_Label = luis.createElement("game", "Label", "HP: 1000/1000", 8, 1, 1, 22)
	luis.createElement("game", "Label", "Enemy: Dragon", 8, 1, 2, 21)
	luis.createElement("game", "Label", "Level: 10", 8, 1, 3, 21)

	-- Text input for chat or commands (bottom of the screen)
	textInput = luis.createElement("game", "TextInput", 22, 2, "Enter command...", function(text) print(text) textInput:setText("") end, 18, 2)
end

-- Update function
function love.update(dt)
    luis.update(dt)
    
    -- Animate health and mana bars
    healthValue = healthValue + healthDirection * dt * 0.5
    manaValue = manaValue + manaDirection * dt * 0.7
    
    if healthValue <= 0 or healthValue >= 1 then
        healthDirection = -healthDirection
    end
    
    if manaValue <= 0 or manaValue >= 1 then
        manaDirection = -manaDirection
    end
    
    healthBar:setValue(healthValue)
    manaBar:setValue(manaValue)
    
    -- Update health and mana labels
    healthBar_label:setText(string.format("HP: %d/100", math.floor(healthValue * 100)))
    manaBar_label:setText(string.format("MP: %d/100", math.floor(manaValue * 100)))
    
    -- Animate enemy health bar
    local enemyHealth = (math.sin(love.timer.getTime()) + 1) / 2
    enemyHealthBar:setValue(enemyHealth)
	enemyHealthBar_Label:setText(string.format("HP: %d/1000", math.floor(enemyHealth * 1000)))
end

-- Draw function
function love.draw()
    luis.draw()
end

-- Input handling
function love.mousepressed(x, y, button, istouch)
    luis.mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    luis.mousereleased(x, y, button, istouch)
end

function love.wheelmoved(x, y)
    luis.wheelmoved(x, y)
end

function love.textinput(text)
    luis.textinput(text)
end

function love.keypressed(key)
    luis.keypressed(key)
end
