local utils = require("luis.3rdparty.utils")
local Vector2D = require("luis.3rdparty.vector")
local decorators = require("luis.3rdparty.decorators")

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
function button.new(text, width, height, onClick, onRelease, row, col, customTheme)
    local buttonTheme = customTheme or luis.theme.button
    return {
        type = "Button",
        text = text,
        width = width * luis.gridSize,
        height = height * luis.gridSize,
        onClick = onClick,
        onRelease = onRelease,
        hover = false,
        pressed = false,
        focused = false,
        focusable = true,  -- Make the button focusable
        position = Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        colorR = buttonTheme.color[1],
        colorG = buttonTheme.color[2],
        colorB = buttonTheme.color[3],
        colorA = buttonTheme.color[4],
        elevation = buttonTheme.elevation,
		theme = buttonTheme,
		decorator = nil,

        update = function(self, mx, my)
            local wasHovered = self.hover
            self.hover = pointInRect(mx, my, self.position.x, self.position.y, self.width, self.height)

            -- Check for joystick button press when focused
--            if self.focused and luis.joystickJustPressed(1, 'a') then
--                self:click()
--            elseif self.pressed and not luis.isJoystickPressed(1, 'a') then
--                self:release()
--            end

            if (self.hover and not wasHovered) or (self.focused and not self.hover) then
                luis.flux.to(self, buttonTheme.transitionDuration, {
                    elevation = buttonTheme.elevationHover,
                    colorR = buttonTheme.hoverColor[1],
                    colorG = buttonTheme.hoverColor[2],
                    colorB = buttonTheme.hoverColor[3],
                    colorA = buttonTheme.hoverColor[4]
                })
            elseif (not self.hover and wasHovered) and not self.focused then
                luis.flux.to(self, buttonTheme.transitionDuration, {
                    elevation = buttonTheme.elevation,
                    colorR = buttonTheme.color[1],
                    colorG = buttonTheme.color[2],
                    colorB = buttonTheme.color[3],
                    colorA = buttonTheme.color[4]
                })
            end
        end,

        defaultDraw = function(self)
            drawElevatedRectangle(self.position.x, self.position.y, self.width, self.height, {self.colorR, self.colorG, self.colorB, self.colorA}, self.elevation, buttonTheme.cornerRadius)

            -- Draw text
            love.graphics.setColor(buttonTheme.textColor)
			love.graphics.setFont(luis.theme.text.font)
            love.graphics.printf(self.text, self.position.x, self.position.y + (self.height - luis.theme.text.font:getHeight()) / 2, self.width, buttonTheme.align)
            
            -- Draw focus indicator
            if self.focused then
                love.graphics.setColor(1, 1, 1, 0.5)
                love.graphics.rectangle("line", self.position.x - 2, self.position.y - 2, self.width + 4, self.height + 4, buttonTheme.cornerRadius + 2)
            end
        end,

		-- Draw method that can use a decorator
		draw = function(self)
			if self.decorator then
				self.decorator:draw(self)
			else
				self:defaultDraw()
			end
		end,

		-- Method to set a decorator
		setDecorator = function(self, decoratorType, ...)
			self.decorator = decorators[decoratorType].new(self, ...)
		end,

        click = function(self, x, y, button, istouch, presses)
            if (self.hover or self.focused) and not self.pressed then
                self.pressed = true
                luis.flux.to(self, buttonTheme.transitionDuration, {
                    elevation = buttonTheme.elevationPressed,
                    colorR = buttonTheme.pressedColor[1],
                    colorG = buttonTheme.pressedColor[2],
                    colorB = buttonTheme.pressedColor[3],
                    colorA = buttonTheme.pressedColor[4]
                })
                
                if self.onClick then
                    self.onClick(self)
                end
                return true
            end
            return false
        end,
        
        release = function(self, x, y, button, istouch, presses)
            if self.pressed then
                self.pressed = false
                local targetColor = (self.hover or self.focused) and buttonTheme.hoverColor or buttonTheme.color
                luis.flux.to(self, buttonTheme.transitionDuration, {
                    elevation = (self.hover or self.focused) and buttonTheme.elevationHover or buttonTheme.elevation,
                    colorR = targetColor[1],
                    colorG = targetColor[2],
                    colorB = targetColor[3],
                    colorA = targetColor[4]
                })
                if self.onRelease then
                    self.onRelease(self)
                end
                return true
            end
            return false
        end,
        
        -- function for handling focus updates
        updateFocus = function(self, jx, jy)
            -- Handle any focus-specific updates here
            -- For buttons, we don't need to do anything special when focused
            -- This function is more useful for elements like sliders
        end,

        -- Joystick-specific functions
        gamepadpressed = function(self, id, button)
			--print("checkbox.gamepadpressed = function", id, button, self.focused )
            if button == 'a' and self.focused then
                return self:click()
            end
            return false
        end,
        
        gamepadreleased = function(self, id, button)
			--print("checkbox.gamepadreleased = function", id, button )
            if button == 'a' and self.pressed then
                return self:release()
            end
            return false
        end
    }
end

return button
