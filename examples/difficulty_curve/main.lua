local initLuis = require("luis.init")
-- Direct this to your widgets folder.
local luis = initLuis("examples/complex_ui/widgets")

-- register flux in luis, because the widgets of complex_ui need this
luis.flux = require("examples.3rdparty.flux")

local Game = {
    spawnsPerTurn = 3,
    spawnGrowthRate = 0.24,
    turnsPerTier = 100,
    tierDifficultyProgression = 2,
    tierDifficulty = {1.0, 1.1, 1.2, 1.3, 1.4, 1.5},
    maxTiers = 6,
    graphData = {},
    maxTurns = 600,
    graphWidth = 800,
    graphHeight = 400,
    padding = 40
}

function Game:calculateTierDistribution(baseCount, turn)
    local distribution = {}
    
    -- Calculate available tiers based on turns (1 new tier per TURNS_PER_TIER turns)
    local availableTiers = math.min(
        math.floor(turn / self.turnsPerTier) + 1,
        self.maxTiers
    )
    
    -- Calculate weight for each tier based on progression value
    local totalWeight = 0
    local weights = {}
    for tier = 1, availableTiers do
        -- Higher tiers have higher weights as the game progresses
        weights[tier] = (availableTiers - tier + 1) ^ self.tierDifficultyProgression
        totalWeight = totalWeight + weights[tier]
    end
    
    -- Distribute enemies across tiers based on weights
    local remainingCount = baseCount
    for tier = 1, availableTiers do
        local tierWeight = weights[tier] / totalWeight
        local tierCount = math.floor(remainingCount * tierWeight * self.tierDifficulty[tier])
        
        -- Ensure at least one enemy of each available tier
        distribution[tier] = math.max(1, tierCount)
        remainingCount = remainingCount - distribution[tier]
    end
    
    -- Add any remaining enemies to the highest tier
    if remainingCount > 0 then
        distribution[availableTiers] = (distribution[availableTiers] or 0) + remainingCount
    end
    
    return distribution
end

function Game:calculateDifficulty()
    self.graphData = {}
    
    for turn = 0, self.maxTurns do
        if turn % self.spawnsPerTurn == 0 then
            local baseCount = math.floor(1 + (turn / self.spawnsPerTurn) * self.spawnGrowthRate)
            local tierDistribution = self:calculateTierDistribution(baseCount, turn)
            
            -- Calculate total enemies considering tier difficulties
            local totalEnemies = 0
            for tier, count in pairs(tierDistribution) do
                totalEnemies = totalEnemies + count
            end
            
            table.insert(self.graphData, {
                turn = turn,
                enemies = totalEnemies,
                tiers = tierDistribution,
                baseCount = baseCount
            })
        end
    end
end

function Game:init()
    -- Calculate initial data
    self:calculateDifficulty()
    
    -- Create UI layer
    luis.newLayer("gameAnalysis")
    luis.setCurrentLayer("gameAnalysis")
    
    -- Create labels for current values
    self.spawnsLabel = luis.createElement("gameAnalysis", "Label",
        "Spawns Per Turn: " .. self.spawnsPerTurn,
        10, 2,  -- width, height
        1, 2      -- row, col
    )
    
    self.growthLabel = luis.createElement("gameAnalysis", "Label",
        "Spawn Growth Rate: " .. string.format("%.2f", self.spawnGrowthRate),
        10, 2,
        3, 2
    )
    
    self.tiersLabel = luis.createElement("gameAnalysis", "Label",
        "Turns Per Tier: " .. self.turnsPerTier,
        10, 2,
        5, 2
    )
    
    self.progressionLabel = luis.createElement("gameAnalysis", "Label",
        "Tier Difficulty Progression: " .. self.tierDifficultyProgression,
        10, 2,
        7, 2
    )
    
    -- Create sliders
    self.spawnsSlider = luis.createElement("gameAnalysis", "Slider",
        1, 10, self.spawnsPerTurn,  -- min, max, value
        20, 2,                     -- width, height
        function(value)
            self.spawnsPerTurn = value
            luis.setElementState("gameAnalysis", self.spawnsLabel, 
                "Spawns Per Turn: " .. value)
            self:calculateDifficulty()
        end,
        1, 12                       -- row, col
    )
    self.spawnsSlider.setValue = function(self, newValue)
            newValue = math.floor(math.abs(math.max(self.min, math.min(self.max, newValue))))
            if newValue ~= self.value then
                self.value = newValue
                if self.onChange then
                    self.onChange(self.value)
                end
            end
        end
    
    self.growthSlider = luis.createElement("gameAnalysis", "Slider",
        0.05, 0.5, self.spawnGrowthRate,
        20, 2,
        function(value)
            self.spawnGrowthRate = value
            luis.setElementState("gameAnalysis", self.growthLabel,
                "Spawn Growth Rate: " .. string.format("%.2f", value))
            self:calculateDifficulty()
        end,
        3, 12
    )
    
    self.tiersSlider = luis.createElement("gameAnalysis", "Slider",
        10, 200, self.turnsPerTier,
        20, 2,
        function(value)
            self.turnsPerTier = value
            luis.setElementState("gameAnalysis", self.tiersLabel,
                "Turns Per Tier: " .. value)
            self:calculateDifficulty()
        end,
        5, 12
    )
    self.tiersSlider.setValue = function(self, newValue)
            newValue = math.floor(math.abs(math.max(self.min, math.min(self.max, newValue))))
            if newValue ~= self.value then
                self.value = newValue
                if self.onChange then
                    self.onChange(self.value)
                end
            end
        end
    
    self.progressionSlider = luis.createElement("gameAnalysis", "Slider",
        1, 5, self.tierDifficultyProgression,
        20, 2,
        function(value)
            self.tierDifficultyProgression = value
            luis.setElementState("gameAnalysis", self.progressionLabel,
                "Tier Difficulty Progression: " .. value)
            self:calculateDifficulty()
        end,
        7, 12
    )
    
    -- Create custom graph element
    self.graphElement = luis.createElement("gameAnalysis", "Custom",
        function()
            self:drawGraph()
        end,
        self.graphWidth, self.graphHeight,
        6, 0
    )
