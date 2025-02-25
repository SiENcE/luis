local Vector2D = require("luis.3rdparty.vector")
local decorators = require("luis.3rdparty.decorators")

local custom = {}

local luis  -- This will store the reference to the core library
function custom.setluis(luisObj)
    luis = luisObj
end

-- Custom
function custom.new(drawFunc, width, height, row, col, customTheme)
    local customTheme = customTheme or luis.theme.text
    return {
        type = "Custom",
        drawFunc = drawFunc,
        width = width * luis.gridSize,
        height = height * luis.gridSize,
        position = Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        focused = false,
        focusable = false,    -- Make it not focusable
		theme = customTheme,
		decorator = nil,
        
        defaultDraw = function(self)
            love.graphics.push()
            love.graphics.translate(self.position.x, self.position.y)
            love.graphics.setColor(customTheme.color or {1, 1, 1, 1})
            self.drawFunc(self)
            love.graphics.pop()

            -- Draw focus indicator
            if self.focused then
                love.graphics.setColor(1, 1, 1, 0.5)
                love.graphics.rectangle("line", self.position.x - 2, self.position.y - 2, self.width + 4, self.height + 4, customTheme.cornerRadius)
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
    }
end

return custom
