local luis = require("luis")
local defaultTheme = require("assets.themes.defaultTheme")
local customTheme = require("assets.themes.customTheme")
local materialTheme = require("assets.themes.materialTheme")
local alternativeTheme = require("assets.themes.alternativeTheme")

local resolutions = love.window.getFullscreenModes()
table.sort(resolutions, function(a, b) return a.width*a.height < b.width*b.height end)   -- sort from smallest to largest

local function addNameAttribute(modes)
    for i, mode in ipairs(modes) do
        mode.name = tostring(mode.width) .. "x" .. tostring(mode.height)
    end
end
addNameAttribute(resolutions)

local function keepTop15Resolutions(modes)
    -- Sort the array by resolution (width * height)
    table.sort(modes, function(a, b)
        return (a.width * a.height) > (b.width * b.height)
    end)
    
    -- Only keep the top 15 resolutions
    while #modes > 15 do
        table.remove(modes)
    end
end

keepTop15Resolutions(resolutions)

-- Game settings
local gameSettings = {
    fullscreen = false,
    musicVolume = 50,
    sfxVolume = 50,
    difficulty = "Normal",
    controlScheme = "Default",
    showFPS = false,
    vsync = true,
    fsaa = 1,  -- 1 corresponds to "Off" in the dropdown
    resizable = true,
    pixelPerfect = false,
    highDpi = false
}

local currentTheme = "Custom"
local function toggleTheme()
    if currentTheme == "Default" then
        luis.setTheme(defaultTheme)  -- Reset to default theme
		currentTheme = "Custom"
    elseif currentTheme == "Custom" then
        luis.setTheme(customTheme)
		currentTheme = "Alternative"
    elseif currentTheme == "Alternative" then
        luis.setTheme(materialTheme)
		currentTheme = "Material"
    elseif currentTheme == "Material" then
        luis.setTheme(alternativeTheme)
		currentTheme = "Default"
    end
end

local function getCurrentResolutionIndex()
    local currentWidth, currentHeight = love.window.getMode()
    for i, res in ipairs(resolutions) do
        if res.width == currentWidth and res.height == currentHeight then
            return i
        end
    end
    return 1  -- Default to the first resolution if current is not in the list
end

-- The CustomView can be used to render gameplay
local time = 0
local customView = luis.createElement("custom", "Custom", function()
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("line", 0, 0, 200, 200)
    for y = 1, 200 - 1 do
        for x = 1, 200 - 1 do
            local value = math.sin(x / 16.0)
                        + math.sin(y / 8.0)
                        + math.sin((x + y) / 16.0)
                        + math.sin(math.sqrt(x * x + y * y) / 8.0)
            
            value = math.abs(math.sin(value * math.pi + time))
            
            local r = math.sin(value * 2 * math.pi + 0) * 0.5 + 0.5
            local g = math.sin(value * 2 * math.pi + 2 * math.pi / 3) * 0.5 + 0.5
            local b = math.sin(value * 2 * math.pi + 4 * math.pi / 3) * 0.5 + 0.5
            
            love.graphics.setColor(r, g, b)
            love.graphics.points(x, y)
        end
    end
end, 10, 10, 10, 43)

local function createMainMenu()
    luis.createElement("main", "Label", "Main Menu", 96, 4, 4, 44)
    local menuItems = {"Start Game", "Settings", "Highscore", "Quit"}
    for i, item in ipairs(menuItems) do
        luis.createElement("main", "Button", item, 15, 3, function() handleMainMenuSelection(item) end, function() end, 25 + i * 5, 41)
    end
end

local function createSettingsMenu()
    luis.createElement("settings", "Label", "Settings", 96, 4, 4, 45)
    local settingsItems = {"Video", "Audio", "Gameplay", "Controls", "Back"}
    for i, item in ipairs(settingsItems) do
        luis.createElement("settings", "Button", item, 15, 3, function() handleSettingsMenuSelection(item) end, function() end, 20 + i * 5, 41)
    end
end

