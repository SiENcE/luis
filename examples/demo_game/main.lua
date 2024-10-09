local initLuis = require("luis.init")
-- Direct this to your widgets folder.
local luis = initLuis("examples/complex_ui/widgets")

-- register flux in LUIS, because the widgets of complex_ui need this
luis.flux = require("examples.3rdparty.flux")

love.window.setMode(800, 600)
luis.baseWidth, luis.baseHeight = 800, 600
luis.updateScale()
luis.setGridSize(30)

luis.newLayer("game")
luis.newLayer("battle")
luis.newLayer("camp")

luis.theme.text.font = love.graphics.newFont(18, "normal")

-- Enhanced game state
local gameState = {
    currentView = "game",
    party = {
        { name = "Warrior", hp = 100, maxHp = 100, mp = 20, maxMp = 20, atk = 15, def = 10, mag = 5, level = 1 },
        { name = "Mage", hp = 60, maxHp = 60, mp = 100, maxMp = 100, atk = 5, def = 5, mag = 20, level = 1 },
        { name = "Priest", hp = 80, maxHp = 80, mp = 80, maxMp = 80, atk = 8, def = 8, mag = 15, level = 1 },
        { name = "Thief", hp = 70, maxHp = 70, mp = 40, maxMp = 40, atk = 12, def = 7, mag = 8, level = 1 }
    },
    enemies = {},
    viewDistance = 3,
    cellSize = 10,
    dungeonLevel = 1,
    dungeonMap = {},
    player = {
        x = 1,
        y = 1,
        direction = 1
    },
    inventory = {
        potions = 5,
        elixirs = 2
    }
}

-- Battle system
local battleState = {
    activeCharacter = nil,
    targetEnemy = nil,
    damageText = "",
    damageTimer = 0,
    highlightTimer = 0,
    currentTurn = 1,
    selectedAction = nil,
    targetingMode = false
}


-- Enhanced dungeon generation
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
    -- Ensure start position is clear
    map[1][1] = 0
    map[1][2] = 0
    map[2][1] = 0
	map[2][2] = 0
    gameState.dungeonMap = map
end

generateDungeon()

-- Battle system

function initiateBattle()
    gameState.currentView = "battle"
    gameState.enemies = {
        { name = "Goblin", hp = 30, maxHp = 30, atk = 8, def = 5, isDead = false },
        { name = "Orc", hp = 50, maxHp = 50, atk = 12, def = 8, isDead = false },
        { name = "Troll", hp = 80, maxHp = 80, atk = 15, def = 10, isDead = false }
    }
    battleState.activeCharacter = gameState.party[1]
    battleState.targetEnemy = gameState.enemies[1]
    battleState.currentTurn = 1
    battleState.targetingMode = false
    updateBattleElements()
end

function endBattle()
    gameState.currentView = "game"
    gameState.enemies = {}
    battleState = {
        activeCharacter = nil,
        targetEnemy = nil,
        damageText = "",
        damageTimer = 0,
        highlightTimer = 0,
        currentTurn = 1
    }
    updateBattleElements()
end

