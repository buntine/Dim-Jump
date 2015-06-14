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
    move = anim8.newAnimation(pGrid("1-2", 1), 0.20),
    duck = anim8.newAnimation(pGrid("1-2", 2), 0.20)
  },
  world = {},
  corpses = {}
}

function Player:new(o)
  o = o or {}

  setmetatable(o, self)
  self.__index = self

  o.animation = o.animations.move
  o.y = self.world.ground - o.h

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

function Player:accellerate(dt)
  self.x = self.x + (self.speed * dt)
end

function Player:progressJump(dt)
  local next_y = self.y + self.v

  self.rotation = self.rotation + (dt * math.pi * 4.61)

  if next_y < self.floorTop() then
    self.y = next_y
    self.v = self.v + self.world.gravity
  else
    self.y = self.floorTop()
    self.rotation = 0
    self.jumping = false
  end
end
