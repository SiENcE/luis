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
    
    -- Reset color so the widget's defaultDraw doesn't inherit the glow color.
    love.graphics.setColor(1, 1, 1, 1)

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

    -- The source rectangles depend only on the image and the insets, so build the
    -- nine quads once here instead of allocating them every frame in :draw.
    local iw, ih = image:getDimensions()
    self.iw, self.ih = iw, ih
    local cw = iw - left - right
    local ch = ih - top - bottom
    self.cw, self.ch = cw, ch

    if cw > 0 and ch > 0 then
        self.quads = {
            tl     = love.graphics.newQuad(0,         0,          left,  top,    iw, ih),
            tr     = love.graphics.newQuad(iw - right, 0,         right, top,    iw, ih),
            bl     = love.graphics.newQuad(0,         ih - bottom, left,  bottom, iw, ih),
            br     = love.graphics.newQuad(iw - right, ih - bottom, right, bottom, iw, ih),
            top    = love.graphics.newQuad(left,      0,          cw,    top,    iw, ih),
            bottom = love.graphics.newQuad(left,      ih - bottom, cw,    bottom, iw, ih),
            left   = love.graphics.newQuad(0,         top,        left,  ch,     iw, ih),
            right  = love.graphics.newQuad(iw - right, top,       right, ch,     iw, ih),
            center = love.graphics.newQuad(left,      top,        cw,    ch,     iw, ih),
        }
    end
    return self
end

function Slice9Decorator:draw(this)
    -- Accept the widget either via the `this` argument (legacy call style) or,
    -- when invoked uniformly as `decorator:draw()`, fall back to self.widget.
    this = this or self.widget
    local x, y = self.widget.position.x, self.widget.position.y
    local w, h = self.widget.width, self.widget.height
    local iw, ih = self.iw, self.ih

    -- Draw the image untinted (don't inherit a previous setColor).
    love.graphics.setColor(1, 1, 1, 1)

    if not self.quads then
        -- Degenerate slice insets: fall back to a plain stretched draw.
        love.graphics.draw(self.image, x, y, 0, w / iw, h / ih)
    else
        local q = self.quads
        local sx = (w - self.left - self.right) / self.cw
        local sy = (h - self.top - self.bottom) / self.ch

        -- Corners
        love.graphics.draw(self.image, q.tl, x, y)
        love.graphics.draw(self.image, q.tr, x + w - self.right, y)
        love.graphics.draw(self.image, q.bl, x, y + h - self.bottom)
        love.graphics.draw(self.image, q.br, x + w - self.right, y + h - self.bottom)

        -- Edges
        love.graphics.draw(self.image, q.top,    x + self.left, y,                  0, sx, 1)
        love.graphics.draw(self.image, q.bottom, x + self.left, y + h - self.bottom, 0, sx, 1)
        love.graphics.draw(self.image, q.left,   x,             y + self.top,        0, 1, sy)
        love.graphics.draw(self.image, q.right,  x + w - self.right, y + self.top,   0, 1, sy)

        -- Center
        love.graphics.draw(self.image, q.center, x + self.left, y + self.top, 0, sx, sy)
    end

	-- Draw text
	if this and this.text then
		love.graphics.setColor(this.theme.textColor)
		local font_backup = love.graphics.getFont()
		love.graphics.printf(this.text, this.position.x, this.position.y + (this.height - font_backup:getHeight()) / 2, this.width, this.theme.align)
	end
end

decorators.Slice9Decorator = Slice9Decorator

-- Glassmorphism Decorator
local GlassmorphismDecorator = setmetatable({}, {__index = BaseDecorator})
GlassmorphismDecorator.__index = GlassmorphismDecorator

function GlassmorphismDecorator.new(widget, options)
    local self = setmetatable(BaseDecorator.new(widget), GlassmorphismDecorator)

    -- Tolerate a missing options table (every other decorator does)
    options = options or {}

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

    -- Reset color/line width so the widget's defaultDraw starts from a clean state.
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)

    -- Call the widget's default draw method
    BaseDecorator.draw(self)
end

-- Add to the decorators table
decorators.GlassmorphismDecorator = GlassmorphismDecorator

return decorators
