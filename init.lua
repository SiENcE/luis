local PATH = (...):gsub('%.init$', '')

local luis = require(PATH .. ".luis")

return luis