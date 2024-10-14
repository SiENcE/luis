local initLuis = require("luis.init")
-- Direct this to your widgets folder.
local luis = initLuis("examples/complex_ui/widgets")

-- register flux in luis, because the widgets of complex_ui need this
luis.flux = require("examples.3rdparty.flux")

function love.load()
    love.window.setMode(800, 600)
    luis.setGridSize(20)

    -- Create layers for different menu depths
	luis.newLayer("game")
    luis.newLayer("battleMain")
    luis.newLayer("actionMenu")
    luis.newLayer("magicMenu")
    luis.newLayer("itemMenu")

	-- Set up the game screen
	setupGame()

	-- Set up the main battle menu
    setupBattleMainMenu()

    -- Set up sub-menus (initially disabled)
    setupActionMenu()
    setupMagicMenu()
    setupItemMenu()

    -- Start with the main battle menu
	luis.enableLayer("game")
    luis.enableLayer("battleMain")
    luis.disableLayer("actionMenu")
    luis.disableLayer("magicMenu")
    luis.disableLayer("itemMenu")

	luis.theme.system.font = love.graphics.newFont(12)
	luis.theme.background.color = {0.7,0.7,0.7}
	luis.theme.button.cornerRadius = 0
    luis.theme.button.elevation = 0
    luis.theme.button.elevationHover = 0
    luis.theme.button.elevationPressed = 0
	luis.theme.button.transitionDuration = 0
end

function setupGame()
    -- Set up the game and create a label for battle messages
    luis.createElement("game", "Label", "A wild Enemy appears!", 20, 2, 21, 1)

    -- Create a FlexContainer for character portraits and stats
    local portraitContainer = luis.createElement("game", "FlexContainer", 10, 16, 1, 30)
    for i = 1, 4 do
        local custom = luis.createElement("game", "Custom", function()
            love.graphics.setColor(0, 0.8, 0)
            love.graphics.rectangle("fill", 0, 0, 40, 80)
        end, 2, 4, 1, 1)
        portraitContainer:addChild(custom)
		
        local label = luis.createElement("game", "Label", "Hero " .. i .. "\nHP: 100/100\nMP: 50/50", 8, 4, 1, 1, "left")
        portraitContainer:addChild(label)
    end
end

function setupBattleMainMenu()
    -- Create a FlexContainer for battle commands
    local commandContainer = luis.createElement("battleMain", "FlexContainer", 8, 8, 23, 1)
    local commands = {"Fight", "Magic", "Item", "Defend"}
    for i, command in ipairs(commands) do
        local btn = luis.createElement("battleMain", "Button", command, 8, 2, function()
            if command == "Fight" then
                -- Implement fight logic
            elseif command == "Magic" then
                showMagicMenu()
            elseif command == "Item" then
                showItemMenu()
            elseif command == "Defend" then
                -- Implement defend logic
            end
        end, nil, 1, 1)
		commandContainer:addChild(btn)
    end
end

function setupActionMenu()
    -- Create a FlexContainer for action menu
    local actionContainer = luis.createElement("actionMenu", "FlexContainer", 8, 8, 23, 1)
    local actions = {"Attack", "Special", "Back"}
    for _, action in ipairs(actions) do
        local btn = luis.createElement("actionMenu", "Button", action, 8, 2, function()
            if action == "Back" then
                luis.enableLayer("battleMain")
                luis.disableLayer("actionMenu")
            else
                -- Implement action logic
            end
        end, nil, 1, 1)
		actionContainer:addChild(btn)
    end
end

function setupMagicMenu()
    -- Create a FlexContainer for magic menu
    local magicContainer = luis.createElement("magicMenu", "FlexContainer", 8, 8, 23, 1)
    local spells = {"Fire", "Ice", "Heal", "Back"}
    for _, spell in ipairs(spells) do
        local btn = luis.createElement("magicMenu", "Button", spell, 8, 2, function()
            if spell == "Back" then
                luis.enableLayer("battleMain")
                luis.disableLayer("magicMenu")
            else
                -- Implement spell casting logic
            end
        end, nil, 1, 1)
		magicContainer:addChild(btn)
    end
end

function setupItemMenu()
    -- Create a FlexContainer for item menu
    local itemContainer = luis.createElement("itemMenu", "FlexContainer", 8, 8, 23, 1)
    local items = {"Potion", "Ether", "Phoenix Down", "Back"}
    for _, item in ipairs(items) do
        local btn = luis.createElement("itemMenu", "Button", item, 8, 2, function()
            if item == "Back" then
                luis.enableLayer("battleMain")
                luis.disableLayer("itemMenu")
            else
                -- Implement item usage logic
            end
        end, nil, 1, 1)
		itemContainer:addChild(btn)
    end
end

function showMagicMenu()
    luis.disableLayer("battleMain")
    luis.enableLayer("magicMenu")
end

function showItemMenu()
    luis.disableLayer("battleMain")
    luis.enableLayer("itemMenu")
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
    luis.draw()
end

function love.mousepressed(x, y, button, istouch, presses)
    luis.mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    luis.mousereleased(x, y, button, istouch, presses)
end

function love.wheelmoved(x, y)
    luis.wheelmoved(x, y)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "tab" then
        luis.showGrid = not luis.showGrid
        luis.showElementOutlines = not luis.showElementOutlines
        luis.showLayerNames = not luis.showLayerNames
	else
		luis.keypressed(key, scancode, isrepeat)
	end
end

function love.keyreleased(key, scancode)
    luis.keyreleased(key, scancode)
end

function love.textinput(text)
    luis.textinput(text)
end
