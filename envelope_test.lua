-- adsr / ar
-- envelope test script
-- v0.1 @sonocircuit
--

-- library
local adsr = include 'lib/adsr'

-- variables
local level = 0

-- envelope setup
local env = adsr.new()

function env.increment(inc)
  level = level + inc
end

function env.set_value(val)
  level = val
end

function env.get_value()
  env.prev_value = level
  print("last value: "..env.prev_value)
end

-- helper functions
function r()
  norns.script.load(norns.state.script)
end

function clamp_levels()
  if env.sustain > env.max_value then
    params:set("amplitude", env.sustain)
  end
end

function init()
  params:add_separator("param")
  params:add_control("value", "value", controlspec.new(0, 10, 'lin', 0.1, 0, "v"))
  params:set_action("value", function(val) level = val end)

  params:add_separator("envelope")
  params:add_control("amplitude", "amplitude", controlspec.new(0, 10, 'lin', 0.1, 10, ""))
  params:set_action("amplitude", function(val) env.max_value = val clamp_levels() end)

  params:add_control("attack", "attack", controlspec.new(0, 10, 'lin', 0.1, 2, "s"))
  params:set_action("attack", function(val) env.attack = val * 100 end)

  params:add_control("decay", "decay", controlspec.new(0, 10, 'lin', 0.1, 1, "s"))
  params:set_action("decay", function(val) env.decay = val * 100 end)

  params:add_control("sustain", "sustain", controlspec.new(0, 10, 'lin', 0.1, 4, ""))
  params:set_action("sustain", function(val) env.sustain = val clamp_levels() end)

  params:add_control("release", "release", controlspec.new(0, 10, 'lin', 0.1, 3, "s"))
  params:set_action("release", function(val) env.release = val * 100 end)
  
  params:bang()

  screenredrawtimer = metro.init(function() redraw() end, 1/15, -1)
  screenredrawtimer:start()

  env.metro:stop()
  
end

-- norns UI
function key(n, z)
  if n == 1 then
    -- do nothing
  end
  if n == 2 then
    if z == 1 then
      env:gate_on()
    else
      env:gate_off()
    end
  elseif n == 3 then
    if z == 1 then
      env:trigger()
    end
  end
end

function enc(n, d)
  if n == 2 then
    --params:delta("value", d)
  end
end

function redraw()
  screen.clear()
  screen.font_size(16)

  local pos = 36

  screen.level(env.r_is_running and 15 or 4)
  screen.move(pos + 45, 16)
  screen.text("R")

  screen.level((env.gate and not env.a_is_running and not env.d_is_running and not env.r_is_running) and 15 or 4)
  screen.move(pos + 30, 16)
  screen.text("S")

  screen.level(env.d_is_running and 15 or 4)
  screen.move(pos + 15, 16)
  screen.text("D")

  screen.level(env.a_is_running and 15 or 4)
  screen.move(pos, 16)
  screen.text("A")

  screen.font_size(8)
  screen.level(4)
  screen.move(64, 36)
  screen.text_center("time: "..util.round(env.count / 100, 0.1).."s")
  screen.level(15)
  screen.move(64, 48)
  screen.text_center("value: "..util.round(level, 0.1))
  screen.update()
end
