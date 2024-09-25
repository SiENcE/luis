local utils = require("luis.utils")

local pointInRect = utils.pointInRect

local button = {}

local luis  -- This will store the reference to the core library
function button.setluis(luisObj)
    luis = luisObj
end

local function drawElevatedRectangle(x, y, width, height, color, elevation, cornerRadius)
    local shadowColor = {0, 0, 0, 0.2}
    local shadowBlur = elevation * 2
    
    -- Draw shadow
    love.graphics.setColor(shadowColor)
    love.graphics.rectangle("fill", x - shadowBlur/2, y - shadowBlur/2 + elevation, width + shadowBlur, height + shadowBlur, cornerRadius)
    
    -- Draw main rectangle
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, width, height, cornerRadius)
end

-- Button
function button.new(text, width, height, onClick, row, col, customTheme)
    local buttonTheme = customTheme or luis.theme.button
    local button = {
        type = "Button",
        text = text,
        width = width * luis.gridSize,
        height = height * luis.gridSize,
        onClick = onClick,
        hover = false,
        pressed = false,
        position = luis.Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        colorR = buttonTheme.color[1],
        colorG = buttonTheme.color[2],
        colorB = buttonTheme.color[3],
        colorA = buttonTheme.color[4],
        elevation = buttonTheme.elevation,
        
        update = function(self, mx, my)
            local wasHovered = self.hover
            self.hover = pointInRect(mx, my, self.position.x, self.position.y, self.width, self.height)
            
            if self.hover and not wasHovered then
                luis.flux.to(self, buttonTheme.transitionDuration, {
                    elevation = buttonTheme.elevationHover,
                    colorR = buttonTheme.hoverColor[1],
                    colorG = buttonTheme.hoverColor[2],
                    colorB = buttonTheme.hoverColor[3],
                    colorA = buttonTheme.hoverColor[4]
                })
            elseif not self.hover and wasHovered then
                luis.flux.to(self, buttonTheme.transitionDuration, {
                    elevation = buttonTheme.elevation,
                    colorR = buttonTheme.color[1],
                    colorG = buttonTheme.color[2],
                    colorB = buttonTheme.color[3],
                    colorA = buttonTheme.color[4]
                })
            end
        end,
        
        draw = function(self)
            drawElevatedRectangle(self.position.x, self.position.y, self.width, self.height, {self.colorR, self.colorG, self.colorB, self.colorA}, self.elevation, buttonTheme.cornerRadius)

            -- Draw text
            love.graphics.setColor(buttonTheme.textColor)
            love.graphics.printf(self.text, self.position.x, self.position.y + (self.height - luis.theme.text.font:getHeight()) / 2, self.width, buttonTheme.align)
        end,
        
        click = function(self, x, y)
            if self.hover then
                self.pressed = true
                luis.flux.to(self, buttonTheme.transitionDuration, {
                    elevation = buttonTheme.elevationPressed,
                    colorR = buttonTheme.pressedColor[1],
                    colorG = buttonTheme.pressedColor[2],
                    colorB = buttonTheme.pressedColor[3],
                    colorA = buttonTheme.pressedColor[4]
                })
                
                if self.onClick then
                    self.onClick()
                end
                return true
            end
            return false
        end,
        
        release = function(self)
            if self.pressed then
                self.pressed = false
                local targetColor = self.hover and buttonTheme.hoverColor or buttonTheme.color
                luis.flux.to(self, buttonTheme.transitionDuration, {
                    elevation = self.hover and buttonTheme.elevationHover or buttonTheme.elevation,
                    colorR = targetColor[1],
                    colorG = targetColor[2],
                    colorB = targetColor[3],
                    colorA = targetColor[4]
                })
            end
        end
    }
    
    return button
end

return button
