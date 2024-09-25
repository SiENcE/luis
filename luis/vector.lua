local Vector2D = {}
Vector2D.__index = Vector2D

function Vector2D.new(x, y)
    return setmetatable({x = x or 0, y = y or 0}, Vector2D)
end

function Vector2D:add(other)
    return Vector2D.new(self.x + other.x, self.y + other.y)
end

function Vector2D:multiply(scalar)
    return Vector2D.new(self.x * scalar, self.y * scalar)
end

return Vector2D
