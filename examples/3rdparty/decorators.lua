-- decorators.lua

local decorators = {}

-- Base Decorator
local BaseDecorator = {}
BaseDecorator.__index = BaseDecorator

function BaseDecorator.new(widget)
    local self = setmetatable({}, BaseDecorator)
    self.widget = widget
    return self
end

function BaseDecorator:draw()
    self.widget:defaultDraw()
end

decorators.BaseDecorator = BaseDecorator

-- Additional decorators can be added here

-- Glow Decorator
local GlowDecorator = setmetatable({}, {__index = BaseDecorator})
GlowDecorator.__index = GlowDecorator

function GlowDecorator.new(widget, glowColor, glowSize)
    local self = setmetatable(BaseDecorator.new(widget), GlowDecorator)
    self.glowColor = glowColor or {1, 1, 1, 0.5}
    self.glowSize = glowSize or 10
    return self
end

function GlowDecorator:draw()
    -- Draw glow effect
    love.graphics.setColor(self.glowColor)
    for i = self.glowSize, 1, -1 do
        love.graphics.rectangle("line", 
            self.widget.position.x - i, 
            self.widget.position.y - i, 
            self.widget.width + i * 2, 
            self.widget.height + i * 2, 
            self.widget.theme.cornerRadius
			)
    end
    
    -- Call the base draw method (which calls the widget's defaultDraw)
    BaseDecorator.draw(self)
end

decorators.GlowDecorator = GlowDecorator

-- Slice-9 Decorator
local Slice9Decorator = setmetatable({}, {__index = BaseDecorator})
Slice9Decorator.__index = Slice9Decorator

function Slice9Decorator.new(widget, image, left, right, top, bottom)
    local self = setmetatable(BaseDecorator.new(widget), Slice9Decorator)
    self.image = image
    self.left = left
    self.right = right
    self.top = top
    self.bottom = bottom
    return self
end

function Slice9Decorator:draw()
    local x, y = self.widget.position.x, self.widget.position.y
    local w, h = self.widget.width, self.widget.height
    local iw, ih = self.image:getDimensions()
    
    -- Center width and height
    local cw = iw - self.left - self.right
    local ch = ih - self.top - self.bottom
    
    -- Draw corners
    love.graphics.draw(self.image, love.graphics.newQuad(0, 0, self.left, self.top, iw, ih), x, y)
    love.graphics.draw(self.image, love.graphics.newQuad(iw - self.right, 0, self.right, self.top, iw, ih), x + w - self.right, y)
    love.graphics.draw(self.image, love.graphics.newQuad(0, ih - self.bottom, self.left, self.bottom, iw, ih), x, y + h - self.bottom)
    love.graphics.draw(self.image, love.graphics.newQuad(iw - self.right, ih - self.bottom, self.right, self.bottom, iw, ih), x + w - self.right, y + h - self.bottom)
    
    -- Draw edges
    love.graphics.draw(self.image, love.graphics.newQuad(self.left, 0, cw, self.top, iw, ih), x + self.left, y, 0, (w - self.left - self.right) / cw, 1)
    love.graphics.draw(self.image, love.graphics.newQuad(self.left, ih - self.bottom, cw, self.bottom, iw, ih), x + self.left, y + h - self.bottom, 0, (w - self.left - self.right) / cw, 1)
    love.graphics.draw(self.image, love.graphics.newQuad(0, self.top, self.left, ch, iw, ih), x, y + self.top, 0, 1, (h - self.top - self.bottom) / ch)
    love.graphics.draw(self.image, love.graphics.newQuad(iw - self.right, self.top, self.right, ch, iw, ih), x + w - self.right, y + self.top, 0, 1, (h - self.top - self.bottom) / ch)
    
    -- Draw center
    love.graphics.draw(self.image, love.graphics.newQuad(self.left, self.top, cw, ch, iw, ih), x + self.left, y + self.top, 0, (w - self.left - self.right) / cw, (h - self.top - self.bottom) / ch)
    
    -- Call the base draw method (which calls the widget's defaultDraw)
    BaseDecorator.draw(self)
end

decorators.Slice9Decorator = Slice9Decorator

return decorators
