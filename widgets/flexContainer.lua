local utils = require("luis.3rdparty.utils")
local Vector2D = require("luis.3rdparty.vector")
local decorators = require("luis.3rdparty.decorators")

local flexContainer = {}

local luis  -- This stores the reference to the core library
function flexContainer.setluis(luisObj)
    luis = luisObj
end

-- FlexContainer
function flexContainer.new(width, height, row, col, customTheme, containerName)
    local containerTheme = customTheme or luis.theme.flexContainer
    local container = {
        type = "FlexContainer",
        name = containerName or "FlexContainer", -- optional, makes it better when handling multiple flexcontainers
        width = width * luis.gridSize,
        height = height * luis.gridSize,
        position = Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        children = {},
        padding = containerTheme.padding,
        isDragging = false,
        isResizing = false,
        dragOffset = Vector2D.new(0, 0),
        focused = false,
        focusable = true,  -- Make the button focusable
        focusableChildren = {},
        currentFocusIndex = 0,
        internalFocusActive = false,
        theme = containerTheme,
        decorator = nil,
        visible = true, -- New visibility property, default is visible
        
        -- Check if a child already exists in the container
        hasChild = function(self, child)
            -- First check if child is nil
            if not child then
                return false
            end
            
            -- Check direct reference match
            for _, existingChild in ipairs(self.children) do
                if existingChild == child then
                    return true
                end
            end
            
            -- Optionally check based on properties if child has unique identifiers
            -- like position, type, width, height, etc.
            for _, existingChild in ipairs(self.children) do
                if existingChild.type == child.type and
                   existingChild.position.x == child.position.x and
                   existingChild.position.y == child.position.y and
                   existingChild.width == child.width and
                   existingChild.height == child.height then
                    return true
                end
            end
            
            return false
        end,
        
        addChild = function(self, child)
            -- Check if child already exists before adding
            if not self:hasChild(child) then
                table.insert(self.children, child)
                if child.focusable then
                    table.insert(self.focusableChildren, child)
                end
                self:arrangeChildren()
                self:updateMinimumSize()
                return true
            end
            return false
        end,
        
        removeChild = function(self, child)
            for i, c in ipairs(self.children) do
                if c == child then
                    table.remove(self.children, i)
                    break
                end
            end
            -- Remove from focusableChildren if present
            for i, focusableChild in ipairs(self.focusableChildren) do
                if focusableChild == child then
                    table.remove(self.focusableChildren, i)
                    break
                end
            end
            self:arrangeChildren()
            self:updateMinimumSize()
        end,

        arrangeChildren = function(self)
            local x = self.padding
            local y = self.padding
            local maxHeight = 0
            
            for _, child in ipairs(self.children) do
                if x + child.width > self.width - self.padding then
                    x = self.padding
                    y = y + maxHeight + self.padding
                    maxHeight = 0
                end
                
                child.position.x = self.position.x + x
                child.position.y = self.position.y + y
                
                if child.type == "FlexContainer" then
                    child:arrangeChildren()
                end
                
                x = x + child.width + self.padding
                maxHeight = math.max(maxHeight, child.height)
            end
        end,

        updateMinimumSize = function(self)
            local minWidth = 0
            local minHeight = self.padding * 2  -- Start with padding for top and bottom
            local currentRowWidth = self.padding
            local currentRowHeight = 0
            
            for _, child in ipairs(self.children) do
                if currentRowWidth + child.width + self.padding > self.width then
                    -- Move to next row
                    minWidth = math.max(minWidth, currentRowWidth)
                    minHeight = minHeight + currentRowHeight + self.padding
                    currentRowWidth = self.padding + child.width
                    currentRowHeight = child.height
                else
                    currentRowWidth = currentRowWidth + child.width + self.padding
                    currentRowHeight = math.max(currentRowHeight, child.height)
                end
            end
            -- Add the last row
            minWidth = math.max(minWidth, currentRowWidth)
            minHeight = minHeight + currentRowHeight
            
            -- Add padding for left and right sides
            minWidth = minWidth + self.padding
            
            self.minWidth = math.max(minWidth, containerTheme.handleSize * 2)
            self.minHeight = math.max(minHeight, containerTheme.handleSize * 2)
        end,

        resize = function(self, newWidth, newHeight)
            self.width = math.max(self.minWidth, newWidth)
            self.height = math.max(self.minHeight, newHeight)
            self:arrangeChildren()
            self:updateMinimumSize()  -- Recalculate minimum size after resizing
        end,

        moveFocus = function(self, direction)
            if #self.focusableChildren == 0 then return end

            if direction == "next" then
                self.currentChildFocusIndex = (self.currentChildFocusIndex % #self.focusableChildren) + 1
            elseif direction == "previous" then
                self.currentChildFocusIndex = ((self.currentChildFocusIndex - 2) % #self.focusableChildren) + 1
            end

            -- Update focus states
            for i, child in ipairs(self.focusableChildren) do
                child.focused = (i == self.currentChildFocusIndex)
            end
        end,

        activateInternalFocus = function(self)
            self.internalFocusActive = true
            if #self.focusableChildren > 0 then
                self.currentChildFocusIndex = 1
                self.focusableChildren[1].focused = true
            end
        end,

        deactivateInternalFocus = function(self)
            self.internalFocusActive = false
            for _, child in ipairs(self.focusableChildren) do
                child.focused = false
            end
        end,

        update = function(self, mx, my, dt)
            -- Skip update if container is not visible
            if not self.visible then return end
            
            if self.focused and not self.internalFocusActive then
                self:activateInternalFocus()
            elseif not self.focused and self.internalFocusActive then
                self:deactivateInternalFocus()
            end

            if self.isDragging then
                local dx = mx - self.dragOffset.x - self.position.x
                local dy = my - self.dragOffset.y - self.position.y
                self.position.x = self.position.x + dx
                self.position.y = self.position.y + dy
                self:arrangeChildren()
            elseif self.isResizing then
                self.width = math.max(self.minWidth, mx - self.position.x)
                self.height = math.max(self.minHeight, my - self.position.y)
                self:arrangeChildren()
            end

            for _, child in ipairs(self.children) do
                if child.update then
                    child:update(mx, my, dt)
                end
            end
        end,
        
        defaultDraw = function(self)
            -- Skip drawing if container is not visible
            if not self.visible then return end
            
            -- Draw container background
            love.graphics.setColor(containerTheme.backgroundColor)
            love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height, containerTheme.cornerRadius)
            
            -- Draw container border
            love.graphics.setColor(containerTheme.borderColor)
            love.graphics.setLineWidth(containerTheme.borderWidth)
            love.graphics.rectangle("line", self.position.x, self.position.y, self.width, self.height, containerTheme.cornerRadius)
            
            -- Draw resize handle
            love.graphics.setColor(containerTheme.handleColor)
            love.graphics.rectangle("fill", self.position.x + self.width - containerTheme.handleSize, self.position.y + self.height - containerTheme.handleSize, containerTheme.handleSize, containerTheme.handleSize, containerTheme.cornerRadius)
            
            -- Draw children
            -- TODO: z-sort children before draw
            for _, child in ipairs(self.children) do
                child:draw()

                if luis.showElementOutlines then
                    luis.drawElementOutline(child)

                    local font_backup = love.graphics.getFont()
                    love.graphics.setColor(1, 1, 1, 0.7)
                    love.graphics.setFont(luis.theme.system.font)
                    love.graphics.print(child.type,child.position.x+child.width/2-string.len(child.type)*2, child.position.y)
                    love.graphics.setFont(font_backup)
                end
            end

            if luis.showElementOutlines then
                luis.drawElementOutline(self)

                local font_backup = love.graphics.getFont()
                love.graphics.setColor(1, 1, 1, 0.7)
                love.graphics.setFont(luis.theme.system.font)
                love.graphics.print(self.name,self.position.x+self.width/2-string.len(self.name)*2, self.position.y+love.graphics.getFont():getHeight())
                love.graphics.setFont(font_backup)
            end

            -- Draw focus indicator
            if self.focused then
                love.graphics.setColor(1, 1, 1, 0.5) -- grey focus
                love.graphics.rectangle("line", self.position.x - 2, self.position.y - 2, self.width + 4, self.height + 4, containerTheme.cornerRadius)
            end

            -- Draw focus indicator for the currently focused child
            if self.internalFocusActive and self.currentChildFocusIndex and self.currentChildFocusIndex > 0 then
                local focusedChild = self.focusableChildren[self.currentChildFocusIndex]
                love.graphics.setColor(0.7, 0.7, 0.7, 0.5)  -- darker child focus
                love.graphics.rectangle("line", focusedChild.position.x - 2, focusedChild.position.y - 2, focusedChild.width + 4, focusedChild.height + 4, containerTheme.cornerRadius)
            end
        end,

        -- Draw method that can use a decorator
        draw = function(self)
            -- Skip drawing if container is not visible
            if not self.visible then return end
            
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
            -- Skip interaction if container is not visible
            if not self.visible then return false end
            
            if self:isInResizeHandle(x, y) then
                self.isResizing = true
                return true
            elseif self:isInContainer(x, y) then
                for _, child in ipairs(self.children) do
                    if child.click and child:click(x, y, button, istouch) then
                        return true
                    end
                end
                self.isDragging = true
                self.dragOffset.x = x - self.position.x
                self.dragOffset.y = y - self.position.y
                return true
            end
            return false
        end,
        
        release = function(self, x, y, button, istouch)
            -- Skip interaction if container is not visible
            if not self.visible then return false end
            
            self.isDragging = false
            self.isResizing = false
            for _, child in ipairs(self.children) do
                if child.release then
                    child:release(x, y, button, istouch)
                end
            end
            return false
        end,

        wheelmoved = function(self, x, y)
            -- Skip interaction if container is not visible
            if not self.visible then return false end
            
            for _, child in ipairs(self.children) do
                if child.wheelmoved then
                    child:wheelmoved(x,y)
                    return true
                end
            end
            return false
        end,

        setText = function(self, newText)
            self.isDragging = false
            self.isResizing = false
            for _, child in ipairs(self.children) do
                if child.setText then
                    child:setText(newText)
                end
            end
        end,

        isInResizeHandle = function(self, x, y)
            return x >= self.position.x + self.width - containerTheme.handleSize and
                   x <= self.position.x + self.width and
                   y >= self.position.y + self.height - containerTheme.handleSize and
                   y <= self.position.y + self.height
        end,
        
        isInContainer = function(self, x, y)
            return x >= self.position.x and x <= self.position.x + self.width and
                   y >= self.position.y and y <= self.position.y + self.height
        end,

        gamepadpressed = function(self, id, button)
            -- Skip interaction if container is not visible
            if not self.visible then return false end
            
            if not self.internalFocusActive then return false end

            if button == "dpdown" or button == "dpright" then
                self:moveFocus("next")
                return true
            elseif button == "dpup" or button == "dpleft" then
                self:moveFocus("previous")
                return true
            elseif button == "a" or button == "b" then
                -- Activate the currently focused child
                local focusedChild = self.focusableChildren[self.currentChildFocusIndex]
                if focusedChild and focusedChild.gamepadpressed then
                    local rtn = focusedChild:gamepadpressed(id, button)
                    return rtn
                end
            end
            return false
        end,

        gamepadreleased = function(self, id, button)
            -- Skip interaction if container is not visible
            if not self.visible then return false end
            
            -- Activate the currently focused child
            local focusedChild = self.focusableChildren[self.currentChildFocusIndex]
            if focusedChild and focusedChild.gamepadreleased then
                local rtn = focusedChild:gamepadreleased(id, button)
                return rtn
            end
            return false
        end,
        
        -- New methods for visibility control
        
        -- Hide the container and all children
        hide = function(self)
            self.visible = false
        end,
        
        -- Show the container and all children
        show = function(self)
            self.visible = true
        end,
        
        -- Toggle visibility
        toggleVisibility = function(self)
            self.visible = not self.visible
        end,
        
        -- Set visibility with a boolean value
        setVisible = function(self, isVisible)
            self.visible = isVisible
        end,
        
        -- Get current visibility state
        isVisible = function(self)
            return self.visible
        end
    }
    
    container:updateMinimumSize()
    return container
end

return flexContainer
