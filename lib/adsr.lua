-- adsr / ar envelope lib
-- v0.1 @sonocircuit
--

local envelope = {}
envelope.__index = envelope

--- constructor
function envelope.new(id)
  local i = {}
  setmetatable(i, envelope)
  i.gate = false
  i.trig = false
  i.attack = 0
  i.decay = 0
  i.sustain = 1 
  i.release = 0
  i.a_is_running = false
  i.d_is_running = false
  i.r_is_running = false
  i.max_value = 1 -- redefine in script
  i.init_value = 0
  i.prev_value = 0
  i.count = 0
  i.id = id or "adsr"
  i.metro = metro.init(function() i:run() end, 0.01, -1)
  i.increment = function(_) print("increment") end -- redefine in script
  i.set_value = function(_) print("set value") end -- redefine in script
  i.get_value = function(_) print("previous value") end -- redefine in script
  return i
end

function envelope:gate_on()
  self.gate = true
  self.a_is_running = true
  self.count = 0
  self.set_value(self.init_value)
  self.metro:start()
  --print(self.id.." gate on at : "..util.round(util.time() % 10, 0.1))
  print("gate on")
end

function envelope:gate_off()
  self.get_value()
  self.gate = false
  self.a_is_running = false
  self.d_is_running = false
  self.r_is_running = true
  self.count = 0
  self.metro:start()
  --print(self.id.." gate off at : "..util.round(util.time() % 10, 0.1))
  print("gate off")
end

function envelope:trigger()
  self.trig = true
  self.a_is_running = true
  self.r_is_running = false
  self.count = 0
  self.set_value(self.init_value)
  self.metro:start()
  --print(self.id.." triggered at : "..util.round(util.time() % 10, 0.1))
  print("trigger")
end

--- make envelope
function envelope:run()
  self.count = self.count + 1
  if self.gate then
    if self.a_is_running then
      if self.attack == 0 then
        self.set_value(self.max_value)
        self.get_value()
        self.count = 0
        self.a_is_running = false
        self.d_is_running = true
        print("attack over")
      else
        local d = self.max_value / self.attack
        self.increment(d)
        if self.count >= self.attack then
          self.get_value()
          self.count = 0
          self.a_is_running = false
          self.d_is_running = true
          print("attack over")
          --print(self.id.." attack time reached at: "..util.round(util.time() % 10, 0.1))
        end
      end
    end
    if self.d_is_running then
      if self.decay == 0 then
        self.set_value(self.sustain)
        self.get_value()
        self.count = 0
        self.d_is_running = false
        self.metro:stop()
        print("decay over")
      else
        local d = -(self.prev_value - self.sustain) / self.decay
        self.increment(d)
        if self.count >= self.decay then
          self.set_value(self.sustain)
          self.get_value()
          self.count = 0
          self.d_is_running = false
          self.metro:stop()
          --print(self.id.." decay time reached at : "..util.round(util.time() % 10, 0.1))
          print("decay over ... sustaining now")
        end
      end
    end
  else
    if self.r_is_running then
      if self.release == 0 then
        self.r_is_running = false
        self.metro:stop()
        self.set_value(self.init_value)
        print("release over")
      else
        local d = -self.prev_value / self.release
        self.increment(d)
        if self.count >= self.release then
          self.r_is_running = false
          self.trig = false
          self.metro:stop()
          self.set_value(self.init_value)
          print("release over")
          --print(self.id.." release time reached at : "..util.round(util.time() % 10, 0.1))
        end
      end
    end
  end
  if self.trig then
    if self.a_is_running then
      if self.attack == 0 then
        self.count = 0
        self.a_is_running = false
        self.d_is_running = false
        self.r_is_running = true
        self.set_value(self.sustain)
        self.get_value()
        print("attack over")
      else
        local d = self.max_value / self.attack
        self.increment(d)
        if self.count >= self.attack then
          self.get_value()
          self.count = 0
          self.a_is_running = false
          self.r_is_running = true
          --print(self.id.." attack time reached at : "..util.round(util.time() % 10, 0.1))
          print("attack over")
        end
      end
    end
  end
end

return envelope
