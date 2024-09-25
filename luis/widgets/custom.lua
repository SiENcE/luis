local custom = {}

local luis  -- This will store the reference to the core library
function custom.setluis(luisObj)
    luis = luisObj
end

-- Custom
function custom.new(drawFunc, width, height, row, col, customTheme)
    local customTheme = customTheme or luis.theme.text
    return {
        type = "Custom",
        drawFunc = drawFunc,
        width = width * luis.gridSize,
        height = height * luis.gridSize,
        position = luis.Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        
        draw = function(self)
            love.graphics.push()
            love.graphics.translate(self.position.x, self.position.y)
            love.graphics.setColor(customTheme.color or {1, 1, 1, 1})
            self.drawFunc()
            love.graphics.pop()
        end,
        
        setDrawFunc = function(self, newDrawFunc)
            self.drawFunc = newDrawFunc
        end
    }
end

return custom
