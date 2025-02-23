local materialTheme = {
    background = {
        color = {0.98, 0.98, 0.98}, -- Light gray background
    },
    text = {
        color = {0.1, 0.1, 0.1}, -- Dark text for contrast
        font = love.graphics.newFont("luis/themes/fonts/Roboto-Regular.ttf", 32),
        align = "left",
    },
    button = {
        color = {0.2, 0.6, 0.9, 1}, -- Material Blue
        hoverColor = {0.35, 0.75, 0.95, 1},
        pressedColor = {0.15, 0.55, 0.85, 1},
        textColor = {1, 1, 1, 1},
		align = "center",
        cornerRadius = 2,
        elevation = 2,
        elevationHover = 4,
        elevationPressed = 8,
        transitionDuration = 0.2,
    },
    slider = {
        trackColor = {0.7, 0.7, 0.7},
        knobColor = {0.2, 0.6, 0.9},
		grabColor = {0.15, 0.55, 0.85, 1},
        knobRadius = 14,
    },
    switch = {
        offColor = {0.7, 0.7, 0.7},
        onColor = {0.2, 0.6, 0.9},
        knobColor = {1, 1, 1},
    },
    checkbox = {
        boxColor = {0.7, 0.7, 0.7},
        checkColor = {0.2, 0.6, 0.9},
        cornerRadius = 2,
    },
    radiobutton = {
        circleColor = {0.7, 0.7, 0.7},
        dotColor = {0.2, 0.6, 0.9},
    },
    grid = {
        color = {0.5, 0.5, 0.5, 0.3},
    },
    progressbar = {
        backgroundColor = {0.2, 0.6, 0.9, 1},
        fillColor = {0.25, 0.65, 0.95, 1},
        borderColor = {0.15, 0.55, 0.85, 1},
    },
    icon = {
        color = {1,1,1,1},
    },
    dropdown = {
        backgroundColor = {0.2, 0.6, 0.9, 1},
        textColor = {1, 1, 1, 1},
		align = "center",
        hoverColor = {0.35, 0.75, 0.95, 1},
        borderColor = {0.15, 0.55, 0.85, 1},
        arrowColor = {1, 1, 1, 1},
        scrollBarColor = {0.5, 0.5, 0.5},
        scrollBarWidth = 10
    },
	textinput = {
		backgroundColor = {0.2, 0.6, 0.9, 1},
		textColor = {1, 1, 1, 1},
		cursorColor = {1, 1, 1, 1},
		selectionColor = {0.25, 0.65, 0.95, 1},
		borderColor = {0.15, 0.55, 0.85, 1},
		borderWidth = 2,
		padding = 5
	},
	flexContainer = {
        backgroundColor = {0.2, 0.6, 0.9, 0.2},
        borderColor = {0.25, 0.65, 0.95, 0.5},
        borderWidth = 2,
        padding = 10,
        handleSize = 10,
        handleColor = {0.15, 0.55, 0.85, 0.5},
		cornerRadius = 1,
	},
}

return materialTheme
