local utils = require("luis.utils")

local flexContainer = {}

local luis  -- This will store the reference to the core library
function flexContainer.setluis(luisObj)
    luis = luisObj
end

-- FlexContainer
function flexContainer.new(width, height, row, col, customTheme)
    local containerTheme = customTheme or luis.theme.flexContainer

    local container = {
        type = "FlexContainer",
        width = width * luis.gridSize,
        height = height * luis.gridSize,
        position = luis.Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        children = {},
        padding = containerTheme.padding,
        isDragging = false,
        isResizing = false,
        dragOffset = luis.Vector2D.new(0, 0),
        
        addChild = function(self, child)
            table.insert(self.children, child)
            self:arrangeChildren()
        end,
        
        removeChild = function(self, child)
            for i, c in ipairs(self.children) do
                if c == child then
                    table.remove(self.children, i)
                    break
                end
            end
            self:arrangeChildren()
        end,
        
        arrangeChildren = function(self)
            local x = self.position.x + self.padding
            local y = self.position.y + self.padding
            local maxHeight = 0
            
            for _, child in ipairs(self.children) do
                if x + child.width > self.position.x + self.width - self.padding then
                    -- Move to next row
                    x = self.position.x + self.padding
                    y = y + maxHeight + self.padding
                    maxHeight = 0
                end
                
                child.position.x = x
                child.position.y = y
                
                x = x + child.width + self.padding
                maxHeight = math.max(maxHeight, child.height)
            end
        end,
        
        resize = function(self, newWidth, newHeight)
            self.width = newWidth
            self.height = newHeight
            self:arrangeChildren()
        end,
        
        update = function(self, mx, my)
            if self.isDragging then
                self.position.x = mx - self.dragOffset.x
                self.position.y = my - self.dragOffset.y
                self:arrangeChildren()
            elseif self.isResizing then
                self.width = math.max(containerTheme.handleSize * 2, mx - self.position.x)
                self.height = math.max(containerTheme.handleSize * 2, my - self.position.y)
                self:arrangeChildren()
            end

            for _, child in ipairs(self.children) do
                if child.update then
                    child:update(mx, my)
                end
            end
        end,
        
        draw = function(self)
            -- Draw container background
            love.graphics.setColor(containerTheme.backgroundColor)
            love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height)
            
            -- Draw container border
            love.graphics.setColor(containerTheme.borderColor)
            love.graphics.setLineWidth(containerTheme.borderWidth)
            love.graphics.rectangle("line", self.position.x, self.position.y, self.width, self.height)
            
            -- Draw resize handle
            love.graphics.setColor(containerTheme.handleColor)
            love.graphics.rectangle("fill", self.position.x + self.width - containerTheme.handleSize, self.position.y + self.height - containerTheme.handleSize, containerTheme.handleSize, containerTheme.handleSize)
            
            -- Draw children
            for _, child in ipairs(self.children) do
                child:draw()
            end
        end,
        
        click = function(self, x, y)
            if self:isInResizeHandle(x, y) then
                self.isResizing = true
                return true
            elseif self:isInContainer(x, y) then
                for _, child in ipairs(self.children) do
                    if child.click and child:click(x, y) then
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
        
        release = function(self, x, y)
            self.isDragging = false
            self.isResizing = false
            for _, child in ipairs(self.children) do
                if child.release then
                    child:release(x, y)
                end
            end
        end,

        textinput = function(self, text)
            self.isDragging = false
            self.isResizing = false
            for _, child in ipairs(self.children) do
                if child.textinput then
                    child:textinput(text)
					return
                end
            end
        end,

        keypressed = function(self, key)
            self.isDragging = false
            self.isResizing = false
            for _, child in ipairs(self.children) do
                if child.keypressed then
                    child:keypressed(key)
					return
                end
            end
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
        end
    }
    
    return container
end

return flexContainer