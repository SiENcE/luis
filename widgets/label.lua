local Vector2D = require("luis.3rdparty.vector")
local decorators = require("luis.3rdparty.decorators")

local label = {}

local luis  -- This will store the reference to the core library
function label.setluis(luisObj)
    luis = luisObj
end

local function applyThemeToText(customTheme)
    local textTheme = customTheme or luis.theme.text
    love.graphics.setColor(textTheme.color)
    love.graphics.setFont(textTheme.font)
    return textTheme
end

-- Label
function label.new(value, width, height, row, col, align, customTheme)
    local labelTheme = customTheme or luis.theme.text
    return {
        type = "Label",
        value = value,
        width = width * luis.gridSize,
        height = height * luis.gridSize,
		position = Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
		theme = labelTheme,
		decorator = nil,
        
        defaultDraw = function(self)
            local textTheme = applyThemeToText(self.theme or luis)
            love.graphics.printf(self.value, self.position.x, self.position.y + (self.height - textTheme.font:getHeight()) / 2, self.width, align or textTheme.align)
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
            self.value = newText
        end
    }
end

return label
