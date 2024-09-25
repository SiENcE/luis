local utils = require("luis.utils")

local pointInRect = utils.pointInRect

local switch = {}

local luis  -- This will store the reference to the core library
function switch.setluis(luisObj)
    luis = luisObj
end

-- Switch
function switch.new(value, width, height, onChange, row, col, customTheme)
    local switchTheme = customTheme or luis.theme.switch
    return {
        type = "Switch",
        value = value,
        width = width * luis.gridSize,
        height = height * luis.gridSize,
        onChange = onChange,
        position = luis.Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        
        draw = function(self)
            love.graphics.setColor(self.value and switchTheme.onColor or switchTheme.offColor)
            love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height, self.height / 2)
            
            local knobX = self.value and (self.position.x + self.width - self.height / 2) or (self.position.x + self.height / 2)
            love.graphics.setColor(switchTheme.knobColor)
            love.graphics.circle("fill", knobX, self.position.y + self.height / 2, self.height / 2 - 2)
        end,
        
        click = function(self, x, y)
            if pointInRect(x, y, self.position.x, self.position.y, self.width, self.height) then
                self.value = not self.value
                if self.onChange then
                    self.onChange(self.value)
                end
                return true
            end
            return false
        end
    }
end

return switch
