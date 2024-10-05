local utils = require("examples.3rdparty.utils")
local Vector2D = require("examples.3rdparty.vector")

local Slider = {}

local function setluis(luis)
    Slider.luis = luis
end

function Slider.new(x, y, width, min, max, value, onChange)
    local self = {
        type = "Slider",
        position = Vector2D.new(x, y),
        width = width,
        height = Slider.luis.theme.slider.knobRadius * 2,
        min = min,
        max = max,
        value = value or min,
        onChange = onChange,
        dragging = false,
        hovered = false,
        focusable = true,
        focused = false
    }

    function self:update(mx, my, dt)
        self.hovered = utils.pointInRect(mx, my, self.position.x, self.position.y, self.width, self.height)
        if self.dragging then
            local newValue = (mx - self.position.x) / self.width * (self.max - self.min) + self.min
            self.value = math.max(self.min, math.min(self.max, newValue))
            if self.onChange then
                self.onChange(self.value)
            end
        end
    end

    function self:draw()
        love.graphics.setColor(Slider.luis.theme.slider.trackColor)
        love.graphics.rectangle("fill", self.position.x, self.position.y + self.height / 2 - 2, self.width, 4)
        
        local knobX = self.position.x + (self.value - self.min) / (self.max - self.min) * self.width
        love.graphics.setColor(self.hovered and Slider.luis.theme.slider.grabColor or Slider.luis.theme.slider.knobColor)
        love.graphics.circle("fill", knobX, self.position.y + self.height / 2, Slider.luis.theme.slider.knobRadius)
    end

    function self:click(x, y, button)
        if button == 1 and self.hovered then
            self.dragging = true
            return true
        end
        return false
    end

    function self:release(x, y, button)
        if button == 1 and self.dragging then
            self.dragging = false
            return true
        end
        return false
    end

    return self
end

return {
    new = Slider.new,
    setluis = setluis
}
