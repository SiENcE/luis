local FlexContainer = {}
FlexContainer.__index = FlexContainer

local luis  -- This will store the reference to the core library
function FlexContainer.setluis(luisObj)
	luis = luisObj
end

function FlexContainer.new(x, y, width, height, rows, cols)
    local self = setmetatable({}, FlexContainer)
    self.type = "FlexContainer"
    self.position = {x = x, y = y}
    self.width = width
    self.height = height
    self.rows = rows
    self.cols = cols
    self.cellWidth = width / cols
    self.cellHeight = height / rows
    self.children = {}
    self.focusable = true
    self.focused = false
    self.currentFocus = {row = 1, col = 1}
    return self
end

function FlexContainer:addChild(child, row, col, rowSpan, colSpan)
    rowSpan = rowSpan or 1
    colSpan = colSpan or 1
    table.insert(self.children, {
        element = child,
        row = row,
        col = col,
        rowSpan = rowSpan,
        colSpan = colSpan
    })
    -- Update child's position and size
    child.position.x = self.position.x + (col - 1) * self.cellWidth
    child.position.y = self.position.y + (row - 1) * self.cellHeight
    child.width = self.cellWidth * colSpan
    child.height = self.cellHeight * rowSpan
end

function FlexContainer:update(mx, my, dt)
    for _, child in ipairs(self.children) do
        if child.element.update then
            child.element:update(mx, my, dt)
        end
    end
end

function FlexContainer:draw()
    for _, child in ipairs(self.children) do
        child.element:draw()

		if luis.showElementOutlines then
			love.graphics.setColor(1, 1, 1, 0.5)
			local font_backup = love.graphics.getFont()
			local font = love.graphics.newFont(12, "mono")
			love.graphics.setFont(font)
			local text = child.element.position.x/luis.gridSize+1 .. " x "	-- we have to add +1 as the grid is indexed at 1,1 not 0,0 !!
			love.graphics.print(text, child.element.position.x+2, child.element.position.y)
			love.graphics.print(child.element.position.y/luis.gridSize+2, child.element.position.x+string.len(text)*4+12, child.element.position.y)

			love.graphics.print(child.element.width/luis.gridSize, child.element.position.x+child.element.width-22, child.element.position.y)
			love.graphics.print(child.element.height/luis.gridSize, child.element.position.x+child.element.width-22, child.element.position.y+child.element.height-16)

			love.graphics.rectangle("line", child.element.position.x, child.element.position.y, child.element.width, child.element.height)
			love.graphics.setFont(font_backup)
	
			love.graphics.print(child.element.type,child.element.position.x+child.element.width/2-string.len(child.element.type)*2, child.element.position.y)
		end
    end
    
    -- Draw grid lines (optional, for debugging)
    love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
    for i = 0, self.cols do
        local x = self.position.x + i * self.cellWidth
        love.graphics.line(x, self.position.y, x, self.position.y + self.height)
    end
    for i = 0, self.rows do
        local y = self.position.y + i * self.cellHeight
        love.graphics.line(self.position.x, y, self.position.x + self.width, y)
    end
end

function FlexContainer:moveFocus(direction)
    local row, col = self.currentFocus.row, self.currentFocus.col
    if direction == "up" and row > 1 then
        row = row - 1
    elseif direction == "down" and row < self.rows then
        row = row + 1
    elseif direction == "left" and col > 1 then
        col = col - 1
    elseif direction == "right" and col < self.cols then
        col = col + 1
    end
    self.currentFocus = {row = row, col = col}
    -- Focus the child at the new position
    self:focusChildAt(row, col)
end

function FlexContainer:focusChildAt(row, col)
    for _, child in ipairs(self.children) do
        if child.row == row and child.col == col then
            if child.element.setFocus then
                child.element:setFocus(true)
            end
            break
        end
    end
end

function FlexContainer:gamepadpressed(joystick, button)
    if button == "dpup" then
        self:moveFocus("up")
    elseif button == "dpdown" then
        self:moveFocus("down")
    elseif button == "dpleft" then
        self:moveFocus("left")
    elseif button == "dpright" then
        self:moveFocus("right")
    end
    -- Pass the input to the focused child
    for _, child in ipairs(self.children) do
        if child.row == self.currentFocus.row and child.col == self.currentFocus.col then
            if child.element.gamepadpressed then
                return child.element:gamepadpressed(joystick, button)
            end
            break
        end
    end
    return false
end

return FlexContainer
