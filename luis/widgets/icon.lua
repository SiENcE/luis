local icon = {}

local luis  -- This will store the reference to the core library
function icon.setluis(luisObj)
    luis = luisObj
end

-- Icon
function icon.new(iconPath, size, row, col, customTheme)
    local iconTheme = customTheme or luis.theme.icon
    local icon = love.graphics.newImage(iconPath)
    return {
        type = "Icon",
        icon = icon,
        width = size * luis.gridSize,
        height = size * luis.gridSize,
        position = luis.Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        
        draw = function(self)
            love.graphics.setColor(iconTheme.color)
            love.graphics.draw(self.icon, self.position.x, self.position.y, 0, self.width / self.icon:getWidth(), self.height / self.icon:getHeight())
        end
    }
end

return icon
