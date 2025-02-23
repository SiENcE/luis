local utils = require("luis.3rdparty.utils")
local Vector2D = require("luis.3rdparty.vector")
local decorators = require("luis.3rdparty.decorators")

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
        position = Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
		theme = switchTheme,
		decorator = nil,

        update = function(self, mx, my)
        end,

        defaultDraw = function(self)
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

		-- Draw method that can use a decorator
		draw = function(self)
			if self.decorator then
				self.decorator:draw()
			else
				self:defaultDraw()
			end
		end,

		-- Method to set a decorator
		setDecorator = function(self, decoratorType, ...)
			self.decorator = decorators[decoratorType].new(self, ...)
		end,

        click = function(self, x, y, button, istouch, presses)
            if pointInRect(x, y, self.position.x, self.position.y, self.width, self.height) then
                self.value = not self.value
                if self.onChange then
                    self.onChange(self.value)
                end
                return true
            end
            return false
        end,

        setValue = function(self, value)
			self.value = value
			if self.onChange then
				self.onChange(self.value)
			end
        end,

        -- Joystick-specific functions
        gamepadpressed = function(self, id, button)
			print("switch.gamepadpressed = function", id, button, self.focused)
            if button == 'a' and self.focused then
                self.value = not self.value
                if self.onChange then
                    self.onChange(self.value)
                end
                return true
            end
            return false
        end,
    }
end

return switch
