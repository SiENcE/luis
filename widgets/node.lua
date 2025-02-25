local utils = require("luis.3rdparty.utils")
local Vector2D = require("luis.3rdparty.vector")
local decorators = require("luis.3rdparty.decorators")

local pointInRect = utils.pointInRect
local distanceBetween = utils.distanceBetween

local node = {}

local luis  -- This will store the reference to the core library
function node.setluis(luisObj)
    luis = luisObj
end

function node.new(title, width, height, row, col, func, customTheme)
    local nodeTheme = customTheme or luis.theme.node
    return {
        type = "Node",
        title = title,
        width = width * luis.gridSize,
        height = height * luis.gridSize,
        position = Vector2D.new((col - 1) * luis.gridSize, (row - 1) * luis.gridSize),
        inputs = {},
        outputs = {},
        connections = {},
        hover = false,
        pressed = false,
        dragging = false,
        focused = false,
        focusable = true,  -- Make the button focusable
        theme = nodeTheme,
        decorator = nil,
        dragOffset = Vector2D.new(0, 0),
        connectingFrom = nil,
        func = func or function() return {} end,  -- Default function if none provided

        addInput = function(self, name)
            table.insert(self.inputs, {name = name, position = Vector2D.new(0, 0), value = nil})
            self:updatePortPositions()
        end,

        addOutput = function(self, name)
            table.insert(self.outputs, {name = name, position = Vector2D.new(0, 0), value = nil})
            self:updatePortPositions()
        end,

        updatePortPositions = function(self)
            local inputSpacing = self.height / (#self.inputs + 1)
            for i, input in ipairs(self.inputs) do
                input.position = Vector2D.new(0, i * inputSpacing)
            end

            local outputSpacing = self.height / (#self.outputs + 1)
            for i, output in ipairs(self.outputs) do
                output.position = Vector2D.new(self.width, i * outputSpacing)
            end
        end,

        connect = function(self, outputIndex, targetNode, inputIndex)
            table.insert(self.connections, {
                from = self,
                fromPort = outputIndex,
                to = targetNode,
                toPort = inputIndex
            })
            -- Initialize data flow
            self:execute()
        end,

        disconnect = function(self, connectionIndex)
            local connection = self.connections[connectionIndex]
            if connection then
                -- Clear the input value of the target node
                connection.to.inputs[connection.toPort].value = nil
                -- Remove the connection
                table.remove(self.connections, connectionIndex)
                -- Re-execute the target node to update its state
                connection.to:execute()
            end
        end,

        execute = function(self)
            -- Collect input values
            local inputValues = {}
            for i, input in ipairs(self.inputs) do
                inputValues[i] = input.value
            end

            -- Execute the node's function
            local results = self.func(unpack(inputValues))

            -- Update output values
            for i, output in ipairs(self.outputs) do
                output.value = results[i]
            end

            -- Propagate results to connected nodes
            for _, connection in ipairs(self.connections) do
                connection.to.inputs[connection.toPort].value = self.outputs[connection.fromPort].value
                connection.to:execute()  -- Execute the connected node
            end
        end,

        update = function(self, mx, my)
            self.hover = pointInRect(mx, my, self.position.x, self.position.y, self.width, self.height)
            
            if self.dragging then
                self.position = Vector2D.new(mx, my) - self.dragOffset
            end
        end,

        defaultDraw = function(self)
            -- Draw node background
            love.graphics.setColor(self.theme.backgroundColor)
            love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height, 5)

            -- Draw node border
            love.graphics.setColor(self.hover and self.theme.borderColorHover or self.theme.borderColor)
            love.graphics.rectangle("line", self.position.x, self.position.y, self.width, self.height, 5)

            -- Draw node title
            love.graphics.setColor(self.theme.textColor)
            love.graphics.printf(self.title, self.position.x, self.position.y + 5, self.width, "center")

            -- Draw input ports
            for _, input in ipairs(self.inputs) do
                love.graphics.setColor(self.theme.inputPortColor)
                love.graphics.circle("fill", self.position.x + input.position.x, self.position.y + input.position.y, 5)
            end

            -- Draw output ports
            for _, output in ipairs(self.outputs) do
                love.graphics.setColor(self.theme.outputPortColor)
                love.graphics.circle("fill", self.position.x + output.position.x, self.position.y + output.position.y, 5)
            end

            -- Draw connections
            for _, connection in ipairs(self.connections) do
                love.graphics.setColor(self.theme.connectionColor)
                local startX = connection.from.position.x + connection.from.outputs[connection.fromPort].position.x
                local startY = connection.from.position.y + connection.from.outputs[connection.fromPort].position.y
                local endX = connection.to.position.x + connection.to.inputs[connection.toPort].position.x
                local endY = connection.to.position.y + connection.to.inputs[connection.toPort].position.y
                love.graphics.line(startX, startY, endX, endY)
            end

            -- Draw connecting line when making a new connection
            if self.connectingFrom then
                love.graphics.setColor(self.theme.connectingColor)
                local startX = self.position.x + self.outputs[self.connectingFrom].position.x
                local startY = self.position.y + self.outputs[self.connectingFrom].position.y
                love.graphics.line(startX, startY, love.mouse.getX(), love.mouse.getY())
            end

            -- Draw input and output values
            love.graphics.setColor(self.theme.textColor)
            for i, input in ipairs(self.inputs) do
                love.graphics.printf(tostring(input.value), self.position.x + 10, self.position.y + input.position.y - 10, 50, "left")
            end
            for i, output in ipairs(self.outputs) do
                love.graphics.printf(tostring(output.value), self.position.x + self.width - 60, self.position.y + output.position.y - 10, 50, "right")
            end

			-- Draw focus indicator
			if self.focused then
				love.graphics.setColor(1, 1, 1, 0.5)
				love.graphics.rectangle("line", self.position.x - 2, self.position.y - 2, self.width + 4, self.height + 4, 4 + 2)
			end
        end,

        draw = function(self)
            if self.decorator then
                self.decorator:draw()
            else
                self:defaultDraw()
            end
        end,

        setDecorator = function(self, decoratorType, ...)
            self.decorator = decorators[decoratorType].new(self, ...)
        end,

        click = function(self, x, y, button, istouch, presses)
            if (self.hover or self.focused) and not self.pressed and button == 1 then
                if self.hover then
                    self.pressed = true
                    self.dragging = true
                    self.dragOffset = Vector2D.new(x - self.position.x, y - self.position.y)
                    return true
                end
            elseif not self.pressed and not self.dragging and button == 1 then
                -- Check if clicking on an output port
                for i, output in ipairs(self.outputs) do
                    if distanceBetween(x, y, self.position.x + output.position.x, self.position.y + output.position.y) < 10 then
                        self.connectingFrom = i
                        return true
                    end
                end

                -- Check if clicking on an input port to disconnect
                for i, input in ipairs(self.inputs) do
                    if distanceBetween(x, y, self.position.x + input.position.x, self.position.y + input.position.y) < 10 then
                        -- Find the connection in other nodes and disconnect it
                        for layerName, enabled in pairs(luis.enabledLayers) do
                            if enabled and luis.elements[layerName] then
                                for _, element in ipairs(luis.elements[layerName]) do
                                    if element.type == 'Node' and element ~= self then
                                        for j, connection in ipairs(element.connections) do
                                            if connection.to == self and connection.toPort == i then
                                                element:disconnect(j)
                                                return true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            return false
        end,

        release = function(self, x, y, button, istouch)
            if self.pressed and button == 1 then
                self.pressed = false
                self.dragging = false

                return true
            else
                if self.connectingFrom then
                    -- Check if released on another node's input port
					for layerName, enabled in pairs(luis.enabledLayers) do
						if enabled and luis.elements[layerName] then
							for i, element in ipairs(luis.elements[layerName]) do
								if element.type=='Node' then
									if element ~= self and element.hover then
										for i, input in ipairs(element.inputs) do
											local inputX = element.position.x + input.position.x
											local inputY = element.position.y + input.position.y
											if distanceBetween(x, y, inputX, inputY) < 10 then
												self:connect(self.connectingFrom, element, i)
												self.connectingFrom = nil
												return true
											end
										end
									end
								end
							end
						end
					end
					self.connectingFrom = nil
                end
			end
            return false
        end,

        updateFocus = function(self, jx, jy)
            -- Handle joystick input for node selection or manipulation
            -- This can be implemented based on specific requirements
        end,
    }
end

return node