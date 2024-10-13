local initLuis = require("luis.init")
-- Direct this to your widgets folder.
local luis = initLuis("examples/gridLayoutTest/widgets")

-- Initialize LUIS
love.window.setMode(1240, 1024)
luis.setGridSize(50)  -- Set grid size to 50 pixels

-- Create a new layer for our grid layout
luis.newLayer("gridLayout")
luis.setCurrentLayer("gridLayout")

-- Create a grid container
local grid = luis.newFlexContainer(50, 50, 600, 500, 5, 6)  -- 5 rows, 6 columns

-- Add labels to the grid
local labels = {
    luis.newLabel("1x1", 1, 1, 1, 1, "center"),
    luis.newLabel("2x1", 2, 1, 1, 2, "center"),
    luis.newLabel("1x2", 1, 2, 2, 1, "center"),
    luis.newLabel("2x2", 2, 2, 2, 2, "center"),
    luis.newLabel("3x1", 3, 1, 1, 3, "center"),
    luis.newLabel("1x3", 1, 1, 3, 5, "center"),
    luis.newLabel("Span All", 6, 1, 5, 1, "center", nil, 1, 6),
}

-- Add labels to the grid
grid:addChild(labels[1], 1, 1)
grid:addChild(labels[2], 1, 2, 1, 2)
grid:addChild(labels[3], 2, 1, 2, 1)
grid:addChild(labels[4], 2, 2, 2, 2)
grid:addChild(labels[5], 1, 4, 1, 3)
grid:addChild(labels[6], 1, 6, 3, 1)
grid:addChild(labels[7], 5, 1, 1, 6)

-- Add the grid to LUIS
luis.createElement("gridLayout", "FlexContainer", grid)

-- Variables for dynamic updates
local dynamicLabel = luis.newLabel("Dynamic", 2, 1, 4, 3, "center")
grid:addChild(dynamicLabel, 4, 3, 1, 2)
local dynamicRow, dynamicCol = 4, 3
local dynamicSpanRow, dynamicSpanCol = 1, 2

-- Love2D callbacks
function love.update(dt)
    luis.update(dt)
    
    -- Example of dynamic grid updates
    if love.keyboard.isDown("up") and dynamicRow > 1 then
        dynamicRow = dynamicRow - 1
        dynamicLabel:updateGridPosition(dynamicRow, dynamicCol)
    elseif love.keyboard.isDown("down") and dynamicRow < 5 then
        dynamicRow = dynamicRow + 1
        dynamicLabel:updateGridPosition(dynamicRow, dynamicCol)
    elseif love.keyboard.isDown("left") and dynamicCol > 1 then
        dynamicCol = dynamicCol - 1
        dynamicLabel:updateGridPosition(dynamicRow, dynamicCol)
    elseif love.keyboard.isDown("right") and dynamicCol < 6 then
        dynamicCol = dynamicCol + 1
        dynamicLabel:updateGridPosition(dynamicRow, dynamicCol)
    end

    -- Update span with 'w' and 's' keys
    if love.keyboard.isDown("w") and dynamicSpanRow < 3 then
        dynamicSpanRow = dynamicSpanRow + 1
        dynamicLabel:updateGridSize(2, 1, dynamicSpanRow, dynamicSpanCol)
    elseif love.keyboard.isDown("s") and dynamicSpanRow > 1 then
        dynamicSpanRow = dynamicSpanRow - 1
        dynamicLabel:updateGridSize(2, 1, dynamicSpanRow, dynamicSpanCol)
    elseif love.keyboard.isDown("a") and dynamicSpanCol > 1 then
        dynamicSpanCol = dynamicSpanCol - 1
        dynamicLabel:updateGridSize(2, 1, dynamicSpanRow, dynamicSpanCol)
    elseif love.keyboard.isDown("d") and dynamicSpanCol < 4 then
        dynamicSpanCol = dynamicSpanCol + 1
        dynamicLabel:updateGridSize(2, 1, dynamicSpanRow, dynamicSpanCol)
    end
end

function love.draw()
    luis.draw()
    
    -- Draw instructions
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Use arrow keys to move the dynamic label", 10, 560)
    love.graphics.print("Use W/S to change row span, A/D to change column span", 10, 580)
end

function love.keypressed(key)
    luis.keypressed(key)
end

function love.textinput(t)
    luis.textinput(t)
end

function love.mousepressed(x, y, button)
    luis.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    luis.mousereleased(x, y, button)
end
