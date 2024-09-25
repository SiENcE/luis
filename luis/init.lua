local luis = require("luis.core")
local lfs = love.filesystem

-- Load Vector2D
luis.Vector2D = require("luis.vector")
luis.flux = require("luis.3rdparty.flux")

-- Dynamically load widgets
luis.widgets = {}
local widget_files = lfs.getDirectoryItems("luis/widgets")

for _, file in ipairs(widget_files) do
    local widget_name = file:match("(.+)%.lua$")
    if widget_name then
        local widget = require("luis.widgets." .. widget_name)
		widget.setluis(luis)  -- Pass the core library to the widget module
        luis.widgets[widget_name] = widget
        luis["new" .. widget_name:gsub("^%l", string.upper)] = widget.new
    end
end

return luis
