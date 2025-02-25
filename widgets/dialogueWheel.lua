local utils = require("luis.3rdparty.utils")
local Vector2D = require("luis.3rdparty.vector")
local decorators = require("luis.3rdparty.decorators")

local dialogueWheel = {}

local luis  -- This will store the reference to the core library
function dialogueWheel.setluis(luisObj)
    luis = luisObj
end

-- Helper function to check if a point is inside a sector
local function pointInSector(px, py, cx, cy, radius, startAngle, endAngle)
    local dx = px - cx
    local dy = py - cy
    local distance = math.sqrt(dx * dx + dy * dy)
    
    if distance > radius then return false end
    
    local angle = math.atan2(dy, dx)
    if angle < 0 then angle = angle + 2 * math.pi end
    
    if startAngle > endAngle then
        return angle >= startAngle or angle <= endAngle
    else
        return angle >= startAngle and angle <= endAngle
    end
end

-- Helper function to get segment angles
local function getSegmentAngles2(index, totalSegments)
    local segmentSize = 2 * math.pi / totalSegments
    local startAngle = (index - 1) * segmentSize - math.pi/2 -- Start from top
    local endAngle = startAngle + segmentSize
    return startAngle, endAngle
end

local function getSegmentAngles(index, totalSegments)
    local segmentSize = 2 * math.pi / totalSegments
    local startAngle = (index - 1) * segmentSize - math.pi/2 -- Start from top
    local endAngle = startAngle + segmentSize
    
    -- Normalize both angles to [0, 2π] range
    if startAngle < 0 then startAngle = startAngle + 2 * math.pi end
    if endAngle < 0 then endAngle = endAngle + 2 * math.pi end
    
    return startAngle, endAngle
end

