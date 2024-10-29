-- Original author: https://github.com/trubblegum
-- This is a modified version of https://github.com/trubblegum/Gspot/blob/cf0a49d7d2073686d7ddb32a4fa04e90593d36c4/Gspot.lua
-- The original program did not include a copyright notice.
-- Modifications © Copyright 2015-2016, 2018, 2021 Pedro Gimeno Fortea.
--
-- This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
-- Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
-- 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
-- 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
-- 3. This notice may not be removed or altered from any source distribution.

-- Simplify version checking
local version = love._version_major * 10000 + love._version_minor * 100 + love._version_revision

-- Return the position of the first byte of the given UTF-8 char.
local function utf8char_begin(s, idx)
	-- Precondition:
	--assert(idx >= 1 and idx <= #s + 1)
	local byte = s:byte(idx)
	while byte and byte >= 0x80 and byte < 0xC0 do
		idx = idx - 1
		byte = s:byte(idx)
	end
	-- Postcondition:
	--assert(idx >= 1 and idx <= #s + 1)
	return idx
end

-- Return the position immediately after the current UTF-8 char.
local function utf8char_after(s, idx)
	-- Precondition:
	--assert(idx >= 1 and idx <= #s + 1)
	if idx <= #s then
		idx = idx + 1
		local byte = s:byte(idx)
		while byte and byte >= 0x80 and byte < 0xC0 do
			idx = idx + 1
			byte = s:byte(idx)
		end
	end
	-- Postcondition:
	--assert(idx >= 1 and idx <= #s + 1)
	return idx
end

-- Return the number of UTF-8 characters on the string
local function utf8len(s)
	local p = 0
	for i=1,string.len(s) do
		p = (s:byte(i) >= 0x80 and s:byte(i) < 0xC0) and p or p+1
	end
	return p
end

-- Apply a scissor to the current scissor (intersect the rects)
local clipScissor
if version < 001000 then
	function clipScissor(nx, ny, nw, nh)
		local ox, oy, ow, oh = love.graphics.getScissor()
		if ox then
			-- Intersect both rects
			nw = nx + nw
			nh = ny + nh
			nx, ny = math.max(nx, ox), math.max(ny, oy)
			nw = math.max(0, math.min(nw, ox + ow) - nx)
			nh = math.max(0, math.min(nh, oy + oh) - ny)
		end
		-- Set new scissor
		love.graphics.setScissor(nx, ny, nw, nh)
		-- Return old scissor
		return ox, oy, ow, oh
	end
else
	function clipScissor(nx, ny, nw, nh)
		local ox, oy, ow, oh = love.graphics.getScissor()
		love.graphics.intersectScissor(nx, ny, nw, nh)
		-- Return old scissor
		return ox, oy, ow, oh
	end
end

local DIV = version >= 110000 and 255 or 1

-- 11.0 compatibility
local compat_setColor, setColor, fileExists
if version < 110000 then
	setColor = love.graphics.setColor
	fileExists = love.filesystem.exists
else
	compat_setColor = function(...)
		local n = select('#', ...)
		if n >= 3 then
			local r, g, b, a = ...
			if n >= 4 then
				love.graphics.setColor(r / DIV, g / DIV, b / DIV, a / DIV)
			else
				love.graphics.setColor(r / DIV, g / DIV, b / DIV)
			end
			return
		end
		assert(n == 1, "Invalid number of parameters in setColor()")
		local t = ...
		assert(type(t) == "table", "setColor() only accepts a table parameter")
		if #t >= 4 then
			love.graphics.setColor(t[1] / DIV, t[2] / DIV, t[3] / DIV, t[4] / DIV)
		else
			love.graphics.setColor(t[1] / DIV, t[2] / DIV, t[3] / DIV)
		end
	end

	setColor = compat_setColor

	local info = {type = false, size = false, modtime = false}
	fileExists = function(path)
		return love.filesystem.getInfo(path, info) ~= nil
			and (info.type == "file" or info.type == "symlink")
	end
end

-- Deal with love.mouse API changes in 0.10
local mouseL = version >= 001000 and 1 or 'l'
local mouseR = version >= 001000 and 2 or 'r'

-- 0.10.0 blurs text if rendered on fractional coordinates
-- 0.9 redefines love.graphics.print[f] after first call.
-- To prevent caching the wrong version, we call it now with no text.
love.graphics.print("")
love.graphics.printf("", 0, 0, 0)
local lgprint = version < 001000 and love.graphics.print or function(text, x, y, ...) return love.graphics.print(text, math.floor(x+0.5), math.floor(y+0.5), ...) end
local lgprintf = version < 001000 and love.graphics.printf or function(text, x, y, ...) return love.graphics.printf(text, math.floor(x+0.5), math.floor(y+0.5), ...) end

local Gspot = {}


Gspot.style = { -- see Gspot.setComponentMax for colour values
	unit = 16,
	font = love.graphics.newFont(10),
	fg = {},
	bg = {},
	labelfg = nil, -- defaults to fg when absent
	default = {},
	hilite = {},
	focus = {},
}

Gspot.setComponentMax = function(this, value)
	-- 'this' isn't used at all here - it modifies the base class instead.
	assert(tostring(value) == "255" or value == "native", "Gspot:setColorRange must be 255 or \"native\"")
	if (Gspot.nativeColorMax or false) ~= (value == "native") then
		local st = Gspot.style
		st.fg[1],st.fg[2],st.fg[3],st.fg[4] = 255,255,255,255
		st.bg[1],st.bg[2],st.bg[3],st.bg[4] =  64, 64, 64,255
		st.default[1],st.default[2],st.default[3],st.default[4] = 96,96,96,255
		st.hilite[1],st.hilite[2],st.hilite[3],st.hilite[4] = 128,128,128,255
		st.focus[1],st.focus[2],st.focus[3],st.focus[4] = 160,160,160,255
		if value == "native" then
			Gspot.nativeColorMax = true
			for i = 1, 4 do
				st.fg[i] = st.fg[i] / DIV
				st.bg[i] = st.bg[i] / DIV
				st.default[i] = st.default[i] / DIV
				st.hilite[i] = st.hilite[i] / DIV
				st.focus[i] = st.focus[i] / DIV
			end
			setColor = love.graphics.setColor
		else
			Gspot.nativeColorMax = nil
			setColor = compat_setColor
		end
	end
	return Gspot:load()
end

Gspot.load = function(this)
	local def = {
		style = {
			unit = this.style.unit,
			font = this.style.font,
			fg = this.style.fg,
			bg = this.style.bg,
			labelfg = this.style.labelfg,
			default = this.style.default,
			hilite = this.style.hilite,
			focus = this.style.focus,
			hs = this.style.hs or this.style.unit,
		},
		dblclickinterval = 0.25,
		-- no messin' past here
		maxid = 0, -- legacy
		mem = {},
		elements = {},
		mousein = nil,
		focus = nil,
		drag = nil,
		orepeat = nil,
	}
	def.mousedt = def.dblclickinterval -- Double click timer (make it expired)
	return setmetatable(def, {__index = this, __call = this.load})
end

Gspot.update = function(this, dt)
	this.mousedt = this.mousedt + dt
	local mouse = {}
	mouse.x, mouse.y = this:getmouse()
	local mousein = this.mousein
	this.mousein = false
	this.mouseover = false
	if this.drag then
		local element = this.drag
		if love.mouse.isDown(mouseL) then
			if type(element.drag) == 'function' then element:drag(mouse.x, mouse.y)
			else
				element.pos.y = mouse.y - element.offset.y
				element.pos.x = mouse.x - element.offset.x
			end
		elseif love.mouse.isDown(mouseR) then
			if type(element.rdrag) == 'function' then element:rdrag(mouse.x, mouse.y)
			else
				element.pos.y = mouse.y - element.offset.y
				element.pos.x = mouse.x - element.offset.x
			end
		end
		for i, bucket in ipairs(this.elements) do
			if bucket ~= element and bucket:containspoint(mouse) then this.mouseover = bucket end
		end
	end
	for i = #this.elements, 1, -1 do
		local element = this.elements[i]
		if element.display then
			if element:containspoint(mouse) then
				if element.parent and element.parent:type() == 'Gspot.element.scrollgroup' and element ~= element.parent.scrollv and element ~= element.parent.scrollh then
					if element.parent:containspoint(mouse) then this.mousein = element break end
				else this.mousein = element break end
			end
		end
	end
	for i = #this.elements, 1, -1 do
		local element = this.elements[i]
		if element.display then
			if element.update then
				if element.updateinterval then
					element.dt = element.dt + dt
					if element.dt >= element.updateinterval then
						element.dt = 0
						element:update(dt)
					end
				else element:update(dt) end
			end
		end
	end
	if this.mousein ~= mousein then
		if this.mousein and this.mousein.enter then this.mousein:enter() end
		if mousein and mousein.leave then mousein:leave() end
	end
end

Gspot.draw = function(this)
	local ostyle_font = love.graphics.getFont()
	local ostyle_r, ostyle_g, ostyle_b, ostyle_a = love.graphics.getColor()
	local ostyle_scissor_x, ostyle_scissor_y, ostyle_scissor_w, ostyle_scissor_h = love.graphics.getScissor()
	for i, element in ipairs(this.elements) do
		if element.display then
			local pos, scissor = element:getpos()
			if scissor then clipScissor(scissor.x, scissor.y, scissor.w, scissor.h) end
			love.graphics.setFont(element.style.font)
			element:draw(pos)
			love.graphics.setScissor(ostyle_scissor_x, ostyle_scissor_y, ostyle_scissor_w, ostyle_scissor_h)
		end
	end
	if this.mousein and this.mousein.tip then
		local element = this.mousein
		local tipfont = this.style.font
		local tipw, tiph = tipfont:getWidth(element.tip), tipfont:getHeight()
		local scrw, scrh = love.graphics.getDimensions()
		local pos = element:getpos()
		local _, countlf = element.tip:gsub("\n", "\n")
		local tippos = {x = pos.x + (this.style.unit / 2), y = pos.y + (this.style.unit / 2), w = tipw + this.style.unit, h = this.style.unit / 4 + tiph * (countlf + 1)}
		love.graphics.setFont(tipfont) -- use the default font
		setColor(this.style.bg)
		this.mousein:rect({x = math.max(0, math.min(tippos.x, scrw - (tipw + this.style.unit))), y = math.max(0, math.min(tippos.y, scrh - this.style.unit)), w = tippos.w, h = tippos.h})
		setColor(this.style.fg)
		lgprint(element.tip, math.max(this.style.unit / 2, math.min(tippos.x + (this.style.unit / 2), scrw - (tipw + (this.style.unit / 2)))), math.max((this.style.unit - tiph) / 2, math.min(tippos.y + ((this.style.unit - tiph) / 2), (scrh - this.style.unit) + ((this.style.unit - tiph) / 2))))
	end
	love.graphics.setFont(ostyle_font)
	love.graphics.setColor(ostyle_r, ostyle_g, ostyle_b, ostyle_a)
end

Gspot.mousepress = function(this, x, y, button)
	this:unfocus()
	local mousedt = this.mousedt
	this.mousedt = this.dblclickinterval -- expire unless clicked
	if this.mousein then
		local element = this.mousein
		if element.elementtype ~= 'hidden' then element:getparent():setlevel() end
		if button == mouseL then
			if element.drag then
				this.drag = element
				element.offset = {x = x - element:getpos().x, y = y - element:getpos().y}
			end
			if mousedt < this.dblclickinterval and element.dblclick then
				element:dblclick(x, y, button)
			else
				if element.click then element:click(x, y) end
				this.mousedt = 0
			end
		elseif button == mouseR and element.rclick then element:rclick(x, y)
		elseif button == 'wu' and element.wheelup then element:wheelup(x, y)
		elseif button == 'wd' and element.wheeldown then element:wheeldown(x, y)
		end
	end
end

Gspot.mouserelease = function(this, x, y, button)
	if this.drag then
		local element = this.drag
		if button == mouseR then
			if element.rdrop then element:rdrop(this.mouseover) end
			if this.mouseover and this.mouseover.rcatch then this.mouseover:rcatch(element.id) end
		else
			if element.drop then element:drop(this.mouseover) end
			if this.mouseover and this.mouseover.catch then this.mouseover:catch(element) end
		end
	end
	this.drag = nil
end

Gspot.mousewheel = function(this, x, y)
	if y ~= 0 and this.mousein then
		local element = this.mousein
		local call = y > 0 and element.wheelup or element.wheeldown
		if call then
			local mx, my = this.getmouse()
			call(element, mx, my)
		end
	end
end

Gspot.keypress = function(this, key)
	if this.focus then
		if (key == 'return' or key == 'kpenter') and this.focus.done then this.focus:done() end
		if this.focus and this.focus.keypress then this.focus:keypress(key) end
	end
end

Gspot.textinput = function(this, key)
	-- Due to a bug in love or some library, textinput can give us
	-- invalid UTF-8
	-- (for example, on Linux with Spanish keyboard:
	--  AltGr + Shift + "+" generates "\xAF" which does not
	--  start with \xC0-\xFF)
	if not key or key == "" or key:byte(1) >= 0x80 and key:byte(1) < 0xC0 then return end
	if this.focus and this.focus.textinput then this.focus:textinput(key) end
end

Gspot.getmouse = function(this)
	return love.mouse.getPosition()
end

-- legacy
Gspot.newid = function(this)
	this.maxid = this.maxid + 1
	return this.maxid
end
-- /legacy

Gspot.clone = function(this, t)
	local c = {}
	for i, v in pairs(t) do
		if v then
			if type(v) == 'table' then c[i] = this:clone(v) else c[i] = v end
		end
	end
	return setmetatable(c, getmetatable(t))
end

Gspot.getindex = function(tab, val)
	for i, v in pairs(tab) do if v == val then return i end end
end

Gspot.add = function(this, element)
	element.id = this:newid() -- legacy
	table.insert(this.elements, element)
	if element.parent then element.parent:addchild(element) end
	return element
end

Gspot.rem = function(this, element)
	if element.parent then element.parent:remchild(element) end
	while #element.children > 0 do
		for i, child in ipairs(element.children) do this:rem(child) end
	end
	if element == this.mousein then this.mousein = nil end
	if element == this.drag then this.drag = nil end
	if element == this.focus then this:unfocus() end
	return table.remove(this.elements, this.getindex(this.elements, element))
end

Gspot.setfocus = function(this, element)
	if element then
		this.focus = element
		local rep = element.keyrepeat
		if rep ~= nil then
			if element.keydelay then -- legacy stuff
				rep = element.keydelay > 0
			elseif rep == 0 then
				rep = false
			end
			this.orepeat = love.keyboard.hasKeyRepeat()
			love.keyboard.setKeyRepeat(rep)
		end
	end
end

Gspot.unfocus = function(this)
	this.focus = nil
	if this.orepeat ~= nil then
		love.keyboard.setKeyRepeat(this.orepeat)
		this.orepeat = nil
	end
end

local pos = {
	load = function(this, Gspot, t)
		assert(type(t) == 'table' or not t, 'invalid pos constructor argument : must be of type table or nil')
		t = t or {}
		t = t.pos or t
		local circ = false
		local pos = {}
		if t.r or t[5] or (#t == 3 and not t.w) then
			pos.r = t.r or t[5] or t[3]
			circ = true
			pos.w = t.w or t[3] or pos.r * 2
			pos.h = t.h or t[4] or pos.r * 2
		else
			pos.w = t.w or t[3] or Gspot.style.unit
			pos.h = t.h or t[4] or Gspot.style.unit
		end
		pos.x = t.x or t[1] or 0
		pos.y = t.y or t[2] or 0
		return setmetatable(pos, this), circ
	end,
	__unm = function(a)
		local c = {x = a.x, y = a.y, w = a.w, h = a.h, r = a.r}
		c.x = 0 - a.x
		c.y = 0 - a.y
		return setmetatable(c, getmetatable(a))
	end,
	__add = function(a, b)
		local c = {x = a.x, y = a.y, w = a.w, h = a.h, r = a.r}
		local d
		local success, e = pcall(function(b) return b.x end, b)
		if success then d = e else d = b end
		c.x = a.x + d
		local success, e = pcall(function(b) return b.y end, b)
		if success then d = e else d = b end
		c.y = a.y + d
		return setmetatable(c, getmetatable(a))
	end,
	__sub = function(a, b)
		local c = {x = a.x, y = a.y, w = a.w, h = a.h, r = a.r}
		local d
		local success, e = pcall(function(b) return b.x end, b)
		if success then d = e else d = b end
		c.x = a.x - d
		local success, e = pcall(function(b) return b.y end, b)
		if success then d = e else d = b end
		c.y = a.y - d
		return setmetatable(c, getmetatable(a))
	end,
	__mul = function(a, b)
		local c = {x = a.x, y = a.y, w = a.w, h = a.h, r = a.r}
		local d
		local success, e = pcall(function(b) return b.x end, b)
		if success then d = e else d = b end
		c.x = a.x * d
		local success, e = pcall(function(b) return b.y end, b)
		if success then d = e else d = b end
		c.y = c.y * d
		return setmetatable(c, getmetatable(a))
	end,
	__div = function(a, b)
		local c = {x = a.x, y = a.y, w = a.w, h = a.h, r = a.r}
		local d
		local success, e = pcall(function(b) return b.x end, b)
		if success then d = e else d = b end
		c.x = a.x / d
		local success, e = pcall(function(b) return b.y end, b)
		if success then d = e else d = b end
		c.y = a.y / d
		return setmetatable(c, getmetatable(a))
	end,
	__pow = function(a, b)
		local c = {x = a.x, y = a.y, w = a.w, h = a.h, r = a.r}
		local d
		local success, e = pcall(function(b) return b.x end, b)
		if success then d = e else d = b end
		c.x = a.x ^ d
		local success, e = pcall(function(b) return b.y end, b)
		if success then d = e else d = b end
		c.y = a.y ^ d
		return setmetatable(c, getmetatable(a))
	end,
	__tostring = function(this) return this:type() .. ' : x = ' .. tostring(this.x) .. ', y = ' .. tostring(this.y) .. ', w = ' .. tostring(this.w) .. ', h = ' .. tostring(this.h) .. ', r = ' .. tostring(this.r) end,
	__index = {
		type = function(this) return 'Gspot.pos' end,
	},
}
Gspot.pos = setmetatable(pos, {__call = pos.load})

Gspot.util = {
	setshape = function(this, shape)
		assert(shape == 'circle' or shape == 'rect' or not shape, 'shape must be "rect" or "circle" or nil')
		this.shape = shape
		if this.shape == 'circle' and not this.pos.r then this.pos.r = this.pos.w / 2 end
	end,

	drawshape = function(this, pos)
		pos = pos or this:getpos()
		if this.shape == 'circle' then
			local segments = this.segments or math.max(pos.r, 8)
			love.graphics.circle('fill', pos.x + pos.r, pos.y + pos.r, pos.r, segments)
		else
			this:rect(pos)
		end
	end,

	rect = function(this, pos, mode)
		pos = this.Gspot:pos(pos.pos or pos or this.pos)
		assert(pos:type() == 'Gspot.pos')
		mode = mode or 'fill'
		love.graphics.rectangle(mode, pos.x, pos.y, pos.w, pos.h)
	end,

	setimage = function(this, img)
		if type(img) == 'string' and fileExists(img) then img = love.graphics.newImage(img) end
		if pcall(function(img) return img:type() == 'Image' end, img) then this.img = img
		else this.img = nil end
	end,

	drawimg = function(this, pos)
		local r, g, b, a = love.graphics.getColor()
		setColor(255 / DIV, 255 / DIV, 255 / DIV, 255 / DIV)
		love.graphics.draw(this.img, (pos.x + (pos.w / 2)) - (this.img:getWidth()) / 2, (pos.y + (pos.h / 2)) - (this.img:getHeight() / 2))
		love.graphics.setColor(r, g, b, a)
	end,

	setfont = function(this, font, size)
		if type(font) == 'string' and fileExists(font) then
			font = love.graphics.newFont(font, size)
		elseif type(font) == 'number' then
			font = love.graphics.newFont(font)
		end
		if type(font) == 'userdata' and type(font.type) == 'function' and font:type() == 'Font' then
			this.style.font = font
			if this.autosize then
				this.pos.w = font:getWidth(this.label) + this.style.unit / 2
				this.pos.h = font:getHeight() + this.style.unit / 4
			end
		else
			this.style.font = nil
			this.style = this.Gspot:clone(this.style)
		end
	end,

	getpos = function(this, scissor)
		local pos = this.Gspot:pos(this)
		if this.parent then
			local ppos = 0
			ppos, scissor = this.parent:getpos()
			pos = pos + ppos
			if this.parent:type() == 'Gspot.element.scrollgroup' and this ~= this.parent.scrollv and this ~= this.parent.scrollh then
				scissor = this.Gspot:clone(this.parent:getpos())
				if this.parent.scrollv then pos.y = pos.y - this.parent.scrollv.values.current end
				if this.parent.scrollh then pos.x = pos.x - this.parent.scrollh.values.current end
			end
		end
		return pos, scissor
	end,

	containspoint = function(this, point)
		local contains = true
		local pos = point.pos or point
		local thispos, scissor = this:getpos()
		if this.shape == 'circle' then
			if not this.withinradius(pos, thispos + this.pos.r, scissor) then contains = false end
		elseif not this.withinrect(pos, thispos, scissor) then
			contains = false
		end
		return contains
	end,

	withinrect = function(pos, rect, scissor)
		pos = pos.pos or pos
		rect = rect.pos or rect
		if scissor then
			return pos.x >= rect.x and pos.x < (rect.x + rect.w) and pos.y >= rect.y and pos.y < (rect.y + rect.h)
				and pos.x >= scissor.x and pos.x < scissor.x + scissor.w and pos.y >= scissor.y and pos.y < scissor.y + scissor.h
		end
		return pos.x >= rect.x and pos.x < (rect.x + rect.w) and pos.y >= rect.y and pos.y < (rect.y + rect.h)
	end,

	getdist = function(pos, target)
		pos = pos.pos or pos
		target = target.pos or target
		return math.sqrt((pos.x-target.x) * (pos.x-target.x) + (pos.y-target.y) * (pos.y-target.y))
	end,

	withinradius = function(pos, circ, scissor)
		pos = pos.pos or pos
		circ = circ.pos or circ
		if (pos.x - circ.x) * (pos.x - circ.x) + (pos.y - circ.y) * (pos.y - circ.y) < circ.r * circ.r then
			if scissor then
				return pos.x >= scissor.x and pos.x < scissor.x + scissor.w and pos.y >= scissor.y and pos.y < scissor.y + scissor.h
			else
				return true
			end
		end
		return false
	end,

	getparent = function(this)
		if this.parent then return this.parent:getparent()
		else return this end
	end,

	getmaxw = function(this)
		local maxw = 0
		for i, child in ipairs(this.children) do
			if (child ~= this.scrollv and child ~= this.scrollh) and child.pos.x + child.pos.w > maxw then maxw = child.pos.x + child.pos.w end
		end
		return maxw
	end,

	getmaxh = function(this)
		local maxh = 0
		for i, child in ipairs(this.children) do
			if (child ~= this.scrollv and child ~= this.scrollh) and child.pos.y + child.pos.h > maxh then maxh = child.pos.y + child.pos.h end
		end
		return maxh
	end,

	addchild = function(this, child, autostack)
		if autostack then
			if type(autostack) == 'number' or autostack == 'grid' then
				local limitx = (type(autostack) == 'number' and autostack) or this.pos.w
				local maxx, maxy = 0, 0
				for i, element in ipairs(this.children) do
					if element ~= this.scrollh and element ~= this.scrollv then
						if element.pos.y > maxy then maxy = element.pos.y end
						if element.pos.x + element.pos.w + child.pos.w <= limitx then maxx = element.pos.x + element.pos.w
						else maxx, maxy = 0, element.pos.y + element.pos.h end
					end
				end
				child.pos.x, child.pos.y = maxx, maxy
			elseif autostack == 'horizontal' then child.pos.x = this:getmaxw()
			elseif autostack == 'vertical' then child.pos.y = this:getmaxh() end
		end

		table.insert(this.children, child)
		child.parent = this
		child.style = this.Gspot:clone(child.style)
		setmetatable(child.style, {__index = this.style})
		if this.scrollh then this.scrollh.values.max = math.max(this:getmaxw() - this.pos.w, 0) end
		if this.scrollv then this.scrollv.values.max = math.max(this:getmaxh() - this.pos.h, 0) end
		return child
	end,

	remchild = function(this, child)
		child.pos = child:getpos()
		table.remove(this.children, this.Gspot.getindex(this.children, child))
		child.parent = nil
		setmetatable(child.style, {__index = this.Gspot.style})
	end,

	replace = function(this, replacement)
		this.Gspot.elements[this.Gspot.getindex(this.Gspot.elements, this)] = replacement
		return replacement
	end,

	getlevel = function(this)
		for i, element in pairs(this.Gspot.elements) do
			if element == this then return i end
		end
	end,

	setlevel = function(this, level)
		if level then
			table.insert(this.Gspot.elements, level, table.remove(this.Gspot.elements, this.Gspot.getindex(this.Gspot.elements, this)))
			for i, child in ipairs(this.children) do child:setlevel(level + i) end
		else
			table.insert(this.Gspot.elements, table.remove(this.Gspot.elements, this.Gspot.getindex(this.Gspot.elements, this)))
			for i, child in ipairs(this.children) do child:setlevel() end
		end
	end,

	show = function(this)
		this.display = true
		for i, child in pairs(this.children) do child:show() end
	end,

	hide = function(this)
		this.display = false
		for i, child in pairs(this.children) do child:hide() end
	end,

	focus = function(this)
		this.Gspot:setfocus(this)
	end,

	type = function(this)
		return 'Gspot.element.'..this.elementtype
	end,
}

Gspot.element = {
	load = function(this, Gspot, elementtype, label, pos, parent)
		assert(Gspot[elementtype], 'invalid element constructor argument : element.elementtype must be an existing element type')
		assert(type(label) == 'string' or type(label) == 'number' or not label, 'invalid element constructor argument : element.label must be of type string or number')
		assert(type(pos) == 'table' or not pos, 'invalid element constructor argument : element.pos must be of type table or nil')
		assert((type(parent) == 'table' and parent:type():sub(1, 13) == 'Gspot.element') or not parent, 'invalid element constructor argument : element.parent must be of type element or nil')
		local pos, circ = Gspot:pos(pos)
		local element = {elementtype = elementtype, label = label, pos = pos, display = true, dt = 0, parent = parent, children = {}, Gspot = Gspot}
		if circ then element.shape = 'circle' else element.shape = 'rect' end
		if parent then element.style = setmetatable({}, {__index = parent.style})
		else element.style = setmetatable({}, {__index = Gspot.style}) end
		return setmetatable(element, {__index = Gspot[elementtype], __tostring = function(this) return this:type() .. ' (' .. this:getlevel() .. ')' end})
	end,
}
setmetatable(Gspot.element, {__call = Gspot.element.load})

Gspot.scrollvalues = function(this, values)
	local val = {}
	val.min = values.min or values[1] or 0
	val.max = values.max or values[2] or 0
	val.current = values.current or values[3] or val.min
	val.step = values.step or values[4] or this.style.unit
	val.axis = values.axis or values[5] or 'vertical'
	return val
end

-- elements

Gspot.group = {
	load = function(this, Gspot, label, pos, parent)
		return Gspot:add(Gspot:element('group', label, pos, parent))
	end,
	draw = function(this, pos)
		setColor(this.style.bg)
		this:drawshape(pos)
		if this.label then
			setColor(this.style.labelfg or this.style.fg)
			lgprint(this.label, pos.x + ((pos.w - this.style.font:getWidth(this.label)) / 2), pos.y + ((this.style.unit - this.style.font:getHeight()) / 2))
		end
	end,
}
setmetatable(Gspot.group, {__index = Gspot.util, __call = Gspot.group.load})

Gspot.collapsegroup = {
	load = function(this, Gspot, label, pos, parent)
		local element = Gspot:group(label, pos, parent)
		element.view = true
		element.orig = Gspot:clone(element.pos)
		element.toggle = function(this)
			this.view = not element.view
			this.pos.h = (this.view and this.orig.h) or this.style.unit
			for i, child in ipairs(this.children) do
				if child ~= this.control then
					if this.view then child:show() else child:hide() end
				end
			end
			this.control.label = (this.view and '-') or '='
		end
		element.control = Gspot:button('-', {element.pos.w - element.style.unit}, element)
		element.control.click = function(this)
			this.parent:toggle()
		end
		return element
	end,
}
setmetatable(Gspot.collapsegroup, {__index = Gspot.util, __call = Gspot.collapsegroup.load})

Gspot.text = {
	load = function(this, Gspot, label, pos, parent, autosize)
		local element = Gspot:element('text', label, pos, parent)
		if autosize then
			element.pos.w = element.style.font:getWidth(label) + (element.style.unit / 2)
			element.autosize = autosize
		end
		element:setfont(element.style.font)
		return Gspot:add(element)
	end,
	setfont = function(this, font, size)
		this.Gspot.util.setfont(this, font, size)
		if not this.autosize then -- height needs adjustment regardless
			local width, lines = this.style.font:getWrap(this.label, this.pos.w - (this.style.unit / 2))
			if type(lines) == "table" then lines = #lines end
			lines = math.max(lines, 1)
			this.pos.h = this.style.font:getHeight() * lines + this.style.unit / 4
		end
	end,
	draw = function(this, pos)
		setColor(this.style.labelfg or this.style.fg)
		if this.autosize then lgprint(this.label, pos.x + (this.style.unit / 4), pos.y + (this.style.unit / 8))
		else lgprintf(this.label, pos.x + (this.style.unit / 4), pos.y + (this.style.unit / 8), (this.autosize and pos.w) or pos.w - (this.style.unit / 2), 'left') end
	end,
}
setmetatable(Gspot.text, {__index = Gspot.util, __call = Gspot.text.load})

Gspot.typetext = {
	load = function(this, Gspot, label, pos, parent, autosize)
		local element = Gspot:text('', pos, parent, autosize)
		element.values = {text = label, cursor = 1}
		element.updateinterval = 0.1
		element.update = function(this, dt)
			this.values.cursor = utf8char_after(this.values.text, this.values.cursor + 1) - 1
			this.label = this.values.text:sub(1, this.values.cursor)
		end
		return Gspot:add(element)
	end,
}
setmetatable(Gspot.typetext, {__index = Gspot.util, __call = Gspot.typetext.load})

Gspot.image = {
	load = function(this, Gspot, label, pos, parent, img)
		local element = Gspot:element('image', label, pos, parent)
		element:setimage(img)
		return Gspot:add(element)
	end,
	setimage = function(this, img)
		this.Gspot.util.setimage(this, img)
		if this.img then
			this.pos.w = this.img:getWidth()
			this.pos.h = this.img:getHeight()
		end
	end,
	draw = function(this, pos)
		if this.img then
			this:drawimg(pos)
		end
		if this.label then
			setColor(this.style.labelfg or this.style.fg)
			lgprint(this.label, pos.x + ((pos.w - this.style.font:getWidth(this.label)) / 2), (pos.y + pos.h) + ((this.style.unit - this.style.font:getHeight()) / 2))
		end
	end,
}
setmetatable(Gspot.image, {__index = Gspot.util, __call = Gspot.image.load})

Gspot.button = {
	load = function(this, Gspot, label, pos, parent, autosize)
		if autosize then this.autosize = autosize end
		return Gspot:add(Gspot:element('button', label, pos, parent))
	end,
	draw = function(this, pos)
		if this.parent and this.value == this.parent.value then
			if this == this.Gspot.mousein then setColor(this.style.focus)
			else setColor(this.style.hilite) end
		else
			if this == this.Gspot.mousein then setColor(this.style.hilite)
			else setColor(this.style.default) end
		end
		this:drawshape(pos)
		setColor(this.style.labelfg or this.style.fg)
		if this.shape == 'circle' then
			if this.img then this:drawimg(pos) end
			if this.label then lgprint(this.label, (pos.x + pos.r) - (this.style.font:getWidth(this.label) / 2), (this.img and (pos.y + (pos.r * 2)) + ((this.style.unit - this.style.font:getHeight()) / 2)) or (pos.y + pos.r) - (this.style.font:getHeight() / 2)) end
		else
			if this.img then this:drawimg(pos) end
			if this.label then lgprint(this.label, (pos.x + (pos.w / 2)) - (this.style.font:getWidth(this.label) / 2), (this.img and pos.y + ((this.style.unit - this.style.font:getHeight()) / 2)) or (pos.y + (pos.h / 2)) - (this.style.font:getHeight() / 2)) end
		end
	end,
}
setmetatable(Gspot.button, {__index = Gspot.util, __call = Gspot.button.load})

Gspot.imgbutton = {
	load = function(this, Gspot, label, pos, parent, img)
		local element = Gspot:button(label, pos, parent)
		element:setimage(img)
		return Gspot:add(element)
	end,
}
setmetatable(Gspot.imgbutton, {__index = Gspot.util, __call = Gspot.imgbutton.load})

Gspot.option = {
	load = function(this, Gspot, label, pos, parent, value)
		local element = Gspot:button(label, pos, parent)
		element.value = value
		element.click = function(this) this.parent.value = this.value end
		return element
	end,
}
setmetatable(Gspot.option, {__index = Gspot.util, __call = Gspot.option.load})

Gspot.checkbox = {
	load = function(this, Gspot, label, pos, parent, value)
		local element = Gspot:element('checkbox', label, pos, parent)
		element.value = value
		return Gspot:add(element)
	end,
	click = function(this) this.value = not this.value end,
	draw = function(this, pos)
		if this == this.Gspot.mousein then setColor(this.style.hilite)
		else setColor(this.style.default) end
		this:drawshape(pos)
		if this.value then
			setColor(this.style.fg)
			this:drawshape(this.Gspot:pos({x = pos.x + (pos.w / 4), y = pos.y + (pos.h / 4), w = pos.w / 2, h = pos.h / 2, r = pos.r and pos.r / 2}))
		end
		if this.label then
			setColor(this.style.labelfg or this.style.fg)
			lgprint(this.label, pos.x + pos.w + (this.style.unit / 2), pos.y + ((this.pos.h - this.style.font:getHeight()) / 2))
		end
	end,
}
setmetatable(Gspot.checkbox, {__index = Gspot.util, __call = Gspot.checkbox.load})

Gspot.input = {
	load = function(this, Gspot, label, pos, parent, value, ispassword, passwordchar)
		local element = Gspot:element('input', label, pos, parent)
		element.value = (value and tostring(value)) or ''
		element.cursor = element.value:len()
		element.textorigin = 0
		element.cursorlife = 0
		element.keyrepeat = true
		element.ispassword = ispassword or false
		element.passwordchar = (passwordchar and tostring(passwordchar)) or '*'
		return Gspot:add(element)
	end,
	update = function(this, dt)
		if this.cursor > #this.value then this.cursor = #this.value end
		if this.Gspot.focus == this then
			if this.cursorlife >= 1 then this.cursorlife = 0
			else this.cursorlife = this.cursorlife + dt end
		end
	end,
	draw = function(this, pos)
		if this == this.Gspot.focus then
			setColor(this.style.bg)
		elseif this == this.Gspot.mousein then
			setColor(this.style.hilite)
		else
			setColor(this.style.default)
		end
		this:drawshape(pos)
		-- Margin of edit box is unit/4 on each side, so total margin is unit/2
		local editw = pos.w - this.style.unit / 2
		if editw >= 1 then -- won't be visible otherwise and we need room for the cursor
			-- We don't want to undo the current scissor, to avoid printing text where it shouldn't be
			-- (e.g. partially visible edit box inside a viewport) so we clip the current scissor.
			local sx, sy, sw, sh = clipScissor(pos.x + this.style.unit / 4, pos.y, editw, pos.h)
			setColor(this.style.fg)
			local str = this.ispassword and string.rep(this.passwordchar,utf8len(tostring(this.value))) or tostring(this.value)
			-- cursorx is the position relative to the start of the edit box
			-- (add pos.x + this.style.unit/4 to obtain the screen X coordinate)
			local cursorx = this.textorigin + this.style.font:getWidth(str:sub(1, this.cursor))
			-- adjust text origin so that the cursor is always within the edit box
			if cursorx < 0 then
				this.textorigin = math.min(0, this.textorigin - cursorx)
				cursorx = 0
			end
			if cursorx > editw - 1 then
				this.textorigin = math.min(0, this.textorigin - cursorx + editw - 1)
				cursorx = editw - 1
			end
			-- print the whole text and let the scissor do the clipping
			lgprint(str, pos.x + this.style.unit / 4 + this.textorigin, pos.y + (pos.h - this.style.font:getHeight()) / 2)
			if this == this.Gspot.focus and this.cursorlife < 0.5 then
				love.graphics.rectangle("fill", pos.x + this.style.unit / 4 + cursorx, pos.y + this.style.unit / 8, 1, pos.h - this.style.unit / 4)
			end
			-- restore current scissor
			love.graphics.setScissor(sx, sy, sw, sh)
		end
		if this.label then
			setColor(this.style.labelfg or this.style.fg)
			lgprint(this.label, pos.x - ((this.style.unit / 2) + this.style.font:getWidth(this.label)), pos.y + ((this.pos.h - this.style.font:getHeight()) / 2))
		end
	end,
	click = function(this) this:focus() end,
	done = function(this) this.Gspot:unfocus() end,
	keypress = function(this, key)
		local save_cursorlife = this.cursorlife
		this.cursorlife = 0
		-- fragments attributed to vrld's Quickie : https://github.com/vrld/Quickie
		if key == 'backspace' then
			local cur = this.cursor
			if cur > 0 then
				this.cursor = utf8char_begin(this.value, cur) - 1
				this.value = this.value:sub(1, this.cursor)..this.value:sub(cur + 1)
			end
		elseif key == 'delete' then
			local cur = utf8char_after(this.value, this.cursor + 1)
			this.value = this.value:sub(1, this.cursor)..this.value:sub(cur)
		elseif key == 'left' then
			if this.cursor > 0 then
				this.cursor = utf8char_begin(this.value, this.cursor) - 1
			end
		elseif key == 'right' then
			this.cursor = utf8char_after(this.value, this.cursor + 1) - 1
		elseif key == 'home' then
			this.cursor = 0
		elseif key == 'end' then
			this.cursor = this.value:len()
		elseif key == 'tab' and this.next and this.next.elementtype then
			this.next:focus()
		elseif key == 'escape' then
			this.Gspot:unfocus()
		else
			-- all of the above reset the blink timer, but otherwise it's retained
			this.cursorlife = save_cursorlife
		end
		-- /fragments
	end,

	textinput = function(this, key)
		this.value = this.value:sub(1, this.cursor) .. key .. this.value:sub(this.cursor + 1)
		this.cursor = this.cursor + #key
		-- reset blink timer
		this.cursorlife = 0
	end,
}
setmetatable(Gspot.input, {__index = Gspot.util, __call = Gspot.input.load})

Gspot.scroll = {
	load = function(this, Gspot, label, pos, parent, values)
		local element = Gspot:element('scroll', label, pos, parent)
		element.values = Gspot:scrollvalues(values)
		return Gspot:add(element)
	end,
	update = function(this, dt)
		local mouse = {}
		mouse.x, mouse.y = this.Gspot:getmouse()
		if this.withinrect(mouse, this:getpos()) and not this.Gspot.drag then this.Gspot.mousein = this end
	end,
	step = function(this, step)
		if step > 0 then this.values.current = math.max(this.values.current - this.values.step, this.values.min)
		elseif step < 0 then this.values.current = math.min(this.values.current + this.values.step, this.values.max)
		end
	end,
	drag = function(this, x, y)
		local pos = this:getpos()
		local hs = this.style.hs
		if hs == 'auto' then
			if this.values.axis == 'vertical' then
				local h = this.parent and this.parent.pos.h or pos.h
				hs = math.max(this.style.unit / 4, math.min(pos.h, pos.h * h / (this.values.max - this.values.min + h)))
			else
				local w = this.parent and this.parent.pos.w or pos.w
				hs = math.max(this.style.unit / 4, math.min(pos.w, pos.w * w / (this.values.max - this.values.min + w)))
			end
		end
		if this.values.axis == 'vertical' and pos.h == hs or this.values.axis ~= 'vertical' and pos.w == hs then
			this.values.current = 0
		else
			this.values.current = this.values.min + ((this.values.max - this.values.min) * ((this.values.axis == 'vertical' and ((math.min(math.max(pos.y, y - math.floor(hs / 2)), (pos.y + pos.h - hs)) - pos.y) / (pos.h - hs))) or ((math.min(math.max(pos.x, x - math.floor(hs / 2)), (pos.x + pos.w - hs)) - pos.x) / (pos.w - hs))))
		end
	end,
	wheelup = function(this)
		if this.values.axis == 'horizontal' then this:step(-1) else this:step(1) end
	end,
	wheeldown = function(this)
		if this.values.axis == 'horizontal' then this:step(1) else this:step(-1) end
	end,
	keypress = function(this, key)
		if key == 'left' and this.values.axis == 'horizontal' then
			this:step(1)
		elseif key == 'right' and this.values.axis == 'horizontal' then
			this:step(-1)
		elseif key == 'up' and this.values.axis == 'vertical' then
			this:step(-1)
		elseif key == 'down' and this.values.axis == 'vertical' then
			this:step(1)
		elseif key == 'tab' and this.next and this.next.elementtype then
			this.next:focus()
		elseif key == 'escape' then
			this.Gspot:unfocus()
		end
	end,
	done = function(this) this.Gspot:unfocus() end,
	draw = function(this, pos)
		if this == this.Gspot.mousein or this == this.Gspot.drag or this == this.Gspot.focus then setColor(this.style.default)
		else setColor(this.style.bg) end
		this:rect(pos)
		if this == this.Gspot.mousein or this == this.Gspot.drag or this == this.Gspot.focus then setColor(this.style.fg)
		else setColor(this.style.hilite) end
		local hs = this.style.hs
		if hs == 'auto' then
			if this.values.axis == 'vertical' then
				local h = this.parent and this.parent.pos.h or pos.h
				hs = math.max(this.style.unit / 4, math.min(pos.h, pos.h * h / (this.values.max - this.values.min + h)))
			else
				local w = this.parent and this.parent.pos.w or pos.w
				hs = math.max(this.style.unit / 4, math.min(pos.w, pos.w * w / (this.values.max - this.values.min + w)))
			end
		end
		local handlepos = this.Gspot:pos({x = (this.values.axis == 'horizontal' and math.min(pos.x + (pos.w - hs), math.max(pos.x, pos.x + ((pos.w - hs) * (this.values.current / (this.values.max - this.values.min)))))) or pos.x, y = (this.values.axis == 'vertical' and math.min(pos.y + (pos.h - hs), math.max(pos.y, pos.y + ((pos.h - hs) * (this.values.current / (this.values.max - this.values.min)))))) or pos.y, w = this.values.axis == 'horizontal' and hs or this.style.unit, h = this.values.axis == 'vertical' and hs or this.style.unit, r = pos.r})
		this:drawshape(handlepos)
		if this.label then
			setColor(this.style.labelfg or this.style.fg)
			lgprint(this.label, (this.values.axis == 'horizontal' and pos.x - ((this.style.unit / 2) + this.style.font:getWidth(this.label))) or pos.x + ((pos.w - this.style.font:getWidth(this.label)) / 2), (this.values.axis == 'vertical' and (pos.y + pos.h) + ((this.style.unit - this.style.font:getHeight()) / 2)) or pos.y + ((this.style.unit - this.style.font:getHeight()) / 2))
		end
	end,
}
Gspot.scroll.rdrag = Gspot.scroll.drag
setmetatable(Gspot.scroll, {__index = Gspot.util, __call = Gspot.scroll.load})

Gspot.scrollgroup = {
	load = function(this, Gspot, label, pos, parent, axis)
		axis = axis or 'both'
		local element = Gspot:element('scrollgroup', label, pos, parent)
		element.maxh = 0
		element = Gspot:add(element)
		if axis ~= 'horizontal' then element.scrollv = Gspot:scroll(nil, {x = element.pos.w, y = 0, w = element.style.unit, h = element.pos.h}, element, {0, 0, 0, element.style.unit, 'vertical'}) end
		if axis ~= 'vertical' then element.scrollh = Gspot:scroll(nil, {x = 0, y = element.pos.h, w = element.pos.w, h = element.style.unit}, element, {0, 0, 0, element.style.unit, 'horizontal'}) end
		return element
	end,
	draw = function(this, pos)
		setColor(this.style.bg)
		this:drawshape(pos)
		if this.label then
			setColor(this.style.labelfg or this.style.fg)
			lgprint(this.label, pos.x + ((pos.w - this.style.font:getWidth(this.label)) / 2), pos.y + ((this.style.unit - this.style.font:getHeight()) / 2))
		end
	end,
}
setmetatable(Gspot.scrollgroup, {__index = Gspot.util, __call = Gspot.scrollgroup.load})

Gspot.hidden = {
	load = function(this, Gspot, label, pos, parent)
		return Gspot:add(Gspot:element('hidden', label, pos, parent))
	end,
	draw = function(this, pos)
		--
	end,
}
setmetatable(Gspot.hidden, {__index = Gspot.util, __call = Gspot.hidden.load})

Gspot.radius = {
	load = function(this, Gspot, label, pos, parent)
		return Gspot:add(Gspot:element('radius', label, pos, parent))
	end,
	draw = function(this, pos)
		--
	end,
}
setmetatable(Gspot.radius, {__index = Gspot.util, __call = Gspot.radius.load})

Gspot.feedback = {
	load = function(this, Gspot, label, pos, parent, autopos)
		pos = pos or {}
		autopos = (autopos == nil and true) or autopos
		if autopos then
			for i, element in ipairs(Gspot.elements) do
				if element.elementtype == 'feedback' and element.autopos then element.pos.y = element.pos.y + element.style.unit end
			end
		end
		pos.x = pos.x or pos[1] or 0
		pos.y = pos.y or pos[2] or 0
		pos.w = 0
		pos.h = 0
		local element = Gspot:add(Gspot:element('feedback', label, pos, parent))
		element.style.fg = {255 / DIV, 255 / DIV, 255 / DIV, 255 / DIV}
		element.alpha = 255 / DIV
		element.life = 5
		element.autopos = autopos
		return element
	end,
	update = function(this, dt)
		this.alpha = this.alpha - ((255 / DIV * dt) / this.life)
		if this.alpha < 0 then
			this.Gspot:rem(this)
			return
		end
		local color = this.style.fg
		this.style.fg = {color[1], color[2], color[3], this.alpha}
	end,
	draw = function(this, pos)
		setColor(this.style.fg)
		lgprint(this.label, pos.x + (this.style.unit / 4), pos.y + ((this.style.unit - this.style.font:getHeight()) / 2))
	end,
}
setmetatable(Gspot.feedback, {__index = Gspot.util, __call = Gspot.feedback.load})

Gspot.progress = {
	load = function(this, Gspot, label, pos, parent)
		local element = Gspot:add(Gspot:element('progress', label, pos, parent))
		element.loaders = {}
		element.values = Gspot.scrollvalues(element, {0, 0, 0, 1})
		return element
	end,
	update = function(this, dt)
		for i, loader in ipairs(this.loaders) do
			if loader.status == 'waiting' then
				local success, result = pcall(function(loader) return loader.func() end, loader)
				loader.status = (success and 'done') or error
				loader.result = result
				this.values.current = this.values.current + 1
				break
			end
			if i == #this.loaders then this:done() end
		end
	end,
	draw = function(this, pos)
		setColor(this.style.default)
		this:drawshape(pos)
		setColor(this.style.fg)
		this:rect({x = pos.x, y = pos.y, w = pos.w * (this.values.current / this.values.max), h = pos.h})
		if this.label then
			setColor(this.style.labelfg or this.style.fg)
			lgprint(this.label, pos.x - ((this.style.unit / 2) + this.style.font:getWidth(this.label)), pos.y + ((this.pos.h - this.style.font:getHeight()) / 2))
		end
	end,
	done = function(this)
		this.Gspot:rem(this)
	end,
	add = function(this, loader)
		table.insert(this.loaders, {status = 'waiting', func = loader})
		this.values.max = this.values.max + 1
	end,
}
setmetatable(Gspot.progress, {__index = Gspot.util, __call = Gspot.progress.load})


return Gspot:setComponentMax("native")
