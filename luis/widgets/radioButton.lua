local utils = require("luis.utils")

local pointInRect = utils.pointInRect

local radioButton = {}

local luis  -- This will store the reference to the core library
function radioButton.setluis(luisObj)
    luis = luisObj
end

-- radioButton
function radioButton.new(group, value, size, onChange, row, col, customTheme)
    local radioTheme = customTheme or luis.theme.radiobutton
    return {
        type = "RadioButton",
        group = group,
        value = value,
        width = size * luis.gridSize,
        height = size * luis.gridSize,
        onChange = onChange,
        position = luis.Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        
        draw = function(self)
            love.graphics.setColor(radioTheme.circleColor)
            love.graphics.circle("fill", self.position.x + self.width / 2, self.position.y + self.height / 2, self.width / 2)
            
            if self.value then
                love.graphics.setColor(radioTheme.dotColor)
                love.graphics.circle("fill", self.position.x + self.width / 2, self.position.y + self.height / 2, self.width / 4)
            end
        end,
        
        click = function(self, x, y, button, istouch)
            if pointInRect(x, y, self.position.x, self.position.y, self.width, self.height) and not self.value then
                -- Deactivate all other radioButtons in the same group
                for _, element in ipairs(luis.elements[luis.currentLayer]) do
                    if element.type == "RadioButton" and element.group == self.group then
                        element.value = false
                    end
                end
                self.value = true
                if self.onChange then
                    self.onChange(self.value)
                end
                return true
            end
            return false
        end
    }
end

return radioButton
