local utils = require("luis.3rdparty.utils")
local Vector2D = require("luis.3rdparty.vector")
local decorators = require("luis.3rdparty.decorators")

local colorPicker = {}

local luis  -- This will store the reference to the core library
function colorPicker.setluis(luisObj)
    luis = luisObj
end

-- Helper function to convert HSV to RGB
local function HSVtoRGB(h, s, v)
    local r, g, b

    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    i = i % 6

    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end

    return r, g, b
end

-- Helper function to convert RGB to CMYK
local function RGBtoCMYK(r, g, b)
    local k = 1 - math.max(r, g, b)
    local c = (1 - r - k) / (1 - k)
    local m = (1 - g - k) / (1 - k)
    local y = (1 - b - k) / (1 - k)
    return c, m, y, k
end

-- Helper function to convert RGB to HSL
local function RGBtoHSL(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, l

    l = (max + min) / 2

    if max == min then
        h, s = 0, 0
    else
        local d = max - min
        s = l > 0.5 and d / (2 - max - min) or d / (max + min)
        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h / 6
    end

    return h * 360, s, l
end

function colorPicker.new(width, height, row, col, onChange, customTheme)
    local colorPickerTheme = customTheme or luis.theme.colorpicker
    local self = {
        type = "ColorPicker",
        hue = 0,
        saturation = 1,
        value = 1,
        onChange = onChange or function() end,
        focusable = true,
        focused = false,
        width = width * luis.gridSize,
        height = height * luis.gridSize,
        position = Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        theme = colorPickerTheme,
        decorator = nil,
        totalWidth = width * luis.gridSize + 180,  -- Include space for color values display
        totalHeight = height * luis.gridSize + 8,   -- Include padding
    }

    -- Initialize the color immediately
    local r, g, b = HSVtoRGB(self.hue, self.saturation, self.value)
    self.color = {r, g, b, 1}

    function self:isInBounds(x, y)
        return utils.pointInRect(x, y, 
            self.position.x - 6,  -- Account for padding
            self.position.y - 4, 
            self.totalWidth,
            self.totalHeight)
    end

    function self:getSliderRegion(y)
        local relY = y - self.position.y
        local sliderHeight = self.height / 3

        if relY < sliderHeight then
            return "hue"
        elseif relY < sliderHeight * 2 then
            return "saturation"
        elseif relY < sliderHeight * 3 then
            return "value"
        end
        return nil
    end

    function self:updateColor()
        local r, g, b = HSVtoRGB(self.hue, self.saturation, self.value)
        self.color = {r, g, b, 1}
        if self.onChange then
            self.onChange(self.color)
        end
    end

    function self:click(x, y, button)
        if not self:isInBounds(x, y) then return false end
        
        if button == 1 then
            local relX = x - self.position.x
            local region = self:getSliderRegion(y)
            
            if region then
                -- Limit relX to the slider width
                relX = math.max(0, math.min(relX, self.width))
                
                if region == "hue" then
                    self.hue = relX / self.width
                elseif region == "saturation" then
                    self.saturation = relX / self.width
                elseif region == "value" then
                    self.value = relX / self.width
                end
                
                self:updateColor()
                return true
            end
        end
        return false
    end

    function self:wheelmoved(x, y)
        local mx, my = love.mouse.getPosition()
        mx, my = mx / luis.scale, my / luis.scale
        
        if not self:isInBounds(mx, my) then
            return false
        end

        local region = self:getSliderRegion(my)
        if not region then return false end

        -- Adjust step size for finer control
        local step = 0.01
        if region == "hue" then
            self.hue = (self.hue + y * step) % 1
        elseif region == "saturation" then
            self.saturation = math.max(0, math.min(1, self.saturation + y * step))
        elseif region == "value" then
            self.value = math.max(0, math.min(1, self.value + y * step))
        end

        self:updateColor()
        return true
    end

    function self:update(mx, my, dt)
        -- Add any update logic here if needed
    end

    function self:defaultDraw()
        love.graphics.setLineWidth(1)

        -- Draw background and frame
        love.graphics.setColor(self.theme.backgroundColor)
        love.graphics.rectangle("fill", self.position.x - 6, self.position.y - 4, self.totalWidth, self.totalHeight, self.theme.cornerRadius, self.theme.cornerRadius)

        -- Draw outer frame
        love.graphics.setColor(self.theme.borderColor)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", self.position.x - 6, self.position.y - 4, self.totalWidth, self.totalHeight, self.theme.cornerRadius, self.theme.cornerRadius)

        -- Draw hue slider
        for i = 0, self.width do
            local hue = i / self.width
            local r, g, b = HSVtoRGB(hue, 1, 1)
            love.graphics.setColor(r, g, b)
            love.graphics.line(self.position.x + i, self.position.y, self.position.x + i, self.position.y + self.height / 3)
        end
        
        -- Draw saturation slider
        for i = 0, self.width do
            local sat = i / self.width
            local r, g, b = HSVtoRGB(self.hue, sat, self.value)
            love.graphics.setColor(r, g, b)
            love.graphics.line(self.position.x + i, self.position.y + self.height / 3, self.position.x + i, self.position.y + self.height * 2/3)
        end
        
        -- Draw value slider
        for i = 0, self.width do
            local val = i / self.width
            local r, g, b = HSVtoRGB(self.hue, self.saturation, val)
            love.graphics.setColor(r, g, b)
            love.graphics.line(self.position.x + i, self.position.y + self.height * 2/3, self.position.x + i, self.position.y + self.height)
        end
        
        -- Draw sliders
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", self.position.x + self.hue * self.width, self.position.y + self.height / 6, 5)
        love.graphics.circle("fill", self.position.x + self.saturation * self.width, self.position.y + self.height / 2, 5)
        love.graphics.circle("fill", self.position.x + self.value * self.width, self.position.y + self.height * 5/6, 5)
        
        -- Draw selected color
        love.graphics.setColor(self.color)
        love.graphics.rectangle("fill", self.position.x + self.width + 10, self.position.y, 30, self.height)

        -- Draw focus indicator
        if self.focused then
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.rectangle("line", self.position.x - 8, self.position.y - 6, self.totalWidth + 4, self.totalHeight + 4, self.theme.cornerRadius + 2)
        end

        -- Print color values
        love.graphics.setColor(1, 1, 1)
        local r, g, b = unpack(self.color)
        local hex = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
        local rgb = string.format("RGB: %d, %d, %d", r * 255, g * 255, b * 255)
        local c, m, y, k = RGBtoCMYK(r, g, b)
        local cmyk = string.format("CMYK: %.2f, %.2f, %.2f, %.2f", c, m, y, k)
        local hsv = string.format("HSV: %.2f, %.2f, %.2f", self.hue * 360, self.saturation, self.value)
        local h, s, l = RGBtoHSL(r, g, b)
        local hsl = string.format("HSL: %.2f, %.2f, %.2f", h, s, l)

        local font_backup = love.graphics.getFont()
        love.graphics.setFont(self.theme.font)
        love.graphics.print(hex, self.position.x + self.width + 50, self.position.y)
        love.graphics.print(rgb, self.position.x + self.width + 50, self.position.y + 12)
        love.graphics.print(cmyk, self.position.x + self.width + 50, self.position.y + 24)
        love.graphics.print(hsv, self.position.x + self.width + 50, self.position.y + 36)
        love.graphics.print(hsl, self.position.x + self.width + 50, self.position.y + 48)
        love.graphics.setFont(font_backup)
    end

    function self:draw()
        if self.decorator then
            self.decorator:draw()
        else
            self:defaultDraw()
        end
    end

    function self:setDecorator(decoratorType, ...)
        self.decorator = decorators[decoratorType].new(self, ...)
    end

    return self
end

return colorPicker