local utf8 = require("utf8")
local utils = require("luis.3rdparty.utils")
local Vector2D = require("luis.3rdparty.vector")
local decorators = require("luis.3rdparty.decorators")

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
        value = "",
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
        focusable = true,  -- Make it focusable
		theme = textInputTheme,
		decorator = nil,

        update = function(self, mx, my, dt)
            if self.active then
                self.blinkTimer = self.blinkTimer + dt
                if self.blinkTimer >= 0.53 then
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
            local displayText = self.value
            if #displayText == 0 and not self.active then
                love.graphics.setColor(0.5, 0.5, 0.5)
                displayText = self.placeholder
            end
			love.graphics.setColor(textInputTheme.textColor)
            love.graphics.printf(displayText, self.position.x + textInputTheme.padding, self.position.y + (self.height - luis.theme.text.font:getHeight()) / 2, self.width - textInputTheme.padding * 2, "left")

            if self.active and self.showCursor then
                local cursorX = self.position.x + textInputTheme.padding + luis.theme.text.font:getWidth(utf8_sub(self.value, 1, self.cursorPos))
                love.graphics.setColor(textInputTheme.cursorColor)
                love.graphics.line(cursorX, self.position.y + textInputTheme.padding, cursorX, self.position.y + self.height - textInputTheme.padding)
            end

            -- Draw focus indicator
            if self.focused then
                love.graphics.setColor(1, 1, 1, 0.5)
                love.graphics.rectangle("line", self.position.x - 2, self.position.y - 2, self.width + 4, self.height + 4, textInputTheme.cornerRadius)
            end

			if luis.showElementOutlines then
				love.graphics.print("Active: " .. tostring(self.active), self.position.x, self.position.y-luis.gridSize/2)
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

		-- Note: It's a common problem in UI frameworks where elements like text inputs and dropdowns need to deactivate when clicking elsewhere.
		-- Implement this if you want that your widgets succeed to deactivate properly.
		onGlobalClick = function(self, x, y, button, istouch, presses)
			if not utils.pointInRect(x, y, self.position.x, self.position.y, self.width, self.height) then
				self.active = false
			end
		end,

        click = function(self, x, y, button, istouch, presses)
            if pointInRect(x, y, self.position.x, self.position.y, self.width, self.height) then
                self.active = true
                local clickX = x - self.position.x - textInputTheme.padding
                self.cursorPos = utf8.len(self.value)
                for i = 1, utf8.len(self.value) do
                    if luis.theme.text.font:getWidth(utf8_sub(self.value, 1, i)) > clickX then
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
--[[
        textinput = function(self, value)
			--print("textinput.textinput = function", value )
            if self.active then
                local newText = utf8_sub(self.value, 1, self.cursorPos) .. value .. utf8_sub(self.value, self.cursorPos + 1)
                if luis.theme.text.font:getWidth(newText) <= self.width - textInputTheme.padding * 2 then
                    self.value = newText
                    self.cursorPos = self.cursorPos + utf8.len(value)
                end
            end
        end,
]]--
		textinput = function(self, value)
			if self.active then
				local before = utf8_sub(self.value, 1, self.cursorPos)
				local after = utf8_sub(self.value, self.cursorPos + 1)
				local newText = before .. value .. after
				if luis.theme.text.font:getWidth(newText) <= self.width - textInputTheme.padding * 2 then
					self.value = newText
					self.cursorPos = self.cursorPos + utf8.len(value)
				end
			end
		end,

        keypressed = function(self, key, scancode, isrepeat )
            if self.active then
				if key == "return" or key == "kpenter" then
					if self.onChange then
						self.onChange(self.value)
					end
                elseif key == "backspace" then
                    if self.cursorPos > 0 then
                        local byteoffset = utf8.offset(self.value, -1, utf8.offset(self.value, self.cursorPos + 1))
                        self.value = string.sub(self.value, 1, byteoffset - 1) .. string.sub(self.value, utf8.offset(self.value, self.cursorPos + 1))
                        self.cursorPos = self.cursorPos - 1
                    end
                elseif key == "delete" then
                    if self.cursorPos < utf8.len(self.value) then
                        local nextCharStart = utf8.offset(self.value, self.cursorPos + 1)
                        local nextCharEnd = utf8.offset(self.value, self.cursorPos + 2)
                        if nextCharEnd then
                            self.value = string.sub(self.value, 1, nextCharStart - 1) .. string.sub(self.value, nextCharEnd)
                        else
                            self.value = string.sub(self.value, 1, nextCharStart - 1)
                        end
                    end
                elseif key == "left" then
                    self.cursorPos = math.max(0, self.cursorPos - 1)
                elseif key == "right" then
                    self.cursorPos = math.min(utf8.len(self.value), self.cursorPos + 1)
                end
                self.blinkTimer = 0
                self.showCursor = true
            end
        end,

        keyreleased = function(self, key, scancode )
			--print("textinput.keyreleased = function", key, scancode, isrepeat )
		end,

        setText = function(self, newText)
            if luis.theme.text.font:getWidth(newText) <= self.width - textInputTheme.padding * 2 then
                self.value = newText
                self.cursorPos = utf8.len(newText)
            end
        end,
		
		getText = function(self)
			return self.value
		end
    }

    return input
end

return textInput
