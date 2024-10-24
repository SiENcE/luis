local initLuis = require("luis.init")
-- Direct this to your widgets folder.
local luis = initLuis("examples/complex_ui/widgets")
local Vector2D = require("examples.3rdparty.vector")

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

-- AND Gate
function createAND()
    local andNode = luis.createElement("graph", "Node", "AND", 4, 4, 10, 19, function(a, b)
        return {(a == 1 and b == 1) and 1 or 0}
    end, theme.node)
    andNode:addInput("A")
    andNode:addInput("B")
    andNode:addOutput("Result")
    return andNode
end
-- OR Gate
function createOR()
    local orNode = luis.createElement("graph", "Node", "OR", 4, 4, 10, 19, function(a, b)
        return {(a == 1 or b == 1) and 1 or 0}
    end, theme.node)
    orNode:addInput("A")
    orNode:addInput("B")
    orNode:addOutput("Result")
    return orNode
end
-- XOR Gate
function createXOR()
    local xorNode = luis.createElement("graph", "Node", "XOR", 4, 4, 10, 19, function(a, b)
        return {(a ~= b) and 1 or 0}
    end, theme.node)
    xorNode:addInput("A")
    xorNode:addInput("B")
    xorNode:addOutput("Result")
    return xorNode
end
-- NOT Gate
function createNOT()
    local notNode = luis.createElement("graph", "Node", "NOT", 4, 4, 10, 19, function(a)
        return {(not (a == 1)) and 1 or 0}
    end, theme.node)
    notNode:addInput("A")
    notNode:addOutput("Result")
    return notNode
end
-- NAND Gate
function createNAND()
    local nandNode = luis.createElement("graph", "Node", "NAND", 4, 4, 10, 19, function(a, b)
        return {not (a == 1 and b == 1) and 1 or 0}
    end, theme.node)
    nandNode:addInput("A")
    nandNode:addInput("B")
    nandNode:addOutput("Result")
    return nandNode
end

-- NOR Gate
function createNOR()
	local norNode = luis.createElement("graph", "Node", "NOR", 4, 4, 10, 19, function(a, b)
        return {not (a == 1 or b == 1) and 1 or 0}
	end, theme.node)
	norNode:addInput("A")
	norNode:addInput("B")
    norNode:addOutput("Result")
    return norNode
end

-- XNOR Gate
function createXNOR()
	local xnorNode = luis.createElement("graph", "Node", "XNOR", 4, 4, 10, 19, function(a, b)
        return {(a == b) and 1 or 0}
	end, theme.node)
	xnorNode:addInput("A")
	xnorNode:addInput("B")
    xnorNode:addOutput("Result")
    return xnorNode
end

-- 3-Input Majority Gate
function createMajority()
	local majorityNode = luis.createElement("graph", "Node", "Majority", 4, 4, 10, 19, function(a, b, c)
        local sum = (a == 1 and 1 or 0) + (b == 1 and 1 or 0) + (c == 1 and 1 or 0)
        return {sum >= 2 and 1 or 0}
	end, theme.node)
	majorityNode:addInput("A")
	majorityNode:addInput("B")
	majorityNode:addInput("C")
    majorityNode:addOutput("Result")
    return majorityNode
end

-- Implication Gate
function createImplication()
	local implicationNode = luis.createElement("graph", "Node", "Implication", 4, 4, 10, 19, function(a, b)
        return {( (not a) or b == 1) and 1 or 0}
	end, theme.node)
	implicationNode:addInput("A")
	implicationNode:addInput("B")
    implicationNode:addOutput("Result")
    return implicationNode
end

-- 4-bit Parity Generator
function createParity()
	local parityNode = luis.createElement("graph", "Node", "Parity", 4, 4, 10, 19, function(a, b, c, d)
        local sum = (a == 1 and 1 or 0) + (b == 1 and 1 or 0) + (c == 1 and 1 or 0) + (d == 1 and 1 or 0)
        return {sum % 2 == 1 and 1 or 0}
	end, theme.node)
    parityNode:addInput("A")
    parityNode:addInput("B")
    parityNode:addInput("C")
    parityNode:addInput("D")
    parityNode:addOutput("Parity")
    return parityNode
