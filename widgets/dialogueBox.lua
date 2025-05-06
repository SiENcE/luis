local utf8 = require("utf8")
local utils = require("luis.3rdparty.utils")
local Vector2D = require("luis.3rdparty.vector")
local decorators = require("luis.3rdparty.decorators")

local dialogueBox = {}

local luis  -- store the reference to the core library
function dialogueBox.setluis(luisObj)
    luis = luisObj
end

-- Helper function for drawing rounded rectangle with shadow
local function drawRoundedRectangleWithShadow(x, y, width, height, radius, color, shadowColor, shadowOffset)
    -- Draw shadow
    love.graphics.setColor(shadowColor)
    love.graphics.rectangle("fill", x + shadowOffset, y + shadowOffset, width, height, radius, radius)
    
    -- Draw main rectangle
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, width, height, radius, radius)
    
    -- Draw border (slightly darker than main color)
    love.graphics.setColor(color[1] * 0.8, color[2] * 0.8, color[3] * 0.8, color[4])
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height, radius, radius)
end

-- Function to safely get string length, handling nil and non-string values
local function safeLen(str)
    if type(str) ~= "string" then
        return 0
    end
    return utf8.len(str)
end

-- Function to ensure a value is a string
local function ensureString(value)
    if value == nil then
        return ""
    elseif type(value) ~= "string" then
        return tostring(value)
    end
    return value
end

-- Safe substring function that handles nil and non-string values
local function safeSubstring(str, startPos, endPos)
    if type(str) ~= "string" then
        return ""
    end
    return string.sub(str, startPos, endPos)
end