local function createVideoMenu()
    luis.createElement("video", "Label", "Video Settings", 96, 4, 4, 43)

    -- Fullscreen
    luis.createElement("video", "Label", "Fullscreen", 10, 3, 10, 40)
    luis.createElement("video", "Switch", gameSettings.fullscreen, 5, 3, function(value) 
        gameSettings.fullscreen = value
        love.window.setFullscreen(value)
    end, 10, 50)
    
    -- Show FPS
    luis.createElement("video", "Label", "Show FPS", 10, 3, 15, 40)
    luis.createElement("video", "CheckBox", gameSettings.showFPS, 3, function(value)
        gameSettings.showFPS = value
    end, 15, 50)
    
    -- VSync
    luis.createElement("video", "Label", "VSync", 10, 3, 20, 40)
    luis.createElement("video", "Switch", gameSettings.vsync, 5, 3, function(value)
        gameSettings.vsync = value
        love.window.setVSync(value and 1 or 0)
    end, 20, 50)
    
    -- Resizable
    luis.createElement("video", "Label", "Resizable", 10, 3, 30, 40)
    luis.createElement("video", "CheckBox", gameSettings.resizable, 3, function(value)
        gameSettings.resizable = value
        love.window.updateMode(love.graphics.getWidth(), love.graphics.getHeight(), {resizable = value})
    end, 30, 50)

    -- High DPI
    luis.createElement("video", "Label", "High DPI", 10, 3, 40, 40)
    luis.createElement("video", "CheckBox", gameSettings.highDpi, 3, function(value)
        gameSettings.highDpi = value
        love.window.updateMode(love.graphics.getWidth(), love.graphics.getHeight(), {highdpi = value})
    end, 40, 50)

    luis.createElement("video", "Button", "Back", 15, 3, popMenu, function() end, 45, 41)

	-- add Dropdown at last

	-- FSAA (Full-Screen Anti-Aliasing)
	luis.createElement("video", "Label", "FSAA", 10, 3, 35, 40)
	luis.createElement("video", "DropDown", {"Off", "2x", "4x", "8x"}, gameSettings.fsaa, 10, 3, function(item, index)
		gameSettings.fsaa = index
		local fsaaValue = {0, 2, 4, 8}
		love.window.updateMode(love.graphics.getWidth(), love.graphics.getHeight(), {msaa = fsaaValue[index]})
	end, 35, 50)

	-- Resolution
	luis.createElement("video", "Label", "Resolution", 10, 3, 25, 40)
	local resolutionNames = {}
	for _, res in ipairs(resolutions) do
		table.insert(resolutionNames, res.name)
	end
	luis.createElement("video", "DropDown", resolutionNames, getCurrentResolutionIndex(), 15, 3, function(item, index)
		local newRes = resolutions[index]
		love.window.updateMode(newRes.width, newRes.height, {
			fullscreen = gameSettings.fullscreen,
			vsync = gameSettings.vsync and 1 or 0,
			msaa = gameSettings.fsaa == 1 and 0 or (2 ^ (gameSettings.fsaa - 1)),
			resizable = gameSettings.resizable,
			highdpi = gameSettings.highDpi
		})
		luis.updateScale()
	end, 25, 50, 6)
end

local function createAudioMenu()
    luis.createElement("audio", "Label", "Audio Settings", 96, 4, 4, 43)
    
    luis.createElement("audio", "Label", "Music Volume", 10, 3, 20, 30)
    luis.createElement("audio", "Slider", 0, 100, gameSettings.musicVolume, 20, 3, function(value) 
        gameSettings.musicVolume = value
        -- Update actual music volume here
    end, 20, 45)
    
    luis.createElement("audio", "Label", "SFX Volume", 10, 3, 30, 30)
    luis.createElement("audio", "Slider", 0, 100, gameSettings.sfxVolume, 20, 3, function(value) 
        gameSettings.sfxVolume = value
        -- Update actual SFX volume here
    end, 30, 45)
    
    luis.createElement("audio", "Button", "Back", 15, 3, popMenu, function() end, 45, 41)
end

local function createGameplayMenu()
    luis.createElement("gameplay", "Label", "Gameplay Settings", 96, 4, 4, 41)
    
    luis.createElement("gameplay", "Label", "Difficulty", 10, 3, 20, 28)
    local difficulties = {"Easy", "Normal", "Hard"}
    for i, diff in ipairs(difficulties) do
        luis.createElement("gameplay", "RadioButton", "difficulty", gameSettings.difficulty == diff, 3, function(value)
            if value then
                gameSettings.difficulty = diff
                -- Update actual difficulty here
            end
        end, 20, 27 + i * 10)
        luis.createElement("gameplay", "Label", diff, 10, 3, 20, 31 + i * 10)
    end

    luis.createElement("gameplay", "Button", "Back", 15, 3, popMenu, function() end, 45, 41)
end

