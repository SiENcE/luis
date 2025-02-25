local utils = require("luis.3rdparty.utils")
local Vector2D = require("luis.3rdparty.vector")
local decorators = require("luis.3rdparty.decorators")

local pointInRect = utils.pointInRect

local slider = {}

local luis  -- This will store the reference to the core library
function slider.setluis(luisObj)
    luis = luisObj
end

function slider.new(min, max, value, width, height, onChange, row, col, customTheme)
    local sliderTheme = customTheme or luis.theme.slider
    local knob = {
        radius = sliderTheme.knobRadius,
		currentRadius = sliderTheme.knobRadius,
        grabRadius = sliderTheme.knobRadius * 1.5,  -- Increased size when grabbed
    }
    return {
        type = "Slider",
        min = min,
        max = max,
        value = value,
        width = width * luis.gridSize,
        height = height * luis.gridSize,
        onChange = onChange,
        position = Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        knob = knob,
        hover = false,
        pressed = false,
        focused = false,
        focusable = true,
		theme = sliderTheme,
		decorator = nil,

        update = function(self, mx, my)
            local wasHovered = self.hover
            self.hover = pointInRect(mx, my, self.position.x, self.position.y, self.width, self.height)
            
			-- Handle mouse input
            if love.mouse.isDown(1) and self.hover then
                self:setValue(self:getValueFromPosition(mx - self.position.x))
            end

            -- Handle joystick/gamepad input when focused
            if self.focused then
--                local jx = luis.getJoystickAxis(1, 'leftx')
--                if math.abs(jx) > luis.deadzone then
--                    local delta = jx * (self.max - self.min) * 0.01  -- Adjust sensitivity as needed
--                    self:setValue(self.value + delta)
--                end
                
                -- Handle gamepad button input for more precise control
                if luis.isJoystickPressed(1, 'dpright') then
                    self:setValue(self.value + (self.max - self.min) * 0.01)
                elseif luis.isJoystickPressed(1, 'dpleft') then
                    self:setValue(self.value - (self.max - self.min) * 0.01)
                end
            end

        end,
        
        defaultDraw = function(self)
            -- Draw track
            love.graphics.setColor(sliderTheme.trackColor)
            love.graphics.rectangle("fill", self.position.x, self.position.y + self.height / 2 - 2, self.width, 4)
            
            -- Draw knob
            local knobX = self.position.x + (self.value - self.min) / (self.max - self.min) * self.width
            love.graphics.setColor(self.hover and sliderTheme.grabColor or sliderTheme.knobColor)
            love.graphics.circle("fill", knobX, self.position.y + self.height / 2, self.knob.currentRadius or self.knob.radius)
            
            -- Draw focus indicator
            if self.focused then
                love.graphics.setColor(1, 1, 1, 0.5)
                love.graphics.rectangle("line", self.position.x - 2, self.position.y - 2, self.width + 4, self.height + 4, 4)
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
            if self.hover and button == 1 then
                self.pressed = true
                self:setValue(self:getValueFromPosition(x - self.position.x))

                -- Animate knob enlargement
                luis.flux.to(self.knob, 0.1, { currentRadius = self.knob.grabRadius })
                    :ease("quadout")

                return true
            end
            return false
        end,
        
        release = function(self, x, y, button, istouch)
            if self.pressed and button == 1 then
                self.pressed = false
                self:setValue(self:getValueFromPosition(x - self.position.x))

                -- Animate knob shrinking with a slight bounce
                luis.flux.to(self.knob, 0.1, { currentRadius = self.knob.radius })
                    :ease("bounceout")

                return true
            end
            return false
        end,
        
        setValue = function(self, newValue)
            newValue = math.max(self.min, math.min(self.max, newValue))
            if newValue ~= self.value then
                self.value = newValue
                if self.onChange then
                    self.onChange(self.value)
                end
            end
        end,
        
        getValue = function(self)
            return self.value
        end,
        
        getValueFromPosition = function(self, x)
            return self.min + (x / self.width) * (self.max - self.min)
        end,
        
        updateFocus = function(self, jx, jy)
            -- Handle continuous joystick input for smoother control
            if math.abs(jx) > luis.deadzone then
                local delta = jx * (self.max - self.min) * 0.005  -- Adjust sensitivity as needed
                self:setValue(self.value + delta)
            end
        end,

    }
end

return slider
