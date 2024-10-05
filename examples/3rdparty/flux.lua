--
-- flux
--
-- Copyright (c) 2016 rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local flux = { _version = "0.1.5" }
flux.__index = flux

flux.tweens = {}
flux.easing = { linear = function(p) return p end }

local easing = {
  quad    = "p * p",
  cubic   = "p * p * p",
  quart   = "p * p * p * p",
  quint   = "p * p * p * p * p",
  expo    = "2 ^ (10 * (p - 1))",
  sine    = "-math.cos(p * (math.pi * .5)) + 1",
  circ    = "-(math.sqrt(1 - (p * p)) - 1)",
  back    = "p * p * (2.7 * p - 1.7)",
  elastic = "-(2^(10 * (p - 1)) * math.sin((p - 1.075) * (math.pi * 2) / .3))",
  bounce  =
  "((1-p) < 1/2.75 and 1-(7.5625*(1-p)*(1-p))) or ((1-p) < (2/2.75) and 1-(7.5625*((1-p) - (1.5/2.75))*((1-p) - (1.5/2.75)) + .75)) or ((1-p) < 2.5/2.75 and 1-(7.5625*((1-p) - (2.25/2.75))*((1-p) - (2.25/2.75)) + .9375)) or 1-(7.5625*((1-p) - (2.625/2.75))*((1-p) - (2.625/2.75)) + .984375)"
}

local makefunc = function(str, expr)
  local load = loadstring or load
  return load("return function(p) " .. str:gsub("%$e", expr) .. " end")()
end

for k, v in pairs(easing) do
  flux.easing[k .. "in"] = makefunc("return $e", v)
  flux.easing[k .. "out"] = makefunc([[
    p = 1 - p
    return 1 - ($e)
  ]], v)
  flux.easing[k .. "inout"] = makefunc([[
    p = p * 2
    if p < 1 then
      return .5 * ($e)
    else
      p = 2 - p
      return .5 * (1 - ($e)) + .5
    end
  ]], v)
end



local tween = {}
tween.__index = tween

local function makefsetter(field)
  return function(self, x)
    local mt = getmetatable(x)
    if type(x) ~= "function" and not (mt and mt.__call) then
      error("expected function or callable", 2)
    end
    local old = self[field]
    self[field] = old and function(...)
      old(...)
      x(...)
    end or x
    return self
  end
end

local function makesetter(field, checkfn, errmsg)
  return function(self, x)
    if checkfn and not checkfn(x) then
      error(errmsg:gsub("%$x", tostring(x)), 2)
    end
    self[field] = x
    return self
  end
end

tween.ease             = makesetter("_ease",
  function(x) return flux.easing[x] end,
  "bad easing type '$x'")
tween.delay            = makesetter("_delay",
  function(x) return type(x) == "number" end,
  "bad delay time; expected number")
tween.rewind           = makesetter("_rewind",
  function(x) return type(x):match("[number|boolean]") end,
  "bad rewind time; expected number or boolean")
tween.cycle            = makesetter("_cycle",
  function(x) return type(x):match("[number|boolean]") end,
  "bad cycle value; expected number or boolean")
tween.onstart          = makefsetter("_onstart")
tween.onupdate         = makefsetter("_onupdate")
tween.oncomplete       = makefsetter("_oncomplete")
tween.onrewindcomplete = makefsetter("_onrewindcomplete")
tween.oncyclecomplete  = makefsetter("_oncyclecomplete")

