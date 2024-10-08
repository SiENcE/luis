local utf8 = require("utf8")
local utils = require("examples.3rdparty.utils")
local Vector2D = require("examples.3rdparty.vector")
local decorators = require("examples.3rdparty.decorators")

local pointInRect = utils.pointInRect
local utf8_sub = utils.utf8_sub

local textInputMultiLine = {}

local luis  -- This will store the reference to the core library
function textInputMultiLine.setluis(luisObj)
    luis = luisObj
end

-- textInputMultiLine
function textInputMultiLine.new(width, height, placeholder, onChange, row, col, customTheme)
    local textInputTheme = customTheme or luis.theme.textinput
    local input = {
        type = "TextInputMultiLine",
        lines = {""},
        placeholder = placeholder or "",
        width = width * luis.gridSize,
        height = height * luis.gridSize,
        onChange = onChange,
        position = Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        cursorX = 0,
        cursorY = 1,
        active = false,
        blinkTimer = 0,
        showCursor = true,
        focused = false,
        focusable = true,
        theme = textInputTheme,
        decorator = nil,
        scrollY = 0,

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
            local displayLines = self.lines
            if #displayLines == 1 and #displayLines[1] == 0 and not self.active then
                love.graphics.setColor(0.5, 0.5, 0.5)
                displayLines = {self.placeholder}
            end

            love.graphics.setScissor(self.position.x, self.position.y, self.width, self.height)
            for i, line in ipairs(displayLines) do
                love.graphics.printf(line, self.position.x + textInputTheme.padding, self.position.y + (i - 1 - self.scrollY) * luis.theme.text.font:getHeight() + textInputTheme.padding, self.width - textInputTheme.padding * 2, "left")
            end

            if self.active and self.showCursor then
                local cursorX = self.position.x + textInputTheme.padding + luis.theme.text.font:getWidth(utf8_sub(self.lines[self.cursorY], 1, self.cursorX))
                local cursorY = self.position.y + (self.cursorY - 1 - self.scrollY) * luis.theme.text.font:getHeight() + textInputTheme.padding
                love.graphics.setColor(textInputTheme.cursorColor)
                love.graphics.line(cursorX, cursorY, cursorX, cursorY + luis.theme.text.font:getHeight())
            end
            love.graphics.setScissor()

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

        setDecorator = function(self, decoratorType, ...)
            self.decorator = decorators[decoratorType].new(self, ...)
        end,

        click = function(self, x, y, button, istouch, presses)
            if pointInRect(x, y, self.position.x, self.position.y, self.width, self.height) then
                self.active = true
                local clickY = math.floor((y - self.position.y - textInputTheme.padding) / luis.theme.text.font:getHeight()) + 1 + self.scrollY
                self.cursorY = math.min(math.max(clickY, 1), #self.lines)
                local clickX = x - self.position.x - textInputTheme.padding
                self.cursorX = utf8.len(self.lines[self.cursorY])
                for i = 1, utf8.len(self.lines[self.cursorY]) do
                    if luis.theme.text.font:getWidth(utf8_sub(self.lines[self.cursorY], 1, i)) > clickX then
                        self.cursorX = i - 1
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
                local currentLine = self.lines[self.cursorY]
                local newLine = utf8_sub(currentLine, 1, self.cursorX) .. text .. utf8_sub(currentLine, self.cursorX + 1)
                self.lines[self.cursorY] = newLine
                self.cursorX = self.cursorX + utf8.len(text)
            end
        end,

        keypressed = function(self, key)
			print('textInputMultiLine.keypressed',key, self.active)
            if self.active then
				print('textInputMultiLine.keypressed press', key)
                if key == "return" or key == "kpenter" then
                    local currentLine = self.lines[self.cursorY]
                    local newLine = utf8_sub(currentLine, self.cursorX + 1)
                    self.lines[self.cursorY] = utf8_sub(currentLine, 1, self.cursorX)
                    table.insert(self.lines, self.cursorY + 1, newLine)
                    self.cursorY = self.cursorY + 1
                    self.cursorX = 0
                elseif key == "backspace" then
                    if self.cursorX > 0 then
                        local currentLine = self.lines[self.cursorY]
                        self.lines[self.cursorY] = utf8_sub(currentLine, 1, self.cursorX - 1) .. utf8_sub(currentLine, self.cursorX + 1)
                        self.cursorX = self.cursorX - 1
                    elseif self.cursorY > 1 then
                        local currentLine = self.lines[self.cursorY]
                        local prevLine = self.lines[self.cursorY - 1]
                        self.cursorX = utf8.len(prevLine)
                        self.lines[self.cursorY - 1] = prevLine .. currentLine
                        table.remove(self.lines, self.cursorY)
                        self.cursorY = self.cursorY - 1
                    end
                elseif key == "delete" then
                    local currentLine = self.lines[self.cursorY]
                    if self.cursorX < utf8.len(currentLine) then
                        self.lines[self.cursorY] = utf8_sub(currentLine, 1, self.cursorX) .. utf8_sub(currentLine, self.cursorX + 2)
                    elseif self.cursorY < #self.lines then
                        local nextLine = self.lines[self.cursorY + 1]
                        self.lines[self.cursorY] = currentLine .. nextLine
                        table.remove(self.lines, self.cursorY + 1)
                    end
                elseif key == "left" then
                    if self.cursorX > 0 then
                        self.cursorX = self.cursorX - 1
                    elseif self.cursorY > 1 then
                        self.cursorY = self.cursorY - 1
                        self.cursorX = utf8.len(self.lines[self.cursorY])
                    end
                elseif key == "right" then
                    local currentLine = self.lines[self.cursorY]
                    if self.cursorX < utf8.len(currentLine) then
                        self.cursorX = self.cursorX + 1
                    elseif self.cursorY < #self.lines then
                        self.cursorY = self.cursorY + 1
                        self.cursorX = 0
                    end
                elseif key == "up" then
                    if self.cursorY > 1 then
                        self.cursorY = self.cursorY - 1
                        self.cursorX = math.min(self.cursorX, utf8.len(self.lines[self.cursorY]))
                    end
                elseif key == "down" then
                    if self.cursorY < #self.lines then
                        self.cursorY = self.cursorY + 1
                        self.cursorX = math.min(self.cursorX, utf8.len(self.lines[self.cursorY]))
                    end
                end
                self.blinkTimer = 0
                self.showCursor = true
                self:updateScroll()
            end
        end,

        setText = function(self, newText)
            self.lines = {}
            for line in newText:gmatch("[^\r\n]+") do
                table.insert(self.lines, line)
            end
            if #self.lines == 0 then
                self.lines = {""}
            end
            self.cursorY = #self.lines
            self.cursorX = utf8.len(self.lines[self.cursorY])
            self:updateScroll()
        end,
        
        getText = function(self)
            return table.concat(self.lines, "\n")
        end,

        updateScroll = function(self)
            local visibleLines = math.floor((self.height - 2 * textInputTheme.padding) / luis.theme.text.font:getHeight())
            if self.cursorY - self.scrollY > visibleLines then
                self.scrollY = self.cursorY - visibleLines
            elseif self.cursorY - self.scrollY < 1 then
                self.scrollY = self.cursorY - 1
            end
        end
    }

    return input
end

return textInputMultiLine
