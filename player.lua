require "corpse"

local anim8 = require("lib/anim8")
local pSprites = love.graphics.newImage("assets/images/dim.png")
local pGrid = anim8.newGrid(16, 24, pSprites:getWidth(), pSprites:getHeight())

Player = {
  x = 5,
  v = 0,
  w = 16,
  h = 24,
  visible = true,
  lifeAlpha = 255,
  rotation = 0,
  spritesheet = pSprites,
  jumping = false,
  ducking = false,
  deaths = 0,
  speed = 160,
  level = 1,
  alive = true,
  animations = {
    move = anim8.newAnimation(pGrid("1-2", 1), 0.1),
    duck = anim8.newAnimation(pGrid("1-2", 2), 0.1)
  },
  world = {},
  corpses = {}
}

function Player:new(o)
  o = o or {}

  setmetatable(o, self)
  self.__index = self

  o.animation = o.animations.move
  o.y = o.world.ground - o.h

  o.world:clearCollisionPoints(self.level)

  return o
end

function Player:continue(l, d)
  self.level = l
  self.deaths = d
end

function Player:right()
  return self.x + self.w
end

function Player:floorTop()
  return self.world.ground - self.h
end

function Player:centerX()
  return self.x + (self.w / 2)
end

function Player:centerY()
  return self.y + (self.h / 2)
end

function Player:nextLevel()
  self.x = 0
  self.level = self.level + 1
end

function Player:finished()
  self.alive = false
end

function Player:removeCorpse(i)
  table.remove(self.corpses, i)
end

function Player:duck()
  self.ducking = true
  self.animation = self.animations.duck
  self.h = 16
  self.y = self:floorTop()
end

function Player:stand(o)
  o = o or {setY = true}

  self.ducking = false
  self.animation = self.animations.move
  self.h = 24

  if o.setY then
    self.y = self:floorTop()
  end
end

function Player:accellerate(dt, width)
  if self:right() > width then
    if self.level < #self.world.levels then
      self:nextLevel()
    else
      self:finished()
    end

    self.world:clearCollisionPoints(self.level)
  else
    self.x = self.x + (self.speed * dt)

    if self.lifeAlpha > 0 then
      self.lifeAlpha = self.lifeAlpha - (200 * dt)
    end
  end
end

function Player:jump()
  local style = self.ducking and "small" or "big"

  self.jumping = true
  self.v = self.world.velocity[style]
end

function Player:progressJump(dt)
  local nextY = self.y + self.v

  self.rotation = self.rotation + (dt * math.pi * 4.61)

  if nextY < self:floorTop() then
    self.y = nextY
    self.v = self.v + self.world.gravity
  else
    self.y = self:floorTop()
    self.rotation = 0
    self.jumping = false
  end
end

function Player:kill()
  table.insert(self.corpses, Corpse:new{x=self.x, y=self.y})

  self:stand()

  self.deaths = self.deaths + 1
  self.visible = false
  self.x = 5
  self.lifeAlpha = 255
  player.jumping = false
  player.rotation = 0
end