-- DialogueBox widget
function dialogueBox.new(text, speakerName, width, height, row, col, customTheme)
    -- Ensure all parameters are valid
    width = tonumber(width) or 20  -- Default width if nil or not a number
    height = tonumber(height) or 5  -- Default height if nil or not a number
    row = tonumber(row) or 1
    col = tonumber(col) or 1
    
    -- Convert text and speaker name to strings, handling nil values
    text = ensureString(text)
    speakerName = ensureString(speakerName)
    
    local dialogueTheme = customTheme or {
        boxColor = {0.90, 0.82, 0.55, 1},          -- Beige/tan color for main box
        nameBoxColor = {0.90, 0.82, 0.55, 1},      -- Same color for name box
        textColor = {0.2, 0.2, 0.2, 1},            -- Dark text
        borderRadius = 20,                          -- Rounded corners
        shadowColor = {0.1, 0.1, 0.1, 0.5},         -- Dark shadow
        shadowOffset = 4,                           -- Shadow size
        padding = 20,                                -- Inner padding
        font = love.graphics.getFont() or love.graphics.newFont(16),
        nameFont = love.graphics.getFont() or love.graphics.newFont(18),
        indicatorColor = {0.2, 0.2, 0.2, 0.8},      -- Indicator triangle color
        textSpeed = 50,                             -- Characters per second
        fadeInDuration = 0.2,                       -- Fade-in time in seconds
        fadeOutDuration = 0.2                       -- Fade-out time in seconds
    }
    
    -- Calculate sizes
    local boxWidth = width * luis.gridSize
    local boxHeight = height * luis.gridSize
    
    return {
        type = "DialogueBox",
        text = text,
        speakerName = speakerName,
        fullText = text,
        width = boxWidth,
        height = boxHeight,
        position = Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        theme = dialogueTheme,
        decorator = nil,
        isComplete = false,
        charIndex = 0,
        lastCharTime = love.timer.getTime(),
        active = true,
        opacity = 1,
        fadeState = "none", -- "in", "out", "none"
        fadeTimer = 0,
        
        -- Update the dialogue box (text animation, etc.)
        update = function(self, mx, my, dt)
            if not self.active then return end
            
            -- Handle text animation
            if not self.isComplete then
                local timeNow = love.timer.getTime()
                local timeDiff = timeNow - self.lastCharTime
                
                if timeDiff > (1 / self.theme.textSpeed) then
                    self.charIndex = self.charIndex + 1
                    self.lastCharTime = timeNow
                    
                    -- Safely get the text length
                    local textLength = safeLen(self.fullText)
                    
                    if self.charIndex >= textLength then
                        self.isComplete = true
                        self.charIndex = textLength
                    end
                end
            end
            
            -- Handle fading
            if self.fadeState == "in" then
                self.fadeTimer = self.fadeTimer + dt
                self.opacity = math.min(1, self.fadeTimer / self.theme.fadeInDuration)
                
                if self.opacity >= 1 then
                    self.fadeState = "none"
                    self.opacity = 1
                end
            elseif self.fadeState == "out" then
                self.fadeTimer = self.fadeTimer + dt
                self.opacity = math.max(0, 1 - (self.fadeTimer / self.theme.fadeOutDuration))
                
                if self.opacity <= 0 then
                    self.fadeState = "none"
                    self.active = false
                end
            end
        end,
        
        -- The default draw method that will be used when no decorator is applied
        defaultDraw = function(self)
            if not self.active then return end
            
            -- Calculate nameTag width based on text
            love.graphics.setFont(self.theme.nameFont)
            local nameWidth = self.theme.nameFont:getWidth(self.speakerName) + self.theme.padding * 2
            nameWidth = math.max(nameWidth, 80) -- Minimum nameTag width
            
            -- Draw main dialogue box with shadow
            drawRoundedRectangleWithShadow(
                self.position.x, 
                self.position.y, 
                self.width, 
                self.height, 
                self.theme.borderRadius,
                {self.theme.boxColor[1], self.theme.boxColor[2], self.theme.boxColor[3], self.theme.boxColor[4] * self.opacity},
                {self.theme.shadowColor[1], self.theme.shadowColor[2], self.theme.shadowColor[3], self.theme.shadowColor[4] * self.opacity},
                self.theme.shadowOffset
            )
            
            -- Only draw name tag if there's a speaker name
            if self.speakerName and self.speakerName ~= "" then
                -- Draw name tag
                drawRoundedRectangleWithShadow(
                    self.position.x + self.theme.padding, 
                    self.position.y - self.theme.nameFont:getHeight() / 1.3, 
                    nameWidth, 
                    self.theme.nameFont:getHeight() * 1.3, 
                    self.theme.borderRadius / 2,
                    {self.theme.nameBoxColor[1], self.theme.nameBoxColor[2], self.theme.nameBoxColor[3], self.theme.nameBoxColor[4] * self.opacity},
                    {self.theme.shadowColor[1], self.theme.shadowColor[2], self.theme.shadowColor[3], self.theme.shadowColor[4] * self.opacity},
                    self.theme.shadowOffset / 2
                )
                
                -- Draw speaker name
                love.graphics.setColor(self.theme.textColor[1], self.theme.textColor[2], self.theme.textColor[3], self.theme.textColor[4] * self.opacity)
                love.graphics.setFont(self.theme.nameFont)
                love.graphics.printf(
                    self.speakerName, 
                    self.position.x + self.theme.padding + self.theme.padding/2, 
                    self.position.y - self.theme.nameFont:getHeight() / 1.5, 
                    nameWidth - self.theme.padding, 
                    "center"
                )
            end
            
            -- Draw dialogue text
            love.graphics.setColor(self.theme.textColor[1], self.theme.textColor[2], self.theme.textColor[3], self.theme.textColor[4] * self.opacity)
            love.graphics.setFont(self.theme.font)
            
            local displayText = ""
            if self.charIndex > 0 then
                displayText = safeSubstring(self.fullText, 1, self.charIndex)
            end
            
            love.graphics.printf(
                displayText, 
                self.position.x + self.theme.padding, 
                self.position.y + self.theme.padding, 
                self.width - (self.theme.padding * 2), 
                "left"
            )
            
            -- Draw "continue" indicator when text is complete
            if self.isComplete then
                love.graphics.setColor(self.theme.indicatorColor[1], self.theme.indicatorColor[2], self.theme.indicatorColor[3], self.theme.indicatorColor[4] * self.opacity)
                
                local indicatorX = self.position.x + self.width - self.theme.padding - 15
                local indicatorY = self.position.y + self.height - self.theme.padding - 15
                
                -- Animate the indicator with a subtle bounce
                local bounce = math.sin(love.timer.getTime() * 5) * 2
                
                -- Draw a simple triangle indicator
                love.graphics.polygon(
                    "fill", 
                    indicatorX, indicatorY + bounce, 
                    indicatorX + 15, indicatorY + 7.5 + bounce, 
                    indicatorX, indicatorY + 15 + bounce
                )
            end
        end,
        
        -- Proper draw method that supports the decorator pattern
        draw = function(self)
            if not self.active then return end
            
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
        
        -- Handle click events (advance or dismiss dialogue)
        click = function(self, x, y, button, istouch, presses)
            if not self.active then return false end
            
            if utils.pointInRect(x, y, self.position.x, self.position.y, self.width, self.height) then
                if not self.isComplete then
                    -- Skip to end of text if clicked before animation completes
                    self.charIndex = safeLen(self.fullText)
                    self.isComplete = true
                    return true
                else
                    -- Don't hide automatically - let the application handle this
                    return true
                end
            end
            return false
        end,
        
        -- Method to set new dialogue text
        setText = function(self, text, speakerName)
            self.fullText = ensureString(text) or self.fullText
            if speakerName then self.speakerName = ensureString(speakerName) end
            self.charIndex = 0
            self.isComplete = false
            self.lastCharTime = love.timer.getTime()
        end,
        
        -- Method to immediately show all text
        showFullText = function(self)
            self.charIndex = safeLen(self.fullText)
            self.isComplete = true
        end,
        
        -- Animation methods
        
        -- Start fade-in animation
        fadeIn = function(self)
            self.active = true  -- Ensure it's active
            self.fadeState = "in"
            self.fadeTimer = 0
        end,
        
        -- Start fade-out animation
        fadeOut = function(self)
            self.fadeState = "out"
            self.fadeTimer = 0
        end,
        
        -- Set visibility immediately without animation
        setVisible = function(self, visible)
            self.active = visible
            self.opacity = visible and 1 or 0
            self.fadeState = "none"
        end,
        
        -- Show immediately without animation (alias for setVisible(true))
        show = function(self)
            self.active = true
            self.opacity = 1
            self.fadeState = "none"
        end,
        
        -- Hide immediately without animation (alias for setVisible(false))
        hide = function(self)
            self.active = false
            self.opacity = 0
            self.fadeState = "none"
        end,
        
        -- Method for gamepad support
        gamepadpressed = function(self, id, button)
            if not self.active then return false end
            
            if button == 'a' or button == 'b' then
                if not self.isComplete then
                    -- Skip to end of text
                    self.charIndex = safeLen(self.fullText)
                    self.isComplete = true
                    return true
                else
                    -- Don't hide automatically - let the application handle this
                    return true
                end
            end
            return false
        end,
        
        -- Set text speed
        setTextSpeed = function(self, charsPerSecond)
            self.theme.textSpeed = charsPerSecond
        end,
        
        -- Set visual theme properties
        setTheme = function(self, newTheme)
            for key, value in pairs(newTheme) do
                self.theme[key] = value
            end
        end
    }
end

return dialogueBox