end

-- 2-to-1 Multiplexer
function createMUX()
	local muxNode = luis.createElement("graph", "Node", "MUX", 4, 4, 10, 19, function(a, b, sel)
        return {s == 1 and a or b}
	end, theme.node)
    muxNode:addInput("A")
    muxNode:addInput("B")
    muxNode:addInput("Select")
    muxNode:addOutput("Output")
    return muxNode
end

-- SR Latch (possibily WRONG implemented!)
function createMUX()
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
    return srLatchNode
end

-- more advanced Nodes
function createADD(value)
	local adderNode = luis.createElement("graph", "Node", "Adder", 4, 4, 10, 10, function(a, b)
		return {(a or 0) + (b or 0)}
	end, theme.node)
	adderNode:addInput("A")
	adderNode:addInput("B")
	adderNode:addOutput("Sum")
    return adderNode
end

function createMUL(value)
	local multiplierNode = luis.createElement("graph", "Node", "Multiplier", 4, 4, 5, 19, function(a, b)
		return {(a or 1) * (b or 1)}
	end, theme.node)
	multiplierNode:addInput("A")
	multiplierNode:addInput("B")
	multiplierNode:addOutput("Product")
    return multiplierNode
end

-- Funktion zum Erstellen einer Konstanten-Node
function createConstant(value)
    local constantNode = luis.createElement("graph", "Node", tostring(value), 2, 2, 10, 19, function()
        return {value}
    end, theme.node)
    constantNode:addOutput("Value")
    return constantNode
end

function love.load()
    luis.newLayer("graph")

--[[
	-- Emty Nodes, no functions

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

	-- Erstellen der benötigten Gatter
	local xor1 = createXOR()
	local xor2 = createXOR()
	local and1 = createAND()
	local and2 = createAND()
	local or1 = createOR()

	-- Erstellen der Eingabe-Nodes)
	local inputValues = { [1]=0, [2]=1, [3]=0}
	local inputA = createConstant(inputValues[1])
	local inputB = createConstant(inputValues[2])
	local inputCin = createConstant(inputValues[3])

	-- Positionieren der Gatter und Eingabe-Nodes
	inputA.position = Vector2D.new(50, 50)
	inputB.position = Vector2D.new(50, 150)
	inputCin.position = Vector2D.new(50, 250)
	xor1.position = Vector2D.new(200, 100)
	xor2.position = Vector2D.new(400, 150)
	and1.position = Vector2D.new(200, 200)
	and2.position = Vector2D.new(400, 250)
	or1.position = Vector2D.new(600, 200)

	-- Verbindungen herstellen
	inputA:connect(1, xor1, 1)  -- Input A zu XOR1 Input A
	inputA:connect(1, and1, 1)  -- Input A zu AND1 Input A
	inputB:connect(1, xor1, 2)  -- Input B zu XOR1 Input B
	inputB:connect(1, and1, 2)  -- Input B zu AND1 Input B
	inputCin:connect(1, xor2, 2)  -- Input Cin zu XOR2 Input B
	inputCin:connect(1, and2, 2)  -- Input Cin zu AND2 Input B
	xor1:connect(1, xor2, 1)  -- XOR1 Output zu XOR2 Input A
	xor1:connect(1, and2, 1)  -- XOR1 Output zu AND2 Input A
	and1:connect(1, or1, 1)   -- AND1 Output zu OR Input A
	and2:connect(1, or1, 2)   -- AND2 Output zu OR Input B

	-- Funktion zum Auslesen der Ausgangswerte
	local function getOutputs()
		return {
			Sum = xor2.outputs[1].value,
			Cout = or1.outputs[1].value
		}
	end

	-- Ausführen der Berechnung
	inputA:execute()
	inputB:execute()
	inputCin:execute()

	-- Ergebnis ausgeben
	local result = getOutputs()
	print("Eingabe: A=" .. inputValues[1], "B=" .. inputValues[2], "Cin=" .. inputValues[3])
	print("Ergebnis: Sum =", result.Sum, "Cout =", result.Cout)

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
