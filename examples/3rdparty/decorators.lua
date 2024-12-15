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

function Slice9Decorator:draw(this)
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

	-- Draw text
	if this.text then
		love.graphics.setColor(this.theme.textColor)
		local font_backup = love.graphics.getFont()
		love.graphics.printf(this.text, this.position.x, this.position.y + (this.height - font_backup:getHeight()) / 2, this.width, this.theme.align)
	end

    -- Call the base draw method (which calls the widget's defaultDraw)
    --BaseDecorator.draw(self)
end

decorators.Slice9Decorator = Slice9Decorator

-- Glassmorphism Decorator
local GlassmorphismDecorator = setmetatable({}, {__index = BaseDecorator})
GlassmorphismDecorator.__index = GlassmorphismDecorator

function GlassmorphismDecorator.new(widget, options)
    local self = setmetatable(BaseDecorator.new(widget), GlassmorphismDecorator)
    
    -- Default options
    self.options = {
        opacity = options.opacity or 0.5,
        blur = options.blur or 10,
        borderRadius = options.borderRadius or 10,
        borderWidth = options.borderWidth or 1,
        borderColor = options.borderColor or {1, 1, 1, 0.2},
        backgroundColor = options.backgroundColor or {1, 1, 1, 0.1},
        shadowColor = options.shadowColor or {0, 0, 0, 0.2},
        shadowBlur = options.shadowBlur or 15,
        shadowOffsetX = options.shadowOffsetX or 5,
        shadowOffsetY = options.shadowOffsetY or 5,
        highlightColor = options.highlightColor or {1, 1, 1, 0.1},
        highlightWidth = options.highlightWidth or 1
    }
    
    return self
end

function GlassmorphismDecorator:draw()
    local x, y = self.widget.position.x, self.widget.position.y
    local w, h = self.widget.width, self.widget.height
    local opt = self.options
    
    -- Draw shadow
    love.graphics.setColor(opt.shadowColor)
    for i = 1, opt.shadowBlur do
        local alpha = (opt.shadowBlur - i) / opt.shadowBlur * opt.shadowColor[4]
        love.graphics.setColor(opt.shadowColor[1], opt.shadowColor[2], opt.shadowColor[3], alpha)
        love.graphics.rectangle(
            "fill",
            x + opt.shadowOffsetX - i/2,
            y + opt.shadowOffsetY - i/2,
            w + i,
            h + i,
            opt.borderRadius
        )
    end
    
    -- Draw main background with glass effect
    love.graphics.setColor(opt.backgroundColor)
    love.graphics.rectangle("fill", x, y, w, h, opt.borderRadius)
    
    -- Draw border
    love.graphics.setColor(opt.borderColor)
    love.graphics.setLineWidth(opt.borderWidth)
    love.graphics.rectangle("line", x, y, w, h, opt.borderRadius)
    
    -- Draw highlight edge (top and left)
    love.graphics.setColor(opt.highlightColor)
    love.graphics.setLineWidth(opt.highlightWidth)
    love.graphics.line(
        x, y + h - opt.borderRadius,  -- Start from bottom-left
        x, y + opt.borderRadius,      -- Go up to top-left
        x + opt.borderRadius, y       -- Turn right to top
    )
    
    -- Call the widget's default draw method
    BaseDecorator.draw(self)
end

-- Add to the decorators table
decorators.GlassmorphismDecorator = GlassmorphismDecorator

return decorators
