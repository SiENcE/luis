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
function label.new(text, width, height, row, col, align, customTheme)
    local labelTheme = customTheme or luis.theme.text
    return {
        type = "Label",
        text = text,
        width = width * luis.gridSize,
        height = height * luis.gridSize,
		position = luis.Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        
        draw = function(self)
            local textTheme = applyThemeToText(customTheme or luis)
            love.graphics.printf(self.text, self.position.x, self.position.y + (self.height - textTheme.font:getHeight()) / 2, self.width, align or textTheme.align)
        end,

        setText = function(self, newText)
            self.text = newText
        end
    }
end

return label
