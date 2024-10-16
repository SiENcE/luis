local initLuis = require("luis.init")
-- Direct this to your widgets folder.
local luis = initLuis("examples/complex_ui/widgets")

local theme = {
	node = {
		textColor = {1,1,1},
		backgroundColor = {0.1, 0.1, 0.1},
		borderColorHover = {0.25, 0.25, 0.25, 1},
		borderColor = {0.25, 0.25, 0.25, 1},
		inputPortColor = {0,1,0},
		outputPortColor = {1,0,0},
		connectionColor = {0,1,0},
		connectingColor = {0.7,0.7,0.7},
	},
	colorpicker = {
		cornerRadius = 4,
	}
}

function love.load()
    luis.newLayer("graph")
--[[
    local node1 = luis.createElement("graph", "Node", "My Node 0", 4, 4, 10, 10, nil, theme.node)
    node1:addOutput("Output 1")
    node1:addOutput("Output 2")

    local node2 = luis.createElement("graph", "Node", "My Node 1", 4, 4, 5, 19, nil, theme.node)
    node2:addInput("Input 1")
    node2:addOutput("Output 1")

    local node3 = luis.createElement("graph", "Node", "My Node 2", 4, 4, 14, 19, nil, theme.node)
    node3:addInput("Input 1")
    node3:addInput("Input 2")

    node1:connect(1, node2, 1)
    node1:connect(2, node3, 1)
    node2:connect(1, node3, 2)
]]--
	local valueNode0 = luis.createElement("graph", "Node", "Value 0", 4, 4, 5, 10, function()
		return {0}
	end, theme.node)
	valueNode0:addOutput("0")

	local valueNode1 = luis.createElement("graph", "Node", "Value 1", 4, 4, 5, 10, function()
		return {1}
	end, theme.node)
	valueNode1:addOutput("1")

	local valueNode2 = luis.createElement("graph", "Node", "Value 2", 4, 4, 5, 10, function()
		return {2}
	end, theme.node)
	valueNode2:addOutput("2")

	local valueNode3 = luis.createElement("graph", "Node", "Value 3", 4, 4, 5, 5, function()
		return {3}
	end, theme.node)
	valueNode3:addOutput("3")

	local adderNode = luis.createElement("graph", "Node", "Adder", 4, 4, 10, 10, function(a, b)
		return {(a or 0) + (b or 0)}
	end, theme.node)
	adderNode:addInput("A")
	adderNode:addInput("B")
	adderNode:addOutput("Sum")

	local multiplierNode = luis.createElement("graph", "Node", "Multiplier", 4, 4, 5, 19, function(a, b)
		return {(a or 1) * (b or 1)}
	end, theme.node)
	multiplierNode:addInput("A")
	multiplierNode:addInput("B")
	multiplierNode:addOutput("Product")

	-- Connect nodes
	adderNode:connect(1, multiplierNode, 1)

	-- AND Gate
	local andNode = luis.createElement("graph", "Node", "AND", 4, 4, 10, 19, function(a, b)
        return {(a == 1 and b == 1) and 1 or 0}
	end, theme.node)
	andNode:addInput("A")
	andNode:addInput("B")
    andNode:addOutput("Result")

	-- OR Gate
	local orNode = luis.createElement("graph", "Node", "OR", 4, 4, 10, 19, function(a, b)
        return {(a == 1 or b == 1) and 1 or 0}
	end, theme.node)
	orNode:addInput("A")
	orNode:addInput("B")
    orNode:addOutput("Result")

	-- XOR Gate
	local xorNode = luis.createElement("graph", "Node", "XOR", 4, 4, 10, 19, function(a, b)
        return {(a ~= b) and 1 or 0}
	end, theme.node)
	xorNode:addInput("A")
	xorNode:addInput("B")
    xorNode:addOutput("Result")

	-- NOT Gate
	local notNode = luis.createElement("graph", "Node", "NOT", 4, 4, 10, 19, function(a)
        return {(not (a == 1)) and 1 or 0}
	end, theme.node)
	notNode:addInput("A")
    notNode:addOutput("Result")

	-- NAND Gate
	local nandNode = luis.createElement("graph", "Node", "NAND", 4, 4, 10, 19, function(a, b)
        return {not (a == 1 and b == 1) and 1 or 0}
	end, theme.node)
	nandNode:addInput("A")
	nandNode:addInput("B")
    nandNode:addOutput("Result")

	-- NOR Gate
	local norNode = luis.createElement("graph", "Node", "NOR", 4, 4, 10, 19, function(a, b)
        return {not (a == 1 or b == 1) and 1 or 0}
	end, theme.node)
	norNode:addInput("A")
	norNode:addInput("B")
    norNode:addOutput("Result")

	-- XNOR Gate
	local xnorNode = luis.createElement("graph", "Node", "XNOR", 4, 4, 10, 19, function(a, b)
        return {(a == b) and 1 or 0}
	end, theme.node)
	xnorNode:addInput("A")
	xnorNode:addInput("B")
    xnorNode:addOutput("Result")

	-- 3-Input Majority Gate
	local majorityNode = luis.createElement("graph", "Node", "Majority", 4, 4, 10, 19, function(a, b, c)
        local sum = (a == 1 and 1 or 0) + (b == 1 and 1 or 0) + (c == 1 and 1 or 0)
        return {sum >= 2 and 1 or 0}
	end, theme.node)
	majorityNode:addInput("A")
	majorityNode:addInput("B")
	majorityNode:addInput("C")
    majorityNode:addOutput("Result")

	-- Implication Gate
	local implicationNode = luis.createElement("graph", "Node", "Implication", 4, 4, 10, 19, function(a, b)
        return {( (not a) or b == 1) and 1 or 0}
	end, theme.node)
	implicationNode:addInput("A")
	implicationNode:addInput("B")
    implicationNode:addOutput("Result")

	-- 4-bit Parity Generator
	local parityNode = luis.createElement("graph", "Node", "Parity", 4, 4, 10, 19, function(a, b, c, d)
        local sum = (a == 1 and 1 or 0) + (b == 1 and 1 or 0) + (c == 1 and 1 or 0) + (d == 1 and 1 or 0)
        return {sum % 2 == 1 and 1 or 0}
	end, theme.node)
    parityNode:addInput("A")
    parityNode:addInput("B")
    parityNode:addInput("C")
    parityNode:addInput("D")
    parityNode:addOutput("Parity")

	-- 2-to-1 Multiplexer
	local muxNode = luis.createElement("graph", "Node", "MUX", 4, 4, 10, 19, function(a, b, sel)
        return {s == 1 and a or b}
	end, theme.node)
    muxNode:addInput("A")
    muxNode:addInput("B")
    muxNode:addInput("Select")
    muxNode:addOutput("Output")

	-- SR Latch
	local srLatchNode = luis.createElement("graph", "Node", "SR Latch", 4, 4, 10, 19, function(set, reset)
        local state = srLatchNode.state or 0
        if set and not reset then
            state = 1
        elseif reset and not set then
            state = 0
        elseif set and reset then
            state = "Invalid"
        end
        srLatchNode.state = state
        return {state, state == 1 and 0 or 1}
	end, theme.node)
    srLatchNode:addInput("Set")
    srLatchNode:addInput("Reset")
    srLatchNode:addOutput("Q")
    srLatchNode:addOutput("Q'")
--[[
	-- In your LUIS initialization code:
	luis.createElement("graph", "ColorPicker", 8, 3, 1, 1,
		function(color)
			print("Selected color:", color[1], color[2], color[3])
		end)
]]--
	luis.enableLayer("graph")
end

function love.update(dt)
    luis.update(dt)
end

function love.draw()
    luis.draw()
end

function love.keypressed(key, scancode, isrepeat)
	if key == "tab" then
        luis.showGrid = not luis.showGrid
        luis.showElementOutlines = not luis.showElementOutlines
        luis.showLayerNames = not luis.showLayerNames
	else
		luis.keypressed(key, scancode, isrepeat)
	end
end

function love.mousepressed(x, y, button, istouch)
    luis.mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    luis.mousereleased(x, y, button, istouch)
end
