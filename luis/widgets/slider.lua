local utils = require("luis.utils")
local pointInRect = utils.pointInRect

local slider = {}

local luis  -- This will store the reference to the core library
function slider.setluis(luisObj)
    luis = luisObj
end

-- Slider
function slider.new(min, max, value, width, height, onChange, row, col, sliderTheme)
    local sliderTheme = sliderTheme or luis.theme.slider
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
        dragging = false,
        position = luis.Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        knob = knob,
        
        update = function(self, mx, my)
            if self.dragging then
                local percentage = (mx - self.position.x) / self.width
                self.value = self.min + (self.max - self.min) * math.max(0, math.min(1, percentage))
                if self.onChange then
                    self.onChange(self.value)
                end
            end
        end,
        
        draw = function(self)
            love.graphics.setColor(sliderTheme.trackColor)
            love.graphics.rectangle("fill", self.position.x, self.position.y + self.height / 2 - 2, self.width, 4)
            
            local knobX = self.position.x + (self.value - self.min) / (self.max - self.min) * self.width
            love.graphics.setColor(self.dragging and sliderTheme.grabColor or sliderTheme.knobColor)
            love.graphics.circle("fill", knobX, self.position.y + self.height / 2, self.knob.currentRadius or self.knob.radius)
        end,
        
        click = function(self, x, y, button, istouch)
            local knobX = self.position.x + (self.value - self.min) / (self.max - self.min) * self.width
            if pointInRect(x, y, knobX - self.knob.radius, self.position.y, self.knob.radius * 2, self.height) then
                self.dragging = true
                self:update(x, y)
                
                -- Animate knob enlargement
                luis.flux.to(self.knob, 0.1, { currentRadius = self.knob.grabRadius })
                    :ease("quadout")
                
                return true
            end
            return false
        end,
        
        release = function(self)
            if self.dragging then
                self.dragging = false
                
                -- Animate knob shrinking with a slight bounce
                luis.flux.to(self.knob, 0.1, { currentRadius = self.knob.radius })
                    :ease("bounceout")
            end
        end
    }
end

return slider
