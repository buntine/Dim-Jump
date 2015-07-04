Stats = {
  updates = 0,
  draws = 0,
  keypresses = 0,
  startTime = os.time(),
  lastKey = "",
  visible = true
}

function Stats:new(o)
  o = o or {}

  setmetatable(o, self)
  self.__index = self

  return o
end

function Stats:recordUpdate()
  self.update = self.updates + 1
end

function Stats:recordDraw()
  self.draws = self.draws + 1
end

function Stats:recordKey()
  self.lastKey = key
  self.keypresses = self.keypresses + 1
end
