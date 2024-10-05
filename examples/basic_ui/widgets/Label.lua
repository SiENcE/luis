local utils = require("examples.3rdparty.utils")
local Vector2D = require("examples.3rdparty.vector")

local Label = {}

local function setluis(luis)
    Label.luis = luis
end

function Label.new(x, y, text, width)
    local self = {
        type = "Label",
        position = Vector2D.new(x, y),
        text = text,
        width = width,
		height = Label.luis.theme.text.font:getHeight(),
        focusable = false
    }

    function self:update(mx, my, dt)
        -- Labels don't need updating
    end

    function self:draw()
        love.graphics.setColor(Label.luis.theme.text.color)
        love.graphics.setFont(Label.luis.theme.text.font)
        love.graphics.printf(self.text, self.position.x, self.position.y, self.width, Label.luis.theme.text.align)
    end

    return self
end

return {
    new = Label.new,
    setluis = setluis
}
