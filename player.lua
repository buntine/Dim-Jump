require "corpse"

local anim8 = require("lib/anim8")
local pSprites = love.graphics.newImage("assets/dim.png")
local pGrid = anim8.newGrid(16, 24, pSprites:getWidth(), pSprites:getHeight())

Player = {
  x = 0,
  v = 0,
  w = 16,
  h = 24,
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

  return o
end

function Player:right()
  return self.x + self.w
end

function Player:floorTop()
  return self.world.ground - self.h
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

function Player:stand()
  self.ducking = false
  self.animation = self.animations.move
  self.h = 24
  self.y = self:floorTop()
end

function Player:accellerate(dt, width)
  if self:right() > width then
    if self.level < #self.world.levels then
      self:nextLevel()
    else
      self:finished()
    end
  else
    self.x = self.x + (self.speed * dt)
  end
end

function Player:jump()
  self.jumping = true
  self.v = self.world.velocity
end

function Player:progressJump(dt)
  local next_y = self.y + self.v

  self.rotation = self.rotation + (dt * math.pi * 4.61)

  if next_y < self:floorTop() then
    self.y = next_y
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
  self.x = 0
  player.jumping = false
  player.rotation = 0
end
