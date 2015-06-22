World = {
  gravity = 0.8,
  velocity = -10,
  queueOffset = -30,
  queueSpeed = 120,
  ground = 0,
  collisionPoints = {},

  -- x, w, h, float.
--  levels = {
--    { {160, 20, 20, 0}, {360, 20, 20, 0}, {600, 20, 20, 0} },
--    { {120, 20, 20, 0}, {300, 20, 20, 0}, {400, 20, 20, 0}, {520, 20, 30, 0}, {700, 35, 15, 0} },
--    { {110, 20, 20, 0}, {200, 20, 20, 0}, {290, 20, 20, 0}, {350, 100, 5, 29}, {490, 35, 12, 0}, {600, 20, 40, 0}, {740, 20, 30, 0} },
--    { {120, 20, 20, 0}, {190, 20, 20, 0}, {260, 20, 20, 0}, {330, 20, 20, 0}, {400, 20, 20, 0}, {490, 20, 20, 0}, {560, 20, 20, 0}, {630, 20, 20, 0}, {700, 20, 20, 0}, {770, 20, 20, 0} },
--    { {100, 200, 4, 27}, {340, 40, 10, 0}, {350, 20, 10, 10}, {420, 200, 4, 17}, {660, 30, 30, 0} },
--    { {130, 30, 10, 25}, {140, 10, 45, 0}, {215, 80, 5, 17}, {350, 30, 10, 25}, {360, 10, 45, 0}, {430, 220, 5, 29}, {535, 10, 45, 29}, {525, 30, 10, 54}, {675, 45, 8, 0}, {802, 7, 7, 0}, {790, 30, 20, 7} },
--    { {120, 100, 10, 17}, {260, 10, 30, 0}, {310, 100, 10, 17}, {450, 20, 20, 0}, {520, 20, 20, 0}, {610, 100, 10, 17}, {780, 35, 20, 0}, {780, 5, 5, 20}, {790, 5, 5, 20}, {800, 5, 5, 20}, {810, 5, 5, 20} },
--  }
}

function World:new(o)
  o = o or {}

  setmetatable(o, self)
  self.__index = self

  setY = function(vertices)
    for i, v in ipairs(vertices) do
      if i % 2 == 0 then
        vertices[i] = v + o.ground
      end
    end

    return vertices
  end

  -- w, h, {Polygon vertices}.
  self.levels = {
    { {20, 20, setY{160, -20, 180, -20, 180, 0, 160, 0}},
      {20, 20, setY{360, -20, 380, -20, 380, 0, 360, 0}}, 
      {20, 20, setY{600, -20, 620, -20, 620, 0, 600, 0}} },
  }

  self:clearCollisionPoints(1)

  return o
end

function World:clearCollisionPoints(level)
  self.collisionPoints = {}

  for i=1, #self.levels[level] do
    table.insert(self.collisionPoints, {}) 
  end
end

function World:addCollisionPoint(i, x, y)
  table.insert(self.collisionPoints[i], {x, y})
end

function World:moveQueue(dt)
  self.queueOffset = self.queueOffset + (self.queueSpeed * dt)
end

function World:queueHitGround()
  return self.queueOffset > -6
end

function World:resetQueue()
  self.queueOffset = -30
end
