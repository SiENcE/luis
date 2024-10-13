local Vector2D = require("examples.3rdparty.vector")

local Ball = {}
Ball.__index = Ball

-- Spielfeldbegrenzungen
local arena = {x = 0, y = 0, width = 100, height = 100}

-- Kugel-Tabelle
local kugeln = {
    {x = 10, y = 20, speed = 0, angle = 0, radius = 10, max_speed = 10},
    {x = 20, y = 10, speed = 0, angle = 0, radius = 10, max_speed = 10}
}
local collisionDamper = -0.5
local accelerationFactor = 1
local brakingFactor = 1

-- Funktion für Wandkollision
local function checkWallCollision(kugel)
    -- Linke und rechte Wandkollision
    if kugel.x - kugel.radius < arena.x then
        kugel.x = arena.x + kugel.radius
        kugel.speed = kugel.speed * collisionDamper -- Reduziere Geschwindigkeit
        -- Horizontale Bewegung umkehren (Rückstoß)
        kugel.x = kugel.x + (arena.x + kugel.radius - kugel.x)
    elseif kugel.x + kugel.radius > arena.x + arena.width then
        kugel.x = arena.x + arena.width - kugel.radius
        kugel.speed = kugel.speed * collisionDamper
        kugel.x = kugel.x - (kugel.x - (arena.x + arena.width - kugel.radius))
    end

    -- Obere und untere Wandkollision
    if kugel.y - kugel.radius < arena.y then
        kugel.y = arena.y + kugel.radius
        kugel.speed = kugel.speed * collisionDamper
        kugel.y = kugel.y + (arena.y + kugel.radius - kugel.y)
    elseif kugel.y + kugel.radius > arena.y + arena.height then
        kugel.y = arena.y + arena.height - kugel.radius
        kugel.speed = kugel.speed * collisionDamper
        kugel.y = kugel.y - (kugel.y - (arena.y + arena.height - kugel.radius))
    end
end

function updateKugel(dt, kugel, stickX, stickY)
    -- Stärke und Richtung des Sticks
    local strength = math.sqrt(stickX^2 + stickY^2) -- Entfernung vom Stick-Zentrum
    local angle = math.atan2(stickY, stickX) -- Winkel der Stickbewegung

    -- Nur beschleunigen, wenn der Stick sich vom Zentrum weg bewegt
    if strength then -- Schwellenwert, ab wann der Stick vom Zentrum weg ist
        local acceleration = strength * accelerationFactor -- Stärke multipliziert mit einem Beschleunigungsfaktor

        -- Aktualisiere Geschwindigkeit, begrenzt durch die Maximalgeschwindigkeit
        kugel.speed = math.min(kugel.speed + acceleration * dt, kugel.max_speed)

        -- Bewege die Kugel in die Richtung des Sticks
        kugel.x = kugel.x + math.cos(angle) * kugel.speed --* dt
        kugel.y = kugel.y + math.sin(angle) * kugel.speed --* dt
    else
        -- Wenn der Stick im Zentrum ist, langsam abbremsen
        kugel.speed = kugel.speed * brakingFactor -- Verlangsamen durch einen Bremsfaktor
    end

    -- Überprüfen, ob die Kugel gegen die Wände stößt und abprallen lassen
    checkWallCollision(kugel)
end


-- Funktion zur Kollisionserkennung zwischen zwei Kugeln
local function checkCollision(kugel1, kugel2)
    local dx = kugel2.x - kugel1.x
    local dy = kugel2.y - kugel1.y
    local distance = math.sqrt(dx^2 + dy^2)
    return distance < (kugel1.radius + kugel2.radius)
end

-- Funktion zur Behandlung der Kugelkollisionen
local function handleCollision(kugel1, kugel2)
    local dx = kugel2.x - kugel1.x
    local dy = kugel2.y - kugel1.y
    local angle = math.atan2(dy, dx)

    -- Abstoßbewegung
    kugel1.x = kugel1.x - math.cos(angle) * 10
    kugel1.y = kugel1.y - math.sin(angle) * 10
    kugel2.x = kugel2.x + math.cos(angle) * 10
    kugel2.y = kugel2.y + math.sin(angle) * 10

    -- Geschwindigkeit reduzieren
    kugel1.speed = kugel1.speed * collisionDamper
    kugel2.speed = kugel2.speed * collisionDamper
end

function Ball.new(x, y)
    local self = setmetatable({}, Ball)
    return self
end

function Ball:update(dt, joystick1, joystick2, width, height)
	-- update arena dimensions
	arena.width = width
	arena.height = height

    -- Simuliere die Kugeln basierend auf den Sticks
    local leftStickX, leftStickY = joystick1.x, joystick1.y
    local rightStickX, rightStickY = joystick2.x, joystick2.y

    -- Kugeln basierend auf den Stickwerten aktualisieren
    updateKugel(dt, kugeln[1], leftStickX, leftStickY)
    updateKugel(dt, kugeln[2], rightStickX, rightStickY)

    -- Kollision überprüfen und behandeln
    if checkCollision(kugeln[1], kugeln[2]) then
        handleCollision(kugeln[1], kugeln[2])
    end
end

function Ball:draw()
    -- Zeichne die Kugeln
    for _, kugel in ipairs(kugeln) do
        love.graphics.circle("fill", kugel.x, kugel.y, kugel.radius)
    end
end

return Ball
