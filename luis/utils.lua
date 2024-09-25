local utf8 = require("utf8")

local utils = {}

function utils.pointInRect(px, py, rx, ry, rw, rh)
    return px > rx and px < rx + rw and py > ry and py < ry + rh
end

-- UTF8 helper function
function utils.utf8_sub(str, start_pos, end_pos)
    if not end_pos then end_pos = -1 end
    local start_byte = utf8.offset(str, start_pos)
    local end_byte = utf8.offset(str, end_pos + 1)
    if end_byte then end_byte = end_byte - 1 end
    return string.sub(str, start_byte, end_byte)
end

return utils
