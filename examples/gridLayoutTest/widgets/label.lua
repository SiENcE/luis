local Vector2D = require("examples.3rdparty.vector")
local decorators = require("examples.3rdparty.decorators")

local label = {}

local luis  -- This will store the reference to the core library
function label.setluis(luisObj)
    luis = luisObj
end

local function applyThemeToText(customTheme)
    local textTheme = customTheme.theme.text or luis.theme.text
    love.graphics.setColor(textTheme.color)
    love.graphics.setFont(textTheme.font)
    return textTheme
end

-- Label
function label.new(text, width, height, row, col, align, customTheme, rowSpan, colSpan)
    local labelTheme = customTheme or luis.theme.text
    
    -- Calculate grid-aware dimensions
    local gridWidth = width * luis.gridSize
    local gridHeight = height * luis.gridSize
    
    -- Apply row and column spans
    if rowSpan and rowSpan > 1 then
        gridHeight = gridHeight * rowSpan
    end
    if colSpan and colSpan > 1 then
        gridWidth = gridWidth * colSpan
    end
    
    return {
        type = "Label",
        text = text,
        width = gridWidth,
        height = gridHeight,
        position = Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        theme = labelTheme,
        decorator = nil,
        row = row,
        col = col,
		color = { love.math.random( 0.1, 0.9 ), love.math.random( 0.1, 0.9 ), love.math.random( 0.1, 0.9 )},
        rowSpan = rowSpan or 1,
        colSpan = colSpan or 1,
        
        defaultDraw = function(self)
			love.graphics.setColor( self.color[1], self.color[2], self.color[3], 1)
			love.graphics.rectangle( "fill", self.position.x, self.position.y, self.width, self.height )
            local textTheme = applyThemeToText(customTheme or luis)
            love.graphics.printf(self.text, self.position.x, self.position.y + (self.height - textTheme.font:getHeight()) / 2, self.width, align or textTheme.align)
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

        setText = function(self, newText)
            self.text = newText
        end,
        
        -- Method to update position based on grid
        updateGridPosition = function(self, newRow, newCol)
            self.row = newRow
            self.col = newCol
            self.position.x = (newCol - 1) * luis.gridSize
            self.position.y = (newRow - 1) * luis.gridSize
        end,
        
        -- Method to update size based on grid
        updateGridSize = function(self, newWidth, newHeight, newRowSpan, newColSpan)
            self.width = newWidth * luis.gridSize
            self.height = newHeight * luis.gridSize
            if newRowSpan and newRowSpan > 1 then
                self.height = self.height * newRowSpan
            end
            if newColSpan and newColSpan > 1 then
                self.width = self.width * newColSpan
            end
            self.rowSpan = newRowSpan or self.rowSpan
            self.colSpan = newColSpan or self.colSpan
        end
    }
end

return label
