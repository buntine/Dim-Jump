require "lib/fun" ()
local anim8 = require("lib/anim8")

function love.load(a)
  love.graphics.setBackgroundColor(171, 205, 236)
  love.graphics.setColor(255, 255, 255, 255)

  pSprites = love.graphics.newImage("assets/dim.png")

  world = {
    gravity = 0.8,
    velocity = -10,
    ground = love.graphics.getHeight() - 80,

    -- x, w, h, float.
    levels = {
      { {160, 20, 20, 0}, {360, 20, 20, 0}, {600, 20, 20, 0} },
      { {120, 20, 20, 0}, {300, 20, 20, 0}, {400, 20, 20, 0}, {520, 20, 30, 0}, {700, 35, 15, 0} },
      { {60, 100, 5, 29}, {190, 20, 20, 0}, {290, 40, 10, 0}, {300, 20, 20, 0}, {400, 20, 20, 0}, {550, 45, 10, 0}, {720, 30, 15, 0} },
    }
  }

  player = createPlayer()
end

function love.update(dt)
  if player.alive then
    player.animation:update(dt)
    accelleratePlayer(dt)

    if player.jumping then
      progressJump(dt)
    end

    for i, c in ipairs(player.corpses) do
      if (c.alpha - (800 * dt)) < 0 then
        table.remove(player.corpses, i)
      else
        c.offset = c.offset + (20 * dt)
        c.scale = c.scale + (20 * dt)
        c.alpha = c.alpha - (800 * dt)
      end
    end

    if collisionFound() then
      table.insert(player.corpses, createCorpse())

      player.deaths = player.deaths + 1
      player.x = 0
      player.jumping = false
      player.rotation = 0
      player.y = world.ground - player.h
    end
  end
end

function love.draw(dt)
  if player.alive then
    drawFloor()
    drawLevel()
    drawPlayer()
    drawCorpses()
    drawScore()
  else
    drawGameOver()
  end
end

function love.keypressed(key, isrepeat)
  if key == " " then
    if player.alive and not player.jumping then
      player.jumping = true
      player.v = world.velocity
    elseif not player.alive then
      player = createPlayer()
    end
  end
end

function accelleratePlayer(dt)
  if (player.x + player.w) > love.graphics.getWidth() then
    player.x = 0

    if player.level < #world.levels then
      player.level = player.level + 1
    else
      player.alive = false
    end
  else
    player.x = player.x + (player.speed * dt)
  end
end

function progressJump(dt)
  player.rotation = player.rotation + (dt * math.pi * 4.61)

  if player.y + player.v < (world.ground - player.h) then
    player.y = player.y + player.v
    player.v = player.v + world.gravity
  else
    player.y = world.ground - player.h
    player.rotation = 0
    player.jumping = false
  end
end

function drawPlayer()
  local tx, ty = 0, 0

  if player.jumping then
    tx = (player.w / 2) - player.rotation
    ty = (player.h / 2) - player.rotation
  end

  player.animation:draw(player.spritesheet, player.x, player.y, player.rotation, 1, 1, tx, ty)
end

function drawFloor()
  love.graphics.rectangle("fill", 0, world.ground, love.graphics.getWidth(), world.ground)
end

function drawLevel()
  local obstacles = world.levels[player.level]

  for _, o in ipairs(obstacles) do
    love.graphics.rectangle("fill", o[1], world.ground - o[3] - o[4], o[2], o[3])
  end
end

function drawCorpses()
  for _, c in ipairs(player.corpses) do
    love.graphics.setColor(255, 255, 255, c.alpha)
    player.animation:draw(player.spritesheet, c.x, c.y, 0, c.scale, c.scale, c.offset, c.offset)
    love.graphics.setColor(255, 255, 255, 255)
  end
end

function drawScore()
  love.graphics.print("Deaths: " .. player.deaths, 10, 10)
  love.graphics.print("Level: " .. player.level .. " / " .. #world.levels, 10, 30)
end

function drawGameOver()
  love.graphics.print("Well done!", 10, 10)
  love.graphics.print("Deaths: " .. player.deaths, 10, 50)
  love.graphics.print("Press SPACE to play again", 10, 100)
end

function collision(o)
  local ox, ow, oh = o[1], o[2], o[3]
  local oy = world.ground - oh - o[4]

  return player.x < (ox + ow) and
    ox < (player.x + player.w) and
    player.y < (oy + oh) and
    oy < (player.y + player.h)
end

function collisionFound()
  local obstacles = world.levels[player.level]
  return any(collision, obstacles)
end

function createPlayer()
  local pGrid = anim8.newGrid(16, 24, pSprites:getWidth(), pSprites:getHeight())

  local p = {
    x = 0,
    v = 0,
    w = 16,
    h = 24,
    rotation = 0,
    spritesheet = pSprites,
    jumping = false,
    deaths = 0,
    speed = 160,
    level = 1,
    alive = true,
    animations = {
      move = anim8.newAnimation(pGrid("1-2", 1), 0.25)
    },
    corpses = {}
  }

  p.animation = p.animations.move
  p.y = world.ground - p.h

  return p
end

function createCorpse()
  return {
    x = player.x,
    y = player.y,
    offset = 0,
    scale = 1,
    alpha = 255,
  }
end
