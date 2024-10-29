local Vector2D = require("examples.3rdparty.vector")
local custom = require("examples.complex_ui.widgets.custom")

local colorPicker = {}

local luis  -- This will store the reference to the core library
function colorPicker.setluis(luisObj)
    luis = luisObj
end

function colorPicker.new(width, height, row, col, onChange, customTheme)
	local colorPickerTheme = customTheme or luis.theme.colorpicker
    local colorp = custom.new(colorPicker.draw, width, height, row, col, colorPickerTheme)

    colorp.type = "ColorPicker"
    colorp.hue = 0
    colorp.saturation = 1
    colorp.value = 1
    colorp.onChange = onChange or function() end
    colorp.focusable = true
	theme = colorPickerTheme

    function colorp:updateColor()
        local r, g, b = HSVtoRGB(self.hue, self.saturation, self.value)
        self.color = {r, g, b, 1}
        self.onChange(self.color)
    end

    function colorp:click(x, y, button)
        if button == 1 then
            local relX = x - self.position.x
            local relY = y - self.position.y
            
            -- Limit relX and relY to colorp bounds
            relX = math.max(0, math.min(relX, self.width))
            relY = math.max(0, math.min(relY, self.height))
            
            -- Hue slider
            if relY < self.height * 0.33 then
                self.hue = relX / self.width
            -- Saturation slider
            elseif relY < self.height * 0.66 then
                self.saturation = relX / self.width
            -- Value slider
            else
                self.value = relX / self.width
            end
            
            self:updateColor()
        end
    end

    function colorp:wheelmoved(x, y)
        if self.focused then
            self.hue = (self.hue + y * 0.01) % 1
            self:updateColor()
        end
    end

    colorp:updateColor()

    return colorp
end

function colorPicker.draw(self)
    love.graphics.setLineWidth(1)

    -- Draw background and frame
    love.graphics.setColor( self.theme.backgroundColor )
    love.graphics.rectangle("fill", -6, -4, self.width+180, self.height+8, self.theme.cornerRadius, self.theme.cornerRadius)

    -- Draw outer frame
    love.graphics.setColor( self.theme.borderColor )
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", -6, -4, self.width+180, self.height+8, self.theme.cornerRadius, self.theme.cornerRadius)

    -- Draw hue slider
    for i = 0, self.width do
        local hue = i / self.width
        local r, g, b = HSVtoRGB(hue, 1, 1)
        love.graphics.setColor(r, g, b)
        love.graphics.line(i, 0, i, self.height / 3)
    end
    
    -- Draw saturation slider
    for i = 0, self.width do
        local sat = i / self.width
        local r, g, b = HSVtoRGB(self.hue, sat, self.value)
        love.graphics.setColor(r, g, b)
        love.graphics.line(i, self.height / 3, i, self.height * 2/3)
    end
    
    -- Draw value slider
    for i = 0, self.width do
        local val = i / self.width
        local r, g, b = HSVtoRGB(self.hue, self.saturation, val)
        love.graphics.setColor(r, g, b)
        love.graphics.line(i, self.height * 2/3, i, self.height)
    end
    
    -- Draw sliders
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", self.hue * self.width, self.height / 6, 5)
    love.graphics.circle("fill", self.saturation * self.width, self.height / 2, 5)
    love.graphics.circle("fill", self.value * self.width, self.height * 5/6, 5)
    
    -- Draw selected color
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.width + 10, 0, 30, self.height)

    -- Draw focus indicator
    if self.focused then
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.rectangle("line", self.position.x - 2, self.position.y - 2, self.width + 4, self.height + 4, 4 + 2)
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
    love.graphics.print(hex, self.width + 50, 0)
    love.graphics.print(rgb, self.width + 50, 12)
    love.graphics.print(cmyk, self.width + 50, 24)
    love.graphics.print(hsv, self.width + 50, 36)
    love.graphics.print(hsl, self.width + 50, 48)
	love.graphics.setFont(font_backup)
end

-- Helper function to convert HSV to RGB
function HSVtoRGB(h, s, v)
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
function RGBtoCMYK(r, g, b)
    local k = 1 - math.max(r, g, b)
    local c = (1 - r - k) / (1 - k)
    local m = (1 - g - k) / (1 - k)
    local y = (1 - b - k) / (1 - k)
    return c, m, y, k
end

-- Helper function to convert RGB to HSL
function RGBtoHSL(r, g, b)
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

return colorPicker
