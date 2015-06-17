require "lib/fun" ()
require "player"

function love.load(a)
  love.graphics.setBackgroundColor(171, 205, 236)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setNewFont(18)

  love.keyboard.setKeyRepeat(true)

  title = love.graphics.newImage("assets/title.png")
  dim_queue = love.graphics.newImage("assets/dim_queue.png")

  world = {
    gravity = 0.8,
    velocity = -10,
    queue_offset = -30,
    ground = love.graphics.getHeight() - 80,

    -- x, w, h, float.
    levels = {
      { {160, 20, 20, 0}, {360, 20, 20, 0}, {600, 20, 20, 0} },
      { {120, 20, 20, 0}, {300, 20, 20, 0}, {400, 20, 20, 0}, {520, 20, 30, 0}, {700, 35, 15, 0} },
      { {110, 20, 20, 0}, {200, 20, 20, 0}, {290, 20, 20, 0}, {350, 100, 5, 29}, {490, 35, 12, 0}, {600, 20, 40, 0}, {740, 20, 30, 0} },
      { {100, 200, 4, 27}, {340, 40, 10, 0}, {350, 20, 10, 10}, {420, 200, 4, 17}, {660, 30, 30, 0} },
      { {120, 20, 20, 0}, {190, 20, 20, 0}, {260, 20, 20, 0}, {330, 20, 20, 0}, {400, 20, 20, 0}, {490, 20, 20, 0}, {560, 20, 20, 0}, {630, 20, 20, 0}, {700, 20, 20, 0}, {770, 20, 20, 0} },
    }
  }

  player = Player:new{world=world}
end

function love.update(dt)
  if not player.alive then
    return
  end

  if not player.visible then
    if world.queue_offset > -6 then
      player.visible = true
      world.queue_offset = -30
    else
      world.queue_offset = world.queue_offset + (120 * dt)
    end
  else
    player.animation:update(dt)
    player:accellerate(dt, love.graphics.getWidth())

    if collisionFound() then
      player:kill()
    end

    if player.jumping then
      player:progressJump(dt)
    end

    if love.keyboard.isDown("down") and not (player.jumping or player.ducking) then
      player:duck()
    end
  end

  for i, c in ipairs(player.corpses) do
    if not c:progress(dt) then
      player:removeCorpse(i)
    end
  end
end

function love.draw(dt)
  if player.alive then
    drawFloor()
    drawLevel()
    drawUI()
    drawQueue()
    drawCorpses()

    if player.visible then
      drawPlayer()
    end
  else
    drawUI()
  end
end

function love.keypressed(key, isrepeat)
  if key == "up" or key == " " then
    if player.alive and not player.jumping then
      player:jump()
    elseif not player.alive then
      player = Player:new{world=world}
    end
  end
end

function love.keyreleased(key)
  if key == "down" and player.ducking then
    player:stand()
  end
end

function drawQueue()
  love.graphics.draw(dim_queue, 5, world.queue_offset)
end

function drawPlayer()
  local tx, ty = 0, 0

  if player.jumping then
    tx = (player.w / 2) - player.rotation
    ty = (player.h / 2) - player.rotation
  end

  if player.lifeAlpha > 0 then
    withColour(118, 101, 255, player.lifeAlpha, function ()
      love.graphics.printf(player.deaths + 1, player.x, player.y - 20, 1000, "left", player.rotation, 1, 1, tx, ty)
    end)
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
    withColour(255, 255, 255, c.alpha, function ()
      player.animation:draw(player.spritesheet, c.x, c.y, 0, c.scale, c.scale, c.offset, c.offset)
    end)
  end
end

function drawUI()
  love.graphics.draw(title, 10, love.graphics.getHeight() - title:getHeight() - 10)

  withColour(226, 182, 128, 255, function ()
    love.graphics.print("Level " .. player.level, title:getWidth() + 30, love.graphics.getHeight() - 27)

    if not player.alive then
      love.graphics.print("Press UP to play again", 10, love.graphics.getHeight() / 2)
    end
  end)
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

function withColour(r, g, b, a, f)
  local _r, _g, _b, _a = love.graphics.getColor()

  love.graphics.setColor(r, g, b, a)
  f()
  love.graphics.setColor(_r, _g, _b, _a)
end
