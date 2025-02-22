local initLuis = require("luis.init")

-- point this to your widgets folder
local luis = initLuis()

-- create a Button widget
local CustomButtonWidget = {}
function CustomButtonWidget.new(x, y, width, height, text, onClick)
    local self = {
        type = "CustomButtonWidget", position = {x=x, y=y},
		width = width, height = height, text = text,
		onClick = onClick, hovered = false, pressed = false
    }
    function self:update(mx, my)
        self.hovered = mx > self.position.x and mx < self.position.x + self.width and
                       my > self.position.y and my < self.position.y + self.height
    end
    function self:draw()
        love.graphics.setColor(self.pressed and {0.3,0.3,0.3} or {0.7,0.7,0.7})
        love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height, 3)
        love.graphics.setColor(1,1,1)
        love.graphics.print(self.text, self.position.x, self.position.y)
    end
    function self:click(_, _, button)
        if button == 1 and self.hovered then
            self.pressed = true
            if self.onClick then self.onClick() end
            return true
        end
        return false
    end
    function self:release(_, _, button)
        if button == 1 and self.pressed then
            self.pressed = false
            return true
        end
        return false
    end

    return self
end

-- add it manually to the luis library (the default way is to load them automatically)
CustomButtonWidget.luis = luis
luis.widgets["CustomButtonWidget"] = CustomButtonWidget
luis["newCustomButtonWidget"] = CustomButtonWidget.new

function love.load()
    luis.newLayer("main")
    luis.enableLayer("main")

	-- You can create an add an new Widget to a Layer
	luis.createElement("main", "CustomButtonWidget", 100, 200, 100, 50, "Click me 1!", function() print("Button clicked!") end)

	-- or you can first create the widget (not useable or visible)
	local button_widget  = luis.newCustomButtonWidget( 200, 200, 100, 50, "Click me 2!", function() print("Button clicked!") end)
	
	-- and than add it to a layer to make it work
	luis.insertElement("main", button_widget)
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