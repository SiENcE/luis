local utils = require("luis.3rdparty.utils")
local Vector2D = require("luis.3rdparty.vector")
local decorators = require("luis.3rdparty.decorators")

local pointInRect = utils.pointInRect

local radioButton = {}

local luis  -- This will store the reference to the core library
function radioButton.setluis(luisObj)
    luis = luisObj
end

function radioButton.new(group, value, size, onChange, row, col, customTheme)
    local radioTheme = customTheme or luis.theme.radiobutton
    local button = {
        type = "RadioButton",
        group = group,
        value = value,
        width = size * luis.gridSize,
        height = size * luis.gridSize,
        hover = false,
        focused = false,
        focusable = true,
        position = Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
		theme = radioTheme,
		decorator = nil,

        update = function(self, mx, my)
            local wasHovered = self.hover
            self.hover = pointInRect(mx, my, self.position.x, self.position.y, self.width, self.height)
            
            -- Check for joystick/gamepad input when focused
            if self.focused then
                if luis.joystickJustPressed(1, 'a') or luis.joystickJustPressed(1, 'dpright') then
                    self:click()
                end
            end
        end,
        
        defaultDraw = function(self)
            -- Draw the radio button circle
            love.graphics.setColor(self.theme.circleColor)
            love.graphics.circle("line", self.position.x + self.width/2, self.position.y + self.height/2, self.width/2)
            
            -- If value, draw the inner dot
            if self.value then
                love.graphics.setColor(self.theme.dotColor)
                love.graphics.circle("fill", self.position.x + self.width/2, self.position.y + self.height/2, self.width/4)
            end
            
            -- Draw focus indicator
            if self.focused then
                love.graphics.setColor(1, 1, 1, 0.5)
                love.graphics.rectangle("line", self.position.x - 2, self.position.y - 2, self.width + 4, self.height + 4)
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
			if (self.focused or pointInRect(x, y, self.position.x, self.position.y, self.width, self.height)) and not self.value then
					-- Deactivate all other radioButtons in the same group
					for _, element in ipairs(luis.elements[luis.currentLayer]) do
						if element.type == "RadioButton" and element.group == self.group then
							element.value = false
						end
					end
					
				-- Check this radio button
				self.value = true
				
				-- Trigger the onChange callback if it exists
				if self.onChange then
					self.onChange(self.value)
				end
				
				return true
			end
        end,
        
        setValue = function(self, isValue)
            if isValue and not self.value then
                self:click()
            elseif not isValue and self.value then
                self.value = false
            end
        end,
        
        isValue = function(self)
            return self.value
        end,
        
        getValue = function(self)
            return self.value
        end,
        
        setOnChange = function(self, callback)
            self.onChange = callback
        end,
        
        -- Handle joystick/gamepad navigation
        updateFocus = function(self, jx, jy)
            -- Handle left/right navigation within the group
            if luis.joystickJustPressed(1, 'dpleft') or luis.joystickJustPressed(1, 'dpright') then
                local currentIndex, groupButtons = self:getGroupInfo()
                local newIndex = luis.joystickJustPressed(1, 'dpleft') and 
                    ((currentIndex - 2) % #groupButtons) + 1 or 
                    (currentIndex % #groupButtons) + 1
                luis.currentFocus = groupButtons[newIndex]
            end
        end,
        
        -- Helper function to get group information
        getGroupInfo = function(self)
            local groupButtons = {}
            local currentIndex = 1
            for layerName, elements in pairs(luis.elements) do
                for i, element in ipairs(elements) do
                    if element.type == "RadioButton" and element.group == self.group then
                        table.insert(groupButtons, element)
                        if element == self then
                            currentIndex = #groupButtons
                        end
                    end
                end
            end
            return currentIndex, groupButtons
        end
    }
    
    return button
end

return radioButton
