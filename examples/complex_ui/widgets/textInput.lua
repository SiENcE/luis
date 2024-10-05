local utf8 = require("utf8")
local utils = require("examples.3rdparty.utils")
local Vector2D = require("examples.3rdparty.vector")
local decorators = require("examples.3rdparty.decorators")

local pointInRect = utils.pointInRect
local utf8_sub = utils.utf8_sub

local textInput = {}

local luis  -- This will store the reference to the core library
function textInput.setluis(luisObj)
    luis = luisObj
end

-- TextInput
function textInput.new(width, height, placeholder, onChange, row, col, customTheme)
    local textInputTheme = customTheme or luis.theme.textinput
    local input = {
        type = "TextInput",
        text = "",
        placeholder = placeholder or "",
        width = width * luis.gridSize,
        height = height * luis.gridSize,
		onChange = onChange,
        position = Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        cursorPos = 0,
        active = false,
        blinkTimer = 0,
        showCursor = true,
        focused = false,
        focusable = true,  -- Make the button focusable
		theme = textInputTheme,
		decorator = nil,

        update = function(self, mx, my, dt)
            if self.active then
                self.blinkTimer = self.blinkTimer + dt
                if self.blinkTimer >= 0.6 then
                    self.showCursor = not self.showCursor
                    self.blinkTimer = 0
                end
            else
                self.showCursor = false
            end
        end,

        defaultDraw = function(self)
            love.graphics.setColor(textInputTheme.backgroundColor)
            love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height)
            
            love.graphics.setColor(textInputTheme.borderColor)
            love.graphics.rectangle("line", self.position.x, self.position.y, self.width, self.height)

            love.graphics.setColor(textInputTheme.textColor)
            local displayText = self.text
            if #displayText == 0 and not self.active then
                love.graphics.setColor(0.5, 0.5, 0.5)
                displayText = self.placeholder
            end
			love.graphics.setColor(textInputTheme.textColor)
            love.graphics.printf(displayText, self.position.x + textInputTheme.padding, self.position.y + (self.height - luis.theme.text.font:getHeight()) / 2, self.width - textInputTheme.padding * 2, "left")

            if self.active and self.showCursor then
                local cursorX = self.position.x + textInputTheme.padding + luis.theme.text.font:getWidth(utf8_sub(self.text, 1, self.cursorPos))
                love.graphics.setColor(textInputTheme.cursorColor)
                love.graphics.line(cursorX, self.position.y + textInputTheme.padding, cursorX, self.position.y + self.height - textInputTheme.padding)
            end

            -- Draw focus indicator
            if self.focused then
                love.graphics.setColor(1, 1, 1, 0.5)
                love.graphics.rectangle("line", self.position.x - 2, self.position.y - 2, self.width + 4, self.height + 4, textInputTheme.cornerRadius)
            end
        end,

		-- Draw method that can use a decorator
		draw = function(self)
			if self.decorator then
				self.decorator:draw()
			else
				self:defaultDraw()
			end
		end,

		-- Method to set a decorator
		setDecorator = function(self, decoratorType, ...)
			self.decorator = decorators[decoratorType].new(self, ...)
		end,

        click = function(self, x, y, button, istouch)
            if pointInRect(x, y, self.position.x, self.position.y, self.width, self.height) then
                self.active = true
                local clickX = x - self.position.x - textInputTheme.padding
                self.cursorPos = utf8.len(self.text)
                for i = 1, utf8.len(self.text) do
                    if luis.theme.text.font:getWidth(utf8_sub(self.text, 1, i)) > clickX then
                        self.cursorPos = i - 1
                        break
                    end
                end
                return true
            else
                self.active = false
            end
            return false
        end,

        textinput = function(self, text)
            if self.active then
                local newText = utf8_sub(self.text, 1, self.cursorPos) .. text .. utf8_sub(self.text, self.cursorPos + 1)
                if luis.theme.text.font:getWidth(newText) <= self.width - textInputTheme.padding * 2 then
                    self.text = newText
                    self.cursorPos = self.cursorPos + utf8.len(text)
                end
            end
        end,

        keypressed = function(self, key)
            if self.active then
				if key == "return" then
					if self.onChange then
						self.onChange(self.text)
					end
                elseif key == "backspace" then
                    if self.cursorPos > 0 then
                        local byteoffset = utf8.offset(self.text, -1, utf8.offset(self.text, self.cursorPos + 1))
                        self.text = string.sub(self.text, 1, byteoffset - 1) .. string.sub(self.text, utf8.offset(self.text, self.cursorPos + 1))
                        self.cursorPos = self.cursorPos - 1
                    end
                elseif key == "delete" then
                    if self.cursorPos < utf8.len(self.text) then
                        local nextCharStart = utf8.offset(self.text, self.cursorPos + 1)
                        local nextCharEnd = utf8.offset(self.text, self.cursorPos + 2)
                        if nextCharEnd then
                            self.text = string.sub(self.text, 1, nextCharStart - 1) .. string.sub(self.text, nextCharEnd)
                        else
                            self.text = string.sub(self.text, 1, nextCharStart - 1)
                        end
                    end
                elseif key == "left" then
                    self.cursorPos = math.max(0, self.cursorPos - 1)
                elseif key == "right" then
                    self.cursorPos = math.min(utf8.len(self.text), self.cursorPos + 1)
                end
                self.blinkTimer = 0
                self.showCursor = true
            end
        end,

        setText = function(self, newText)
            if luis.theme.text.font:getWidth(newText) <= self.width - textInputTheme.padding * 2 then
                self.text = newText
                self.cursorPos = utf8.len(newText)
            end
        end,
		
		getText = function(self)
			return self.text
		end
    }

    return input
end

return textInput
