World = {
  gravity = 0.8,
  velocity = -10,
  queueOffset = -30,
  queueSpeed = 120,
  ground = 0,
  collisionPoints = {},
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
    { doRect(200, 20, 20),
      doRect(400, 20, 30),
      doRect(600, 30, 20) },
    { doRect(160, 20, 20),
      doRect(360, 20, 20), 
      doRect(500, 20, 20),
      doRect(660, 100, 10, 27) },
    { doRect(120, 20, 20),
      doRect(300, 20, 20),
      doRect(400, 20, 20),
      doRect(520, 20, 30),
      doRect(700, 35, 15) },
    { doRect(115, 8, 8),
      doRect(123, 8, 8, 8),
      doRect(131, 8, 8, 16),
      doRect(139, 8, 8, 8),
      doRect(147, 8, 8),
      doRect(220, 37, 9),
      doRect(350, 25, 25),
      doRect(420, 90, 7, 27),
      doRect(510, 100, 7, 17),
      doRect(610, 90, 7, 27),
      doRect(740, 20, 20)},
    { doRect(110, 20, 20),
      doRect(200, 20, 20),
      doRect(290, 20, 20),
      doRect(350, 100, 5, 27),
      doRect(490, 35, 12),
      doRect(600, 20, 40),
      doRect(740, 20, 30) },
    { doRect(120, 140, 8, 17),
      doRect(325, 32, 31),
      doRect(420, 200, 12, 27),
      doRect(646, 20, 20) },
    { doRect(120, 500, 5, 27),
      doRect(660, 30, 20),
      doRect(760, 30, 20) },
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
    { {28, 45, setY{130, -35, 139, -35, 139, -45, 149, -45, 149, -35, 158, -35, 158, -25, 149, -25, 149, 0,
                    139, 0, 139, -25, 130, -25}},
      doRect(215, 80, 5, 17),
      {28, 45, setY{350, -35, 359, -35, 359, -45, 369, -45, 369, -35, 378, -35, 378, -25, 369, -25, 369, 0,
                    359, 0, 359, -25, 350, -25}},
      doRect(430, 220, 5, 26),
      doRect(525, 30, 10, 54),
      doRect(535, 10, 45, 29),
      doRect(675, 45, 8),
      doRect(790, 30, 20, 7),
      doRect(802, 7, 7)},
    { doRect(120, 100, 10, 17),
      doRect(260, 10, 30, 0),
      doRect(310, 100, 10, 17),
      doRect(450, 20, 20),
      doRect(520, 20, 20),
      doRect(610, 100, 10, 17),
      {35, 25, {780, -25, 785, -25, 785, -20, 790, -20, 790, -25, 795, -25, 795, -20, 800, -20, 800, -25, 805, -25,
                805, -20, 810, -20, 810, -25, 815, -25, 815, 0, 780, 0}} }
  }

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
