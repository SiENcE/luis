local initLuis = require("luis.init")
-- Direct this to your widgets folder.
local luis = initLuis("examples/complex_ui/widgets")

-- register flux in luis, because the widgets of complex_ui need this
luis.flux = require("examples.3rdparty.flux")

local game = {}
local secretNumber
local attempts = 0
local maxAttempts = 10

function love.load()
	love.window.setMode( luis.baseWidth, luis.baseHeight, { resizable=true } )

    luis.setGridSize(75)

    luis.newLayer("game")
	luis.enableLayer("game")

    -- Title
    luis.createElement("game", "Label", "Guess the Number", 20, 2, 1, 1, "center")

    -- Instructions
    luis.createElement("game", "Label", "Guess a number between 1 and 100", 20, 2, 3, 1, "center")

    -- Input field
    game.input = luis.createElement("game", "TextInput", 10, 2, "",
		function(text)
			-- Validation to ensure only numbers are entered
			game.input:setText(text:match("%d*"))
		end,
		5, 6 )

    -- Guess button
    luis.createElement("game", "Button", "Guess", 5, 2, function() checkGuess() end, function() end, 5, 16)

    -- Feedback label
    game.feedback = luis.createElement("game", "Label", "", 20, 2, 7, 1, "center")

    -- Attempts left
    game.attemptsLabel = luis.createElement("game", "Label", "Attempts left: " .. maxAttempts, 20, 2, 9, 1, "center")

    -- Progress bar
    game.progressBar = luis.createElement("game", "ProgressBar", 0, 20, 1, 11, 1)

    -- New Game button
    luis.createElement("game", "Button", "New Game", 8, 2, function() startNewGame() end, function() end, 13, 7)

    startNewGame()
end

local accumulator = 0
function love.update(dt)
    accumulator = accumulator + dt
    if accumulator >= 1/60 then
        luis.flux.update(accumulator)
        accumulator = 0
    end

	luis.updateScale()

    luis.update(dt)
end

function love.draw()
    luis.draw()
end

function startNewGame()
    secretNumber = love.math.random(1, 100)
    attempts = 0
    game.input:setText("")
    game.feedback.text = "Make your guess!"
    game.attemptsLabel.text = "Attempts left: " .. maxAttempts
    game.progressBar.value = 0
end

function checkGuess()
    local guess = tonumber(game.input:getText())
    if not guess then
        game.feedback.text = "Please enter a valid number!"
        return
    end

    attempts = attempts + 1
    local attemptsLeft = maxAttempts - attempts

    if guess == secretNumber then
        game.feedback.text = "Congratulations! You guessed it in " .. attempts .. " attempts!"
        game.progressBar.value = 1
    elseif attemptsLeft == 0 then
        game.feedback.text = "Game over! The number was " .. secretNumber
        game.progressBar.value = 1
    else
        if guess < secretNumber then
            game.feedback.text = "Too low! Try again."
        else
            game.feedback.text = "Too high! Try again."
        end
    end

    game.attemptsLabel.text = "Attempts left: " .. attemptsLeft
    game.progressBar.value = attempts / maxAttempts

    game.input:setText("")
end

function love.mousepressed(x, y, button, istouch)
    luis.mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    luis.mousereleased(x, y, button, istouch)
end

function love.wheelmoved(x, y)
    luis.wheelmoved(x, y)
end

function love.textinput(text)
    luis.textinput(text)
end

function love.keypressed(key)
    if key == "return" or key == "enter" then
        checkGuess()
	elseif key == "tab" then
        luis.showGrid = not luis.showGrid
        luis.showElementOutlines = not luis.showElementOutlines
        luis.showLayerNames = not luis.showLayerNames
	else
		luis.keypressed(key, scancode, isrepeat)
	end
end