function dialogueWheel.new(options, width, height, onChange, row, col, customTheme)
    assert(#options > 0, "DialogueWheel requires at least one option")
    
    local wheelTheme = customTheme or luis.theme.dialogueWheel or {
        backgroundColor = {0.2, 0.2, 0.2, 0.8},
        highlightColor = {0.4, 0.4, 0.8, 0.9},
        disabledColor = {0.3, 0.3, 0.3, 0.8},
        textColor = {1, 1, 1, 1},
		font = love.graphics.newFont(12, "normal"),
        disabledTextColor = {0.5, 0.5, 0.5, 1},
        selectedColor = {0.6, 0.6, 1, 0.9},
        focusColor = {1, 1, 1, 0.5}
    }

    -- Convert options to a more detailed format if they're just strings
    local processedOptions = {}
    for i, opt in ipairs(options) do
        if type(opt) == "string" then
            processedOptions[i] = {
                text = opt,
                enabled = true
            }
        else
            processedOptions[i] = opt
        end
    end

    return {
        type = "DialogueWheel",
        options = processedOptions,
        value = nil,	-- selected Index
        hoveredIndex = nil,
        width = width * luis.gridSize,
        height = height * luis.gridSize,
        onChange = onChange,
        focused = false,
        focusable = true,
        position = Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        theme = wheelTheme,
        decorator = nil,

        -- Get the center position of the wheel
        getCenter = function(self)
            return {
                x = self.position.x + self.width/2,
                y = self.position.y + self.height/2
            }
        end,

        -- Get the radius of the wheel
        getRadius = function(self)
            return math.min(self.width, self.height) / 2
        end,

        -- Find which segment the point is in
        getSegmentAt = function(self, x, y)
            local center = self:getCenter()
            local radius = self:getRadius()
            local totalSegments = #self.options
            
            for i = 1, totalSegments do
                local startAngle, endAngle = getSegmentAngles(i, totalSegments)
                if pointInSector(x, y, center.x, center.y, radius, startAngle, endAngle) then
                    return i
                end
            end
            return nil
        end,

        -- Method to update options
        setOptions = function(self, newOptions)
            -- Process new options
            local processedOptions = {}
            for i, opt in ipairs(newOptions) do
                if type(opt) == "string" then
                    processedOptions[i] = {
                        text = opt,
                        enabled = true
                    }
                else
                    processedOptions[i] = opt
                end
            end
            
            self.options = processedOptions
            -- Reset selection if it's no longer valid
            if self.value and self.value > #processedOptions then
                self.value = nil
            end
            if self.hoveredIndex and self.hoveredIndex > #processedOptions then
                self.hoveredIndex = nil
            end
        end,

        -- Method to enable/disable a segment
        setSegmentEnabled = function(self, index, enabled)
            if self.options[index] then
                self.options[index].enabled = enabled
                -- Reset selection if disabled segment was selected
                if not enabled and self.value == index then
                    self.value = nil
                end
                if not enabled and self.hoveredIndex == index then
                    self.hoveredIndex = nil
                end
            end
        end,

        -- Get next enabled segment in a direction
        getNextEnabledSegment = function(self, currentIndex, direction)
            local totalSegments = #self.options
            local steps = 0
            local index = currentIndex
            
            while steps < totalSegments do
                index = index + direction
                if index > totalSegments then index = 1
                elseif index < 1 then index = totalSegments end
                
                if self.options[index].enabled then
                    return index
                end
                steps = steps + 1
            end
            return nil
        end,

        update = function(self, mx, my)
            if not self.focused then return end
            
            -- Update hovered segment based on mouse position
            local newHoveredIndex = self:getSegmentAt(mx, my)
            if newHoveredIndex and self.options[newHoveredIndex].enabled then
                self.hoveredIndex = newHoveredIndex
            else
                self.hoveredIndex = nil
            end
            
            -- Handle gamepad input if mouse isn't being used
            if self.focused and not self.hoveredIndex then
                local joystick = luis.getActiveJoystick(1)
                if joystick then
                    local x = luis.getJoystickAxis(1, "leftx")
                    local y = luis.getJoystickAxis(1, "lefty")
                    
                    if math.abs(x) > 0.3 or math.abs(y) > 0.3 then
                        local angle = math.atan2(y, x)
                        if angle < 0 then angle = angle + 2 * math.pi end
                        local totalSegments = #self.options
                        local rawIndex = math.floor((angle + math.pi/totalSegments) / (2*math.pi/totalSegments)) % totalSegments + 1
                        
                        -- Only highlight if the segment is enabled
                        if self.options[rawIndex].enabled then
                            self.hoveredIndex = rawIndex
                        else
                            -- Find next enabled segment in the direction of movement
                            self.hoveredIndex = self:getNextEnabledSegment(rawIndex, 1)
                        end
                    end
                end
            end
        end,

        defaultDraw = function(self)
            local center = self:getCenter()
            local radius = self:getRadius()
            local totalSegments = #self.options
            
            -- Draw segments
            for i = 1, totalSegments do
                local startAngle, endAngle = getSegmentAngles2(i, totalSegments)
                local option = self.options[i]
                
                -- Choose color based on state
                if not option.enabled then
                    love.graphics.setColor(self.theme.disabledColor)
                elseif i == self.value then
                    love.graphics.setColor(self.theme.selectedColor)
                elseif i == self.hoveredIndex then
                    love.graphics.setColor(self.theme.highlightColor)
                else
                    love.graphics.setColor(self.theme.backgroundColor)
                end
                
                -- Draw segment
                love.graphics.arc("fill", center.x, center.y, radius, startAngle, endAngle)
                
                -- Draw text
                if option.enabled then
                    love.graphics.setColor(self.theme.textColor)
                else
                    love.graphics.setColor(self.theme.disabledTextColor)
                end
                
                local textAngle = (startAngle + endAngle) / 2
                local textRadius = radius * 0.7
                local textX = center.x + math.cos(textAngle) * textRadius
                local textY = center.y + math.sin(textAngle) * textRadius
                
                -- Rotate and draw text
				love.graphics.setColor(self.theme.textColor)
				love.graphics.setFont(self.theme.font)

                love.graphics.push()
                love.graphics.translate(textX, textY)
                love.graphics.rotate(textAngle + math.pi/2)
                love.graphics.printf(option.text, -50, -10, 100, "center")
                love.graphics.pop()
            end
            
            -- Draw focus indicator
            if self.focused then
                love.graphics.setColor(self.theme.focusColor)
                love.graphics.circle("line", center.x, center.y, radius + 2)
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

        click = function(self, x, y, button, istouch, presses)
            local selectedSegment = self:getSegmentAt(x, y)
            if selectedSegment and self.options[selectedSegment].enabled then
                self.value = selectedSegment
                if self.onChange then
                    self.onChange(self.options[selectedSegment].text, selectedSegment)
                end
                return true
            end
            return false
        end,

        setValue = function(self, value)
            self.value = value
        end,

        -- Joystick-specific functions
        gamepadpressed = function(self, id, button)
            if not self.focused then return false end
            
            if button == 'a' and self.hoveredIndex and self.options[self.hoveredIndex].enabled then
                self.value = self.hoveredIndex
                if self.onChange then
                    self.onChange(self.options[self.hoveredIndex].text, self.hoveredIndex)
                end
                return true
            end
            return false
        end,
    }
end

return dialogueWheel