end

function Game:drawGraph()
    local function mapToScreen(x, y, minX, maxX, minY, maxY)
        local screenX = self.padding + (x - minX) / (maxX - minX) * (self.graphWidth - 2 * self.padding)
        local screenY = self.graphHeight - self.padding - (y - minY) / (maxY - minY) * (self.graphHeight - 2 * self.padding)
        return screenX, screenY
    end
    
    -- Find data ranges
    local maxEnemies = 0
    for _, point in ipairs(self.graphData) do
        maxEnemies = math.max(maxEnemies, point.enemies)
    end
    
    -- Draw axes
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.line(
        self.padding, self.padding,
        self.padding, self.graphHeight - self.padding
    )
    love.graphics.line(
        self.padding, self.graphHeight - self.padding,
        self.graphWidth - self.padding, self.graphHeight - self.padding
    )
    
    -- Draw graph lines
    -- Total Enemies (purple)
    love.graphics.setColor(1, 0, 0)
    for i = 2, #self.graphData do
        local x1, y1 = mapToScreen(self.graphData[i-1].turn, self.graphData[i-1].enemies,
            0, self.maxTurns, 0, maxEnemies)
        local x2, y2 = mapToScreen(self.graphData[i].turn, self.graphData[i].enemies,
            0, self.maxTurns, 0, maxEnemies)
        love.graphics.line(x1, y1, x2, y2)
    end
	love.graphics.setPointSize( 10 )
	love.graphics.points( 100, 400+8 )
	love.graphics.setColor(1, 1, 1)
	love.graphics.print('- Total Enemies',110, 400)
    
    -- Base Count (green)
    love.graphics.setColor(0, 1, 0)
    for i = 2, #self.graphData do
        local x1, y1 = mapToScreen(self.graphData[i-1].turn, self.graphData[i-1].baseCount,
            0, self.maxTurns, 0, maxEnemies)
        local x2, y2 = mapToScreen(self.graphData[i].turn, self.graphData[i].baseCount,
            0, self.maxTurns, 0, maxEnemies)
        love.graphics.line(x1, y1, x2, y2)
    end
	love.graphics.setPointSize( 10 )
	love.graphics.points( 100, 415+8 )
	love.graphics.setColor(1, 1, 1)
	love.graphics.print('- Base Count',110, 415)
    
    -- Tier Difficulty (yellow)
    love.graphics.setColor(1, 1, 0)
    for i = 2, #self.graphData do
        local totalTierDifficulty = 0
        for tier, count in pairs(self.graphData[i-1].tiers) do
            totalTierDifficulty = totalTierDifficulty + count * self.tierDifficulty[tier]
        end
        local x1, y1 = mapToScreen(self.graphData[i-1].turn, totalTierDifficulty,
            0, self.maxTurns, 0, maxEnemies)
        
        totalTierDifficulty = 0
        for tier, count in pairs(self.graphData[i].tiers) do
            totalTierDifficulty = totalTierDifficulty + count * self.tierDifficulty[tier]
        end
        local x2, y2 = mapToScreen(self.graphData[i].turn, totalTierDifficulty,
            0, self.maxTurns, 0, maxEnemies)
        
        love.graphics.line(x1, y1, x2, y2)
    end
	love.graphics.setPointSize( 10 )
	love.graphics.points( 100, 430+8 )
	love.graphics.setColor(1, 1, 1)
	love.graphics.print('- Tier Difficulty',110, 430)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function Game:update(dt)
    luis.update(dt)
	
	self.spawnsLabel:setText("Spawns Per Turn: " .. self.spawnsPerTurn)
	self.growthLabel:setText("Spawn Growth Rate: " .. string.format("%.2f", self.spawnGrowthRate))
	self.tiersLabel:setText("Turns Per Tier: " .. self.turnsPerTier)
	self.progressionLabel:setText("Tier Difficulty Progression: " .. self.tierDifficultyProgression)
end

function Game:draw()
    luis.draw()
end

-- LÖVE2D callbacks
function love.load()
    Game:init()
end

local accumulator = 0
function love.update(dt)
    accumulator = accumulator + dt
    if accumulator >= 1/60 then
        luis.flux.update(accumulator)
        accumulator = 0
    end

    Game:update(dt)
end

function love.draw()
    Game:draw()
end

-- Input callbacks
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
    if key == "escape" then
        if luis.currentLayer == "main" then
            love.event.quit()
        else
            popMenu()
        end
    elseif key == "tab" then
        luis.showGrid = not luis.showGrid
        luis.showElementOutlines = not luis.showElementOutlines
        luis.showLayerNames = not luis.showLayerNames
    end
    luis.keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    luis.keyreleased(key, scancode)
end

function love.textinput(text)
    luis.textinput(text)
end
