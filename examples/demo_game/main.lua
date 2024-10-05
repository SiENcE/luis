local initLuis = require("luis.init")
-- point this to your widgets folder
local luis = initLuis("examples/complex_ui/widgets")

-- register flux in LUIS, because the widgets of complex_ui need this
luis.flux = require("examples.3rdparty.flux")

-- Initialize the luis
love.window.setMode(800, 600)
luis.baseWidth, luis.baseHeight = 800, 600
luis.updateScale()
luis.setGridSize(30)  -- 30x30 grid for the whole gui

-- Create a new layer for our game interface
luis.newLayer("game")
luis.newLayer("battle")
luis.newLayer("camp")

luis.theme.text.font = love.graphics.newFont(18, "normal")

-- Game state
local gameState = {
    currentView = "game",  -- "game", "battle", "camp"
    party = {
        { name = "Warrior", hp = 50, maxHp = 50, mp = 0, maxMp = 0, level = 1 },
        { name = "Mage", hp = 30, maxHp = 30, mp = 40, maxMp = 40, level = 1 },
        { name = "Priest", hp = 40, maxHp = 40, mp = 30, maxMp = 30, level = 1 },
        { name = "Thief", hp = 35, maxHp = 35, mp = 10, maxMp = 10, level = 1 }
    },
    enemies = {},
	viewDistance = 3,
	cellSize = 10,
    dungeonLevel = 1,
    dungeonMap = {},  -- Will be populated with a 10x10 grid of walls and corridors
	player = {
		x = 0,
		y = 0,
		direction = 0  -- 0: North, 1: East, 2: South, 3: West
	},
}

-- Generate a simple dungeon map
local function generateDungeon()
    local map = {}
    for y = 1, 20 do
        map[y] = {}
        for x = 1, 20 do
            if x == 1 or y == 1 or x == 20 or y == 20 then
                map[y][x] = 1  -- Wall
            else
                map[y][x] = love.math.random() < 0.7 and 0 or 1  -- 70% chance of floor, 30% wall
            end
        end
    end
    gameState.dungeonMap = map
end

generateDungeon()

-- Update movement functions
local function moveForward()
    local dx, dy = 0, 0
    if gameState.player.direction == 0 then dy = -1
    elseif gameState.player.direction == 1 then dx = 1
    elseif gameState.player.direction == 2 then dy = 1
    else dx = -1 end
    
    local newX, newY = gameState.player.x + dx, gameState.player.y + dy
    if gameState.dungeonMap[newY + 11][newX + 11] == 0 then  -- Check if the new position is a floor tile
        gameState.player.x, gameState.player.y = newX, newY
    end
end

local function turnLeft()
    gameState.player.direction = (gameState.player.direction - 1) % 4
end

local function turnRight()
    gameState.player.direction = (gameState.player.direction + 1) % 4
end

-- Dungeon view (3D-like view in the center)
local dungeonView = luis.createElement("game", "Custom", function()
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("line", 0, 0, 200, 200)
    --drawWireframeDungeon(gameState.player.x, gameState.player.y, 80, 80, 1,1)
end, 10, 10, 4, 20)

-- Minimap (top-right corner)
local minimap = luis.createElement("game", "Custom", function()
    love.graphics.setColor(1, 1, 1)
    local cellSize = gameState.cellSize
    for y = 1, 20 do
        for x = 1, 20 do
            if gameState.dungeonMap[y][x] == 1 then
                love.graphics.rectangle("fill", (x-1)*cellSize, (y-1)*cellSize, cellSize, cellSize)
            end
        end
    end
    -- Draw player position
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", (gameState.player.x + 10.5) * cellSize, (gameState.player.y + 10.5) * cellSize, cellSize/2)
end, 10, 10, 4, 9)

