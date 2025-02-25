-- Convert hex to RGB (0-1 range)
local function hexToRGB(hex)
    return {
        tonumber(hex:sub(1,2), 16) / 255,
        tonumber(hex:sub(3,4), 16) / 255,
        tonumber(hex:sub(5,6), 16) / 255,
		1 -- Alpha is always 1 here
    }
end

-- Alternative color palette
local altColors = {
    burgundy = hexToRGB("a4243b"),
    beige = hexToRGB("d8c99b"),
    orange = hexToRGB("d8973c"),
    rust = hexToRGB("bd632f"),
    navy = hexToRGB("273e47")
}

-- Alternative theme
local alternativeTheme = {
    background = {
        color = altColors.navy,
    },
    text = {
        color = altColors.beige,
        font = love.graphics.newFont("luis/themes/fonts/Monocraft.ttf", 28),
        align = "left",
    },
    button = {
        color = altColors.burgundy,
        hoverColor = altColors.rust,
        pressedColor = {altColors.rust[1]*0.8, altColors.rust[2]*0.8, altColors.rust[3]*0.8, 1},
        textColor = altColors.beige,
		align = "center",
        cornerRadius = 4,
        elevation = 4,
        elevationHover = 8,
        elevationPressed = 12,
        transitionDuration = 0.25,
    },
    slider = {
        trackColor = altColors.beige,
        knobColor = altColors.orange,
		grabColor = {altColors.rust[1]*0.8, altColors.rust[2]*0.8, altColors.rust[3]*0.8, 1},
        knobRadius = 10,
    },
    switch = {
        offColor = altColors.burgundy,
        onColor = altColors.orange,
        knobColor = altColors.beige,
    },
    checkbox = {
        boxColor = altColors.burgundy,
        checkColor = altColors.orange,
		cornerRadius = 4,
    },
    radiobutton = {
        circleColor = altColors.burgundy,
        dotColor = altColors.orange,
    },
    grid = {
        color = {altColors.beige[1], altColors.beige[2], altColors.beige[3], 0.3},
    },
    progressbar = {
        backgroundColor = altColors.burgundy,
        fillColor = altColors.orange,
        borderColor = altColors.beige,
    },
    icon = {
        color = altColors.beige,
    },
    dropdown = {
        backgroundColor = altColors.burgundy,
        textColor = altColors.beige,
		align = "left",
        hoverColor = altColors.rust,
        borderColor = altColors.orange,
        arrowColor = altColors.beige,
        scrollBarColor = {0.5, 0.5, 0.5},
        scrollBarWidth = 10
    },
	textinput = {
		backgroundColor = altColors.navy,
		textColor = altColors.beige,
		cursorColor = altColors.beige,
		selectionColor = altColors.rust,
		borderColor = altColors.orange,
		borderWidth = 2,
		padding = 5
	},
	flexContainer = {
        backgroundColor = altColors.burgundy,
        borderColor = altColors.orange,
        borderWidth = 2,
        padding = 10,
        handleSize = 10,
        handleColor = altColors.rust,
		cornerRadius = 1,
	},
}

return alternativeTheme