battleElements = {}
function updateBattleElements()
    for i, element in ipairs(battleElements) do
        luis.removeElement("battle", element)
    end
    battleElements = {}

    -- Display player characters
    for i, character in ipairs(gameState.party) do
        local yPos = (i-1) * 4 + 1
        battleElements[#battleElements+1] = luis.createElement("battle", "Label", character.name, 8, 1, yPos, 1)
        local hpBar = luis.createElement("battle", "ProgressBar", character.hp / character.maxHp, 8, 1, yPos+1, 1)
        battleElements[#battleElements+1] = hpBar
        local hpLabel = luis.createElement("battle", "Label", "HP: " .. character.hp .. "/" .. character.maxHp, 8, 1, yPos+1, 2)
		hpLabel.zIndex = 100
        battleElements[#battleElements+1] = hpLabel
        local mpBar = luis.createElement("battle", "ProgressBar", character.mp / character.maxMp, 8, 1, yPos+2, 1)
        battleElements[#battleElements+1] = mpBar
        local mpLabel = luis.createElement("battle", "Label", "MP: " .. character.mp .. "/" .. character.maxMp, 8, 1, yPos+2, 2)
		mpLabel.zIndex = 100
        battleElements[#battleElements+1] = mpLabel
    end

    -- Display enemies
    for i, enemy in ipairs(gameState.enemies) do
        local yPos = (i-1) * 3 + 1
        local enemyLabel = luis.createElement("battle", "Label", enemy.name .. (enemy.isDead and " (Dead)" or ""), 8, 1, yPos, 18)
        battleElements[#battleElements+1] = enemyLabel
        if not enemy.isDead then
            local enemyHpBar = luis.createElement("battle", "ProgressBar", enemy.hp / enemy.maxHp, 8, 1, yPos+1, 18)
            battleElements[#battleElements+1] = enemyHpBar
            local enemyHpLabel = luis.createElement("battle", "Label", "HP: " .. enemy.hp .. "/" .. enemy.maxHp, 8, 1, yPos+1, 19)
			enemyHpLabel.zIndex = 100
            battleElements[#battleElements+1] = enemyHpLabel
            
            -- Add target button for each live enemy
            if battleState.targetingMode then
                local targetButton = luis.createElement("battle", "Button", "Target", 3, 1, function() selectTarget(enemy) end, function() end, yPos, 21)
                battleElements[#battleElements+1] = targetButton
            end
        end
    end

    -- Action buttons
    if not battleState.targetingMode then
        battleElements[#battleElements+1] = luis.createElement("battle", "Button", "Attack", 5, 2, function() initiateTargeting("attack") end, function() end, 16, 5)
        battleElements[#battleElements+1] = luis.createElement("battle", "Button", "Defend", 5, 2, function() battleAction("defend") end, function() end, 16, 10)
        battleElements[#battleElements+1] = luis.createElement("battle", "Button", "Magic", 5, 2, function() initiateTargeting("magic") end, function() end, 16, 15)
        battleElements[#battleElements+1] = luis.createElement("battle", "Button", "Item", 5, 2, function() battleAction("item") end, function() end, 16, 20)
    else
        battleElements[#battleElements+1] = luis.createElement("battle", "Button", "Cancel", 5, 2, cancelTargeting, function() end, 16, 20)
    end

    -- Add damage text display
    battleElements[#battleElements+1] = luis.createElement("battle", "Custom", function()
        if battleState.damageTimer > 0 then
            love.graphics.setColor(1, 0, 0)
            love.graphics.setFont(love.graphics.newFont(24))
            love.graphics.printf(battleState.damageText, 0, 300, 800, "center")
        end
    end, 1, 1, 15, 15)

    -- Highlight active character
    highlightCharacter(battleState.activeCharacter)
end

function initiateTargeting(action)
    battleState.targetingMode = true
    battleState.selectedAction = action
    updateBattleElements()
end

function cancelTargeting()
    battleState.targetingMode = false
    battleState.selectedAction = nil
    updateBattleElements()
end

function selectTarget(enemy)
    battleState.targetEnemy = enemy
    battleAction(battleState.selectedAction)
    battleState.targetingMode = false
    battleState.selectedAction = nil
end

function highlightCharacter(character)
    battleState.highlightTimer = 0.5
    -- Update the character's display to show highlighting
	if character then
		for i, element in ipairs(battleElements) do
			if element.text == character.name then
				element.color = {1, 1, 0}  -- Yellow highlight
				break
			end
		end
	else
		print('highlightCharacter character=', character)
	end
end

function getNextLiveEnemy()
    for _, enemy in ipairs(gameState.enemies) do
        if not enemy.isDead then
            return enemy
        end
    end
    return nil
end

function getNextLiveCharacter()
    for _, character in ipairs(gameState.party) do
        if character.hp > 0 then
            return character
        end
    end
    return nil
end

function battleAction(action)
    local activeCharacter = battleState.activeCharacter
    local target = battleState.targetEnemy
    
    highlightCharacter(activeCharacter)
    
    local damage = 0
    if action == "attack" then
        damage = math.max(1, activeCharacter.atk - target.def)
        target.hp = math.max(0, target.hp - damage)
        battleState.damageText = activeCharacter.name .. " deals " .. damage .. " damage to " .. target.name .. "!"
    elseif action == "defend" then
        activeCharacter.def = activeCharacter.def * 1.5  -- Temporary defense boost
        battleState.damageText = activeCharacter.name .. " is defending!"
    elseif action == "magic" then
        if activeCharacter.mp >= 10 then
            damage = math.max(1, activeCharacter.mag * 2 - target.def)
            target.hp = math.max(0, target.hp - damage)
            activeCharacter.mp = activeCharacter.mp - 10
            battleState.damageText = activeCharacter.name .. " casts a spell for " .. damage .. " damage to " .. target.name .. "!"
        else
            battleState.damageText = activeCharacter.name .. " doesn't have enough MP!"
        end
    elseif action == "item" then
        if gameState.inventory.potions > 0 then
            activeCharacter.hp = math.min(activeCharacter.maxHp, activeCharacter.hp + 20)
            gameState.inventory.potions = gameState.inventory.potions - 1
            battleState.damageText = activeCharacter.name .. " uses a potion and recovers 20 HP!"
        else
            battleState.damageText = "No potions left!"
        end
    end

    battleState.damageTimer = 2  -- Display damage text for 2 seconds

    -- Check if target enemy is defeated
    if target.hp <= 0 then
        target.isDead = true
        battleState.damageText = battleState.damageText .. " " .. target.name .. " is defeated!"
        battleState.targetEnemy = getNextLiveEnemy()
    end

    -- Move to next character's turn
    battleState.currentTurn = battleState.currentTurn % #gameState.party + 1
    battleState.activeCharacter = getNextLiveCharacter()

    -- Enemy turn (after all player characters have acted)
    if battleState.currentTurn == 1 then
        for _, enemy in ipairs(gameState.enemies) do
            if not enemy.isDead then
                local targetCharacter = gameState.party[love.math.random(#gameState.party)]
                while targetCharacter.hp <= 0 do
                    targetCharacter = gameState.party[love.math.random(#gameState.party)]
                end
                highlightCharacter(enemy)
                highlightCharacter(targetCharacter)
                local enemyDamage = math.max(1, enemy.atk - targetCharacter.def)
                targetCharacter.hp = math.max(0, targetCharacter.hp - enemyDamage)
                battleState.damageText = enemy.name .. " attacks " .. targetCharacter.name .. " for " .. enemyDamage .. " damage!"
                battleState.damageTimer = 2
            end
        end
    end

    -- Check battle end conditions
    local allEnemiesDead = true
    for _, enemy in ipairs(gameState.enemies) do
        if not enemy.isDead then
            allEnemiesDead = false
            break
        end
    end

    local allPartySuspended = true
    for _, character in ipairs(gameState.party) do
        if character.hp > 0 then
            allPartySuspended = false
            break
        end
    end

    if allEnemiesDead then
        battleState.damageText = "All enemies defeated! Battle won!"
        battleState.damageTimer = 2
        love.timer.sleep(2)  -- Pause for 2 seconds to show the victory message
        endBattle()
    elseif allPartySuspended then
        gameOver()
    else
        updateBattleElements()
    end
end

-- Camp system
function restAtCamp()
    for _, character in ipairs(gameState.party) do
        character.hp = character.maxHp
        character.mp = character.maxMp
    end
    gameState.currentView = "game"
end

-- Enhanced movement functions
function moveForward()
    local dx, dy = 0, 0
    if gameState.player.direction == 0 then dy = -1
    elseif gameState.player.direction == 1 then dx = 1
    elseif gameState.player.direction == 2 then dy = 1
    else dx = -1 end
    
    local newX, newY = gameState.player.x + dx, gameState.player.y + dy
    if newX >= 1 and newX <= 20 and newY >= 1 and newY <= 20 and gameState.dungeonMap[newY][newX] == 0 then
        gameState.player.x, gameState.player.y = newX, newY
        if love.math.random() < 0.2 then  -- 20% chance of encounter
            initiateBattle()
        end
    end
end

function turnLeft()
    gameState.player.direction = (gameState.player.direction - 1) % 4
end

function turnRight()
    gameState.player.direction = (gameState.player.direction + 1) % 4
end

-- Update existing GUI elements
dungeonView = luis.createElement("game", "Custom", function()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 0, 0, 200, 200)
    -- Add simple 3D-like dungeon rendering here
end, 10, 10, 4, 20)

minimap = luis.createElement("game", "Custom", function()
    love.graphics.setColor(1, 1, 1)
    local cellSize = gameState.cellSize
    for y = 1, 20 do
        for x = 1, 20 do
            if gameState.dungeonMap[y][x] == 1 then
                love.graphics.rectangle("fill", (x-1)*cellSize, (y-1)*cellSize, cellSize, cellSize)
            end
        end
    end
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", (gameState.player.x - 0.5) * cellSize, (gameState.player.y - 0.5) * cellSize, cellSize/2)
end, 10, 10, 4, 9)

-- Update party stats display
for i, character in ipairs(gameState.party) do
    local yPos = (i-1) * 4 + 1
    luis.createElement("game", "Label", character.name, 8, 1, yPos, 1)
    local hpBar = luis.createElement("game", "ProgressBar", character.hp / character.maxHp, 8, 1, yPos+1, 1)
    local hpLabel = luis.createElement("game", "Label", "HP: " .. character.hp .. "/" .. character.maxHp, 8, 1, yPos+1, 2)
	hpLabel.zIndex = 100
    local mpBar = luis.createElement("game", "ProgressBar", character.mp / character.maxMp, 8, 1, yPos+2, 1)
    local mpLabel = luis.createElement("game", "Label", "MP: " .. character.mp .. "/" .. character.maxMp, 8, 1, yPos+2, 2)
	mpLabel.zIndex = 100
end

-- Update action buttons
luis.createElement("game", "Button", "←", 5, 2, turnLeft, function() end, 16, 5)
luis.createElement("game", "Button", "↑", 5, 2, moveForward, function() end, 16, 10)
luis.createElement("game", "Button", "→", 5, 2, turnRight, function() end, 16, 15)
luis.createElement("game", "Button", "Camp", 5, 2, function() gameState.currentView = "camp" end, function() end, 16, 20)

-- Update camp elements
campElements = {
    luis.createElement("camp", "Button", "Rest", 5, 2, restAtCamp, function() end, 10, 5),
    luis.createElement("camp", "Button", "Return to Dungeon", 5, 2, function() gameState.currentView = "game" end, function() end, 10, 15)
}

function love.load()
	luis.initJoysticks()  -- Initialize joysticks
	if luis.activeJoystick then
		local name = luis.activeJoystick:getName()
		local index = luis.activeJoystick:getConnectedIndex()
		print(string.format("Changing active joystick to #%d '%s'.", index, name))
		luis.setJoystickPos(luis.baseWidth/2,luis.baseHeight/2)
	end
	
	local customTheme = require("examples.complex_ui.assets.themes.alternativeTheme")
	luis.setTheme(customTheme)
end

-- Main update function
local accumulator = 0
function love.update(dt)
    accumulator = accumulator + dt
    if accumulator >= 1/60 then
        luis.flux.update(accumulator)
        accumulator = 0
    end

    luis.update(dt)

    if gameState.currentView == "battle" then
        luis.setCurrentLayer("battle")
        luis.disableLayer("camp")
        luis.disableLayer("game")

        -- Update damage text timer
        if battleState.damageTimer > 0 then
            battleState.damageTimer = battleState.damageTimer - dt
        end

        -- Update highlight timer
        if battleState.highlightTimer > 0 then
            battleState.highlightTimer = battleState.highlightTimer - dt
        else
            -- Reset character highlights
            for i, element in ipairs(battleElements) do
                element.color = {1, 1, 1}  -- Reset to white
            end
        end
    elseif gameState.currentView == "camp" then
        luis.setCurrentLayer("camp")
        luis.disableLayer("battle")
        luis.disableLayer("game")
    else -- "game"
        luis.setCurrentLayer("game")
        luis.disableLayer("battle")
        luis.disableLayer("camp")
    end
end


-- Draw function (unchanged)
function love.draw()
    luis.draw()
end

-- Input handling (unchanged)
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
    if gameState.currentView == "game" then
        if key == 'up' then
            moveForward()
        elseif key == 'left' then
            turnLeft()
        elseif key == 'right' then
            turnRight()
        end
    end

	if key == "tab" then -- Debug View
        luis.keypressed(key)
    end
    luis.keypressed(key)
end

function love.joystickadded(joystick)
    luis.initJoysticks()  -- Reinitialize joysticks when a new one is added
end

function love.joystickremoved(joystick)
    luis.initJoysticks()  -- Reinitialize joysticks when one is removed
end

function love.gamepadpressed(joystick, button)
    luis.gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
    luis.gamepadreleased(joystick, button)
end