local textInput_widget
local function createControlsMenu()
    luis.createElement("controls", "Label", "Control Settings", 96, 4, 4, 42)

    luis.createElement("controls", "Label", "Control Scheme", 14, 3, 20, 23)
    local schemes = {"Default", "Alternative", "Custom"}
    for i, scheme in ipairs(schemes) do
        luis.createElement("controls", "RadioButton", "controlScheme", gameSettings.controlScheme == scheme, 3, function(value)
            if value then
                gameSettings.controlScheme = scheme
                -- Update actual control scheme here
            end
        end, 20, 24 + i * 12)
        luis.createElement("controls", "Label", scheme, 8, 3, 20, 28 + i * 12)
    end

	local progressBar = {
        backgroundColor = {0.1, 0.5, 0.8, 1},
        fillColor = {0.15, 0.15, 0.15, 1},
        borderColor = {1, 1, 1, 1},
    }
	luis.createElement("controls", "ProgressBar", 0.5, 10, 1, 25, 43, progressBar)
	icon_widget = luis.createElement("controls", "Icon", "assets/images/icon.png", 3, 30, 43)

	----------------------------------------------------------------
	-- Create a FlexContainer
	local container = luis.newFlexContainer(21, 11, 37, 38)
	
	-- if you don't want to resize the container manually, disable this
	--container.release = function() end
	--container.click = function() end
	
	local customButtonTheme = {
		color = {0.5, 0.1, 0.9, 1},
		hoverColor = {0.15, 0.45, 0.85, 1},
		pressedColor = {0.35, 0.35, 0.35, 1},
		textColor = {0.1, 0.1, 0.1, 1},
		align = "center",	-- left, right, center
		cornerRadius = 15,
		elevation = 0,
		elevationHover = 0,
		elevationPressed = 10,
		transitionDuration = 1.5,
	}
	local button_widget  = luis.newButton( "Toggle Theme", 15, 3, toggleTheme, function() end, 40, 41, customButtonTheme)
	local dropdown = luis.newDropDown(  {"Option 1", "Option 2", "Option 3"}, 3, 10, 2, function(item, index) print("Selected: " .. item) end, 35, 43)
	textInput_widget = luis.newTextInput( 20, 3, "Enter text here...", function(text) print(text) textInput_widget:setText("") end, 45, 38)
	container:addChild(button_widget)
	container:addChild(textInput_widget)
	container:addChild(dropdown)
	
	-- Resize the container (this will rearrange the children)
	--container:resize(30 * luis.gridSize, 20 * luis.gridSize)
	
	-- Add the container to your controls layer
	luis.createElement("controls", "FlexContainer", container)
	----------------------------------------------------------------

	luis.createElement("controls", "Button", "Back", 15, 3, popMenu, function() end, 50, 41)
end

function love.load()
    love.window.setMode(luis.baseWidth, luis.baseHeight, {
        fullscreen = gameSettings.fullscreen,
        vsync = gameSettings.vsync and 1 or 0,
        msaa = gameSettings.fsaa == 1 and 0 or (2 ^ (gameSettings.fsaa - 1)),
        resizable = gameSettings.resizable,
        highdpi = gameSettings.highDpi
    })

    love.keyboard.setKeyRepeat(true)

    -- Create layers for different menus
    luis.newLayer("main", 96, 54)
    luis.newLayer("settings", 96, 54)
    luis.newLayer("video", 96, 54)
    luis.newLayer("audio", 96, 54)
    luis.newLayer("gameplay", 96, 54)
    luis.newLayer("controls", 96, 54)
	
	luis.newLayer("custom", 10, 10)

	-- Create UI elements for all menus
    createMainMenu()
    createSettingsMenu()
    createVideoMenu()
    createAudioMenu()
    createGameplayMenu()
    createControlsMenu()

--	luis.loadConfig('config.json')

	luis.enableLayer("custom")
    pushMenu("main")
end

function love.update(dt)
    luis.updateScale()
    luis.update(dt)
	time = time + dt
	
	icon_widget.position = luis.Vector2D.new(math.sin(time*10)+900, math.sin(time*10)+600)
end

function love.draw()
	local startTime = love.timer.getTime()
    luis.draw()
	local endTime = love.timer.getTime()
	local time = (endTime - startTime) * 1000

	local stats = love.graphics.getStats()

	if time >= 7 then
		love.graphics.setColor(1, 0, 0)
	else
		love.graphics.setColor(1, 1, 1)
	end

	if gameSettings.showFPS then
		love.graphics.print(string.format('FPS: %d (%.3f ms) (%d draw calls, %d batched)', love.timer.getFPS(), time, stats.drawcalls, stats.drawcallsbatched), 0, love.graphics.getHeight() - 32)
	end
end

function love.resize(w, h)
    luis.updateScale()
end

function pushMenu(menuName)
	luis.toggleLayer(luis.currentLayer)
    luis.setCurrentLayer(menuName)
end

function popMenu()
	luis.toggleLayer(luis.currentLayer)
    luis.popLayer()
end

function handleMainMenuSelection(selected)
    if selected == "Start Game" then
        print("Starting game...")
    elseif selected == "Settings" then
		luis.disableLayer("custom")
        pushMenu("settings")
    elseif selected == "Highscore" then
        print("Showing highscores...")
    elseif selected == "Quit" then
        love.event.quit()
    end
end

function handleSettingsMenuSelection(selected)
    if selected == "Video" then
        pushMenu("video")
    elseif selected == "Audio" then
        pushMenu("audio")
    elseif selected == "Gameplay" then
        pushMenu("gameplay")
    elseif selected == "Controls" then
        pushMenu("controls")
    elseif selected == "Back" then
--		luis.saveConfig('config.json')
		luis.enableLayer("custom")
        popMenu()
    end
end

function love.textinput(text)
    luis.textinput(text)
end

function love.mousepressed(x, y, button, istouch)
    luis.mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    luis.mousereleased(x, y, button, istouch)
end

function love.wheelmoved(x, y)
    luis.wheelmoved(x, y)
end

function love.keypressed(key)
    if key == "escape" then
        if luis.currentLayer == "main" then
            love.event.quit()
        else
            popMenu()
        end
    elseif key == "t" then
        toggleTheme()
    elseif key == "l" then
        luis.toggleLayer('custom')
    else
        luis.keypressed(key)
	end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    love.mousepressed(x, y, 1, true)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    love.mousereleased(x, y, 1, true)
end
