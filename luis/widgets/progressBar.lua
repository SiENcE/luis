local progressBar = {}

local luis  -- This will store the reference to the core library
function progressBar.setluis(luisObj)
    luis = luisObj
end

-- progressBar
function progressBar.new(value, width, height, row, col, customTheme)
    local progressBarTheme = customTheme or luis.theme.progressbar
    return {
        type = "ProgressBar",
        value = math.max(0, math.min(1, value)), -- Clamp between 0 and 1
        width = width * luis.gridSize,
        height = height * luis.gridSize,
        position = luis.Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        
        draw = function(self)
            -- Draw background
            love.graphics.setColor(progressBarTheme.backgroundColor)
            love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height)
            
            -- Draw fill
            love.graphics.setColor(progressBarTheme.fillColor)
            love.graphics.rectangle("fill", self.position.x, self.position.y, self.width * self.value, self.height)
            
            -- Draw border
            love.graphics.setColor(progressBarTheme.borderColor)
            love.graphics.rectangle("line", self.position.x, self.position.y, self.width, self.height)
        end,
        
        setValue = function(self, newValue)
            self.value = math.max(0, math.min(1, newValue))
        end
    }
end

return progressBar
