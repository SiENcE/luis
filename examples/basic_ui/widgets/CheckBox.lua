local utils = require("examples.3rdparty.utils")
local Vector2D = require("examples.3rdparty.vector")

local Checkbox = {}

local function setluis(luis)
    Checkbox.luis = luis
end

function Checkbox.new(x, y, size, value, onChange)
    local self = {
        type = "CheckBox",
        position = Vector2D.new(x, y),
        size = size,
		width = size,	-- only used for debug
		height = size,	-- only used for debug
        value = checked or false,
        onChange = onChange,
        hovered = false,
        focusable = true,
        focused = false
    }

    function self:update(mx, my, dt)
        self.hovered = utils.pointInRect(mx, my, self.position.x, self.position.y, self.size, self.size)
    end

    function self:draw()
        love.graphics.setColor(Checkbox.luis.theme.checkbox.boxColor)
        love.graphics.rectangle("line", self.position.x, self.position.y, self.size, self.size, Checkbox.luis.theme.checkbox.cornerRadius)
        
        if self.value then
            love.graphics.setColor(Checkbox.luis.theme.checkbox.checkColor)
            love.graphics.rectangle("fill", self.position.x + 2, self.position.y + 2, self.size - 4, self.size - 4, Checkbox.luis.theme.checkbox.cornerRadius)
        end
	end

    function self:click(x, y, button)
        if button == 1 and self.hovered then
            self.value = not self.value
            if self.onChange then
                self.onChange(self.value)
            end
            return true
        end
        return false
    end

    return self
end

return {
    new = Checkbox.new,
    setluis = setluis
}
