local utils = require("luis.utils")

local pointInRect = utils.pointInRect

local checkBox = {}

local luis  -- This will store the reference to the core library
function checkBox.setluis(luisObj)
    luis = luisObj
end

-- checkBox
function checkBox.new(value, size, onChange, row, col, customTheme)
    local checkboxTheme = customTheme or luis.theme.checkbox
    return {
        type = "CheckBox",
        value = value,
        width = size * luis.gridSize,
        height = size * luis.gridSize,
        onChange = onChange,
        position = luis.Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        checkScale = value and 1 or 0,
        
        draw = function(self)
            love.graphics.setColor(checkboxTheme.boxColor)
            love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height)
            
            love.graphics.setColor(checkboxTheme.checkColor)
            local padding = self.width * 0.2
            love.graphics.rectangle("fill", 
                self.position.x + padding + (self.width - padding * 2) * (1 - self.checkScale) / 2, 
                self.position.y + padding + (self.height - padding * 2) * (1 - self.checkScale) / 2, 
                (self.width - padding * 2) * self.checkScale, 
                (self.height - padding * 2) * self.checkScale
            )
        end,
        
        click = function(self, x, y, button, istouch)
            if pointInRect(x, y, self.position.x, self.position.y, self.width, self.height) then
                self.value = not self.value
                luis.flux.to(self, 0.2, { checkScale = self.value and 1 or 0 })
                if self.onChange then
                    self.onChange(self.value)
                end
                return true
            end
            return false
        end
    }
end

return checkBox
