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
        focused = false,
        focusable = true,  -- Make the button focusable
        position = luis.Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        checkScale = value and 1 or 0,

        update = function(self, mx, my)
            -- Update focus state
            self.focused = (luis.currentFocus == self)

            -- Check for joystick button press when focused
            if self.focused and luis.joystickJustPressed('a') then
                if self.click then
					self:click(self.position.x+1,self.position.y+1)
				end
            elseif self.pressed and not luis.isJoystickPressed('a') then
                if self.release then
					self:release()
				end
            end
        end,

        draw = function(self)
            love.graphics.setColor(checkboxTheme.boxColor)
            love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height, checkboxTheme.cornerRadius)
            
            love.graphics.setColor(checkboxTheme.checkColor)
            local padding = self.width * 0.2
            love.graphics.rectangle("fill", 
                self.position.x + padding + (self.width - padding * 2) * (1 - self.checkScale) / 2, 
                self.position.y + padding + (self.height - padding * 2) * (1 - self.checkScale) / 2, 
                (self.width - padding * 2) * self.checkScale, 
                (self.height - padding * 2) * self.checkScale
            )

            -- Draw focus indicator
            if self.focused then
                love.graphics.setColor(1, 1, 1, 0.5)
                love.graphics.rectangle("line", self.position.x - 2, self.position.y - 2, self.width + 4, self.height + 4, checkboxTheme.cornerRadius)
            end
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
