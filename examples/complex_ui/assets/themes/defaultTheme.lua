-- Default theme
local defaultTheme = {
    background = {
        color = {0.1, 0.1, 0.1},
    },
    text = {
        color = {1, 1, 1},
        font = love.graphics.newFont(32, "normal"),
        align = "left",
    },
    button = {
        color = {0.2, 0.2, 0.2, 1},
        hoverColor = {0.25, 0.25, 0.25, 1},
        pressedColor = {0.15, 0.15, 0.15, 1},
        textColor = {1, 1, 1, 1},
		align = "center",
        cornerRadius = 4,
        elevation = 4,
        elevationHover = 8,
        elevationPressed = 12,
        transitionDuration = 0.25,
    },
    slider = {
        trackColor = {0.4, 0.4, 0.4},
        knobColor = {0.6, 0.6, 0.6},
		grabColor = {0.8, 0.8, 0.8},
        knobRadius = 10,
    },
    switch = {
        offColor = {0.5, 0.5, 0.5},
        onColor = {0, 0.7, 0},
        knobColor = {1, 1, 1},
    },
    checkbox = {
        boxColor = {0.4, 0.4, 0.4},
        checkColor = {0, 0.7, 0},
        cornerRadius = 4,
    },
    radiobutton = {
        circleColor = {0.4, 0.4, 0.4},
        dotColor = {0, 0.7, 0},
    },
    grid = {
        color = {0.5, 0.5, 0.5, 0.3},
    },
    progressbar = {
        backgroundColor = {0.2, 0.2, 0.2, 1},
        fillColor = {0.15, 0.15, 0.15, 1},
        borderColor = {0.25, 0.25, 0.25, 1},
    },
    icon = {
        color = {1, 1, 1, 1},
    },
    dropdown = {
        backgroundColor = {0.2, 0.2, 0.2, 1},
        textColor = {1, 1, 1},
		align = "left",
        hoverColor = {0.25, 0.25, 0.25, 1},
        borderColor = {0.15, 0.15, 0.15, 1},
        arrowColor = {1, 1, 1},
        scrollBarColor = {0.5, 0.5, 0.5},
        scrollBarWidth = 10
    },
	textinput = {
		backgroundColor = {0.2, 0.2, 0.2},
		textColor = {1, 1, 1},
		cursorColor = {1, 1, 1},
		selectionColor = {0.3, 0.7, 1, 0.5},
		borderColor = {0.5, 0.5, 0.5},
		borderWidth = 2,
		padding = 5
	},
	flexContainer = {
        backgroundColor = {0.2, 0.2, 0.2, 0.5},
        borderColor = {0.3, 0.3, 0.3, 1},
        borderWidth = 2,
        padding = 10,
        handleSize = 20,
        handleColor = {0.5, 0.5, 0.5, 1},
		cornerRadius = 1,
	},
}

return defaultTheme
