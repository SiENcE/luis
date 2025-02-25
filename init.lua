local function initLuis(widgetPath)
    local luis = require("luis.core")
    local lfs = love.filesystem

    -- Set default widget path if not provided
    widgetPath = widgetPath or "luis/widgets"

    -- Ensure the widget path exists
    if not lfs.getInfo(widgetPath, "directory") then
        --error("Widget directory not found: " .. widgetPath)
		print("Widget directory not found: " .. widgetPath)
    end

    -- Dynamically load widgets
    luis.widgets = {}
    local widget_files = lfs.getDirectoryItems(widgetPath)

    for _, file in ipairs(widget_files) do
        local widget_name = file:match("(.+)%.lua$")
        if widget_name then
            local widget = require(widgetPath:gsub("/", ".") .. "." .. widget_name)
            widget.setluis(luis)  -- Pass the core library to the widget module
            luis.widgets[widget_name] = widget
            luis["new" .. widget_name:gsub("^%l", string.upper)] = widget.new
        end
    end

    return luis
end

return initLuis