local function update(tween, i, deltatime)
  local t = tween[i]
  if not t or t.paused then
    return
  end
  t._dt = deltatime
  if t._delay > 0 then
    t._delay = t._delay - deltatime
    if t._delay <= 0 then
      t._dt = -t._delay
      t._delay = 0
    end
  end
  if t._delay > 0 then
    return
  end
  if t._dt <= 0 then
    return
  end
  if not t.inited then
    flux.clear(tween, t.obj, t.vars)
    t:init()
  end
  if t._onstart then
    t._onstart()
    t._onstart = nil
  end
  local remain = (1 - t.progress) / t.rate
  t.progress = t.progress + t.rate * t._dt
  local p = t.progress
  local x = p >= 1 and 1 or flux.easing[t._ease](p)
  for k, v in pairs(t.vars) do
    t.obj[k] = v.start + x * v.diff * t.way
  end
  if t._onupdate then t._onupdate(deltatime) end
  if p < 1 then
    return
  end
  t._dt = t._dt - remain
  if t._rewind and (t._rewind == true or t._rewind > 1) then
    t.progress = 0
    t._rewind = (t._rewind == true) or (t._rewind - 1)
    t.way = t.way * -1
    for k, v in pairs(t.vars) do
      t.vars[k].start = t.obj[k]
    end
    if t._onrewindcomplete then t._onrewindcomplete() end
  elseif t._cycle and (t._cycle == true or t._cycle > 1) then
    t.progress = 0
    t._cycle = (t._cycle == true) or (t._cycle - 1)
    if t._oncyclecomplete then t._oncyclecomplete() end
  else
    flux.remove(tween, i)
    if t._oncomplete then t._oncomplete(t.obj) end
    if t.g_tick then t.g_tick.paused = false end
  end
end

function tween.new(obj, time, vars)
  local self = setmetatable({}, tween)
  self.obj = obj
  self.rate = time > 0 and 1 / time or 0
  self.progress = time > 0 and 0 or 1
  self._delay = 0
  self._ease = "quadout"
  self.vars = {}
  self.way = 1
  for k, v in pairs(vars) do
    if type(v) ~= "number" then
      error("bad value for key '" .. k .. "'; expected number")
    end
    self.vars[k] = v
  end
  return self
end

function tween:init()
  for k, v in pairs(self.vars) do
    local x = self.obj[k]
    if type(x) ~= "number" then
      error("bad value on object key '" .. k .. "'; expected number")
    end
    self.vars[k] = { start = x, diff = v - x }
  end
  self.inited = true
end

function tween:after(...)
  local t
  if select("#", ...) == 2 then
    t = tween.new(self.obj, ...)
  else
    t = tween.new(...)
  end
  t.parent = self.parent
  self:oncomplete(function()
    flux.add(self.parent, t)
    update(self.parent, #self.parent, self._dt or 0)
  end)
  return t
end

function tween:wait(t, f)
  local tick = self.parent._tick
  assert(tick, "No tick set!", 2)
  local td = tick:delay(t, f)
  td.paused = true
  td._flux = self.parent
  self.g_tick = td
  return td
end

function tween:pause()
  self.paused = true
end

function tween:resume()
  self.paused = false
end

function tween:stop()
  flux.remove(self.parent, self)
end

function flux.group()
  return setmetatable({}, flux)
end

function flux:tick(lib)
  self._tick = lib
end

function flux:to(obj, time, vars)
  return flux.add(self, tween.new(obj, time, vars))
end

function flux:__call(...)
  return self:to(...)
end

function flux:update(deltatime)
  for i = #self, 1, -1 do
    update(self, i, deltatime)
  end
end

function flux:clear(obj, vars)
  for t in pairs(self[obj]) do
    if t.inited then
      for k in pairs(vars) do t.vars[k] = nil end
    end
  end
end

function flux:add(tween)
  -- Add to object table, create table if it does not exist
  local obj = tween.obj
  self[obj] = self[obj] or {}
  self[obj][tween] = true

  if self._tick then
    tween._tick = self._tick
  end

  -- Add to array
  table.insert(self, tween)
  tween.parent = self
  return tween
end

function flux:remove(x)
  if type(x) == "number" then
    -- Remove from object table, destroy table if it is empty
    local obj = self[x].obj
    self[obj][self[x]] = nil
    if not next(self[obj]) then self[obj] = nil end
    -- Remove from array
    self[x] = self[#self]
    return table.remove(self)
  end
  for i, v in pairs(self) do
    if v == x then
      return flux.remove(self, i)
    end
  end
end

local bound = {
  to     = function(...) return flux.to(flux.tweens, ...) end,
  update = function(...) return flux.update(flux.tweens, ...) end,
  remove = function(...) return flux.remove(flux.tweens, ...) end,
}
setmetatable(bound, flux)

return bound
