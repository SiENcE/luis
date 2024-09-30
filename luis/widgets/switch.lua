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
        focused = false,
        focusable = true,  -- Make the button focusable
        position = luis.Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),

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
            love.graphics.setColor(self.value and switchTheme.onColor or switchTheme.offColor)
            love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height, self.height / 2)
            
            local knobX = self.value and (self.position.x + self.width - self.height / 2) or (self.position.x + self.height / 2)
            love.graphics.setColor(switchTheme.knobColor)
            love.graphics.circle("fill", knobX, self.position.y + self.height / 2, self.height / 2 - 2)

            -- Draw focus indicator
            if self.focused then
                love.graphics.setColor(1, 1, 1, 0.5)
                love.graphics.rectangle("line", self.position.x - 2, self.position.y - 2, self.width + 4, self.height + 4)
            end
        end,
        
        click = function(self, x, y, button, istouch)
            if pointInRect(x, y, self.position.x, self.position.y, self.width, self.height) then
                self.value = not self.value
                if self.onChange then
                    self.onChange(self.value)
                end
                return true
            end
            return false
        end,
--[[
        -- Joystick-specific functions
        gamepadpressed = function(self, button)
			print("checkbox.gamepadpressed = function", button)
            if button == 'a' and self.focused and self.click then
                self:click(self.position.x+1,self.position.y+1)
            end
            return false
        end,
        
        gamepadreleased = function(self, button)
			print("checkbox.gamepadreleased = function", button)
            if button == 'a' and self.pressed and self.release then
                return self:release()
            end
            return false
        end
]]--
    }
end

return switch
