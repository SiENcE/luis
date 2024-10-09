local initLuis = require("luis.init")
-- Direct this to your widgets folder.
local luis = initLuis("examples/basic_ui/widgets")

local RetroMenu = require("examples.basic_ui.retro_menu")

function love.load()
    love.window.setMode(800, 600, {resizable=false, vsync=true})

    luis.updateScale()
    
    RetroMenu.init()
end

function love.update(dt)
    luis.update(dt)
end

function love.draw()
    luis.draw()
end

function love.mousepressed(x, y, button, istouch)
    luis.mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    luis.mousereleased(x, y, button, istouch)
end

function love.keypressed(key)
    luis.keypressed(key)
end
