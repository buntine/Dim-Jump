World = {
  gravity = 0.8,
  velocity = -10,
  queueOffset = -30,
  queueSpeed = 120,
  ground = 0,
  collisionPoints = {},

  -- x, w, h, float.
--  levels = {
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

  doRect = function(x, w, h, f)
    f = f or 0

    return {w, h, setY{x, -(h + f), (x + w), -(h + f), (x + w), -f, x, -f}}
  end

  self.levels = {
    { doRect(160, 20, 20),
      doRect(360, 20, 20), 
      doRect(500, 20, 20),
      doRect(660, 100, 10, 27) },
    { doRect(120, 20, 20),
      doRect(300, 20, 20),
      doRect(400, 20, 20),
      doRect(520, 20, 30),
      doRect(700, 35, 15) },
    { doRect(110, 20, 20),
      doRect(200, 20, 20),
      doRect(290, 20, 20),
      doRect(350, 100, 5, 27),
      doRect(490, 35, 12),
      doRect(600, 20, 40),
      doRect(740, 20, 30) },
    { doRect(120, 20, 20),
      doRect(190, 20, 20),
      doRect(260, 20, 20),
      doRect(330, 20, 20),
      doRect(400, 20, 20),
      doRect(490, 20, 20),
      doRect(560, 20, 20),
      doRect(630, 20, 20),
      doRect(700, 20, 20),
      doRect(770, 20, 20) },
    { doRect(100, 200, 4, 27),
      {40, 25, setY{340, -18, 350, -18, 350, -25, 370, -25, 370, -18, 380, -18, 380, 0, 340, 0}},
      doRect(420, 200, 4, 17),
      doRect(660, 30, 30, 0) },
    { {28, 45, setY{130, -35, 139, -35, 139, -45, 149, -45, 149, -35, 158, -35, 158, -25, 149, -25, 149, 0, 139, 0, 139, -25, 130, -25}},
      doRect(215, 80, 5, 17),
      {28, 45, setY{350, -35, 359, -35, 359, -45, 369, -45, 369, -35, 378, -35, 378, -25, 369, -25, 369, 0, 359, 0, 359, -25, 350, -25}},
      doRect(430, 220, 5, 26),
      doRect(525, 30, 10, 54),
      doRect(535, 10, 45, 29),
      doRect(675, 45, 8),
      doRect(790, 30, 20, 7),
      doRect(802, 7, 7)}
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
