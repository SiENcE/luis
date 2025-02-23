local Vector2D = {}
Vector2D.__index = Vector2D

function Vector2D.new(x, y)
    return setmetatable({x = x or 0, y = y or 0}, Vector2D)
end

function Vector2D:clone()
    return Vector2D.new(self.x, self.y)
end

function Vector2D:add(other)
    return Vector2D.new(self.x + other.x, self.y + other.y)
end

function Vector2D:subtract(other)
    return Vector2D.new(self.x - other.x, self.y - other.y)
end

function Vector2D:multiply(scalar)
    return Vector2D.new(self.x * scalar, self.y * scalar)
end

function Vector2D:divide(scalar)
    return Vector2D.new(self.x / scalar, self.y / scalar)
end

function Vector2D:len()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector2D:normalized()
    local length = self:len()
    if length > 0 then
        return self:divide(length)
    else
        return Vector2D.new(0, 0)
    end
end

-- Operator overloading
function Vector2D.__add(a, b)
    return a:add(b)
end

function Vector2D.__sub(a, b)
    return a:subtract(b)
end

function Vector2D.__mul(a, b)
    if type(a) == "number" then
        return b:multiply(a)
    elseif type(b) == "number" then
        return a:multiply(b)
    else
        error("Multiplication is only defined between a vector and a scalar")
    end
end

function Vector2D.__div(a, b)
    if type(b) == "number" then
        return a:divide(b)
    else
        error("Division is only defined between a vector and a scalar")
    end
end

return Vector2D
