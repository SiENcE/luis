local utils = require("examples.3rdparty.utils")
local Vector2D = require("examples.3rdparty.vector")

local Button = {}

local function setluis(luis)
    Button.luis = luis
end

function Button.new(x, y, width, height, text, onClick)
    local self = {
        type = "Button",
        position = Vector2D.new(x, y),
        width = width,
        height = height,
        text = text,
        onClick = onClick,
        hovered = false,
        pressed = false,
        focusable = true,
        focused = false
    }

    function self:update(mx, my, dt)
        local wasHovered = self.hovered
        self.hovered = utils.pointInRect(mx, my, self.position.x, self.position.y, self.width, self.height)
    end

    function self:draw()
        love.graphics.setColor(self.pressed and Button.luis.theme.button.pressedColor or
                               self.hovered and Button.luis.theme.button.hoverColor or
                               Button.luis.theme.button.color)
        love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height, Button.luis.theme.button.cornerRadius)
        
        love.graphics.setColor(Button.luis.theme.button.textColor)
        love.graphics.setFont(Button.luis.theme.text.font)
        local textWidth = Button.luis.theme.text.font:getWidth(self.text)
        local textHeight = Button.luis.theme.text.font:getHeight()
        love.graphics.print(self.text, self.position.x + (self.width - textWidth) / 2, self.position.y + (self.height - textHeight) / 2)
    end

    function self:click(x, y, button)
        if button == 1 and self.hovered then
            self.pressed = true
            if self.onClick then
                self.onClick()
            end
            return true
        end
        return false
    end

    function self:release(x, y, button)
        if button == 1 and self.pressed then
            self.pressed = false
            return true
        end
        return false
    end

    return self
end

return {
    new = Button.new,
    setluis = setluis
}