-- Party stats (left side)
for i, character in ipairs(gameState.party) do
    local yPos = (i-1) * 4 + 1
    luis.createElement("game", "Label", character.name, 8, 1, yPos, 1)
    local hpBar = luis.createElement("game", "ProgressBar", character.hp / character.maxHp, 8, 1, yPos+1, 1)
    local hpLabel = luis.createElement("game", "Label", "HP: " .. character.hp .. "/" .. character.maxHp, 8, 1, yPos+1, 2)
    if character.maxMp > 0 then
        local mpBar = luis.createElement("game", "ProgressBar", character.mp / character.maxMp, 8, 1, yPos+2, 1)
        local mpLabel = luis.createElement("game", "Label", "MP: " .. character.mp .. "/" .. character.maxMp, 8, 1, yPos+2, 2)
    end
end

-- Action buttons (bottom of the screen)
luis.createElement("game", "Button", "Move", 5, 2, moveForward, function() end, 16, 5)
luis.createElement("game", "Button", "Turn Left", 5, 2, turnLeft, function() end, 16, 10)
luis.createElement("game", "Button", "Turn Right", 5, 2, turnRight, function() end, 16, 15)
luis.createElement("game", "Button", "Camp", 5, 2, function() gameState.currentView = "camp" end, function() end, 16, 20)

-- Battle view elements (initially hidden)
local battleElements = {}

local function createBattleElements()
	local enemies = {
			{ name = "Goblin", hp = 20, maxHp = 20 },
			{ name = "Orc", hp = 30, maxHp = 30 }
		}

    -- Enemy info
    for i, enemy in ipairs(enemies) do
        local yPos = (i-1) * 3 + 1
        battleElements[#battleElements+1] = luis.createElement("battle", "Label", enemy.name, 8, 1, yPos, 18)
        local enemyHpBar = luis.createElement("battle", "ProgressBar", enemy.hp / enemy.maxHp, 8, 1, yPos+1, 18)
        battleElements[#battleElements+1] = enemyHpBar
        local enemyHpLabel = luis.createElement("battle", "Label", "HP: " .. enemy.hp .. "/" .. enemy.maxHp, 8, 1, yPos+1, 19)
        battleElements[#battleElements+1] = enemyHpLabel
    end

    -- Battle actions
    battleElements[#battleElements+1] = luis.createElement("battle", "Button", "Attack", 5, 2, function() print("Attacking!") end, function() end, 16, 5)
    battleElements[#battleElements+1] = luis.createElement("battle", "Button", "Defend", 5, 2, function() print("Defending!") end, function() end, 16, 10)
    battleElements[#battleElements+1] = luis.createElement("battle", "Button", "Magic", 5, 2, function() print("Using magic!") end, function() end, 16, 15)
    battleElements[#battleElements+1] = luis.createElement("battle", "Button", "Item", 5, 2, function() print("Using item!") end, function() end, 16, 20)
end

createBattleElements()

-- Camp view elements (initially hidden)
local campElements = {}

local function createCampElements()
    campElements[#campElements+1] = luis.createElement("camp", "Button", "Rest", 5, 2, function() print("Resting...") end, function() end, 10, 5)
    campElements[#campElements+1] = luis.createElement("camp", "Button", "Save Game", 5, 2, function() print("Saving game...") end, function() end, 10, 10)
    campElements[#campElements+1] = luis.createElement("camp", "Button", "Return to Dungeon", 5, 2, function() gameState.currentView = "game" end, function() end, 10, 15)
end

createCampElements()

-- Update function
function love.update(dt)
    luis.update(dt)

    -- Show/hide elements based on current view
	if gameState.currentView == "battle" then
		luis.setCurrentLayer("battle")
		luis.disableLayer("camp")
		luis.disableLayer("game")
	elseif gameState.currentView == "camp" then
		luis.setCurrentLayer("camp")
		luis.disableLayer("battle")
		luis.disableLayer("game")
	else -- "game"
		luis.setCurrentLayer("game")
		luis.disableLayer("battle")
		luis.disableLayer("camp")
	end
	
    -- Simulate occasional random encounters
    if gameState.currentView == "game" and love.math.random() < 0.001 then
        gameState.currentView = "battle"
    end
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
	if key == 'up' then
		moveForward()
	elseif key == 'left' then
		turnLeft()
	elseif key == 'right' then
		turnRight()
	else
		luis.keypressed(key)
	end
end
