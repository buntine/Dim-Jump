require "lib/fun" ()
require "player"

function love.load(a)
  love.graphics.setBackgroundColor(171, 205, 236)
  love.graphics.setColor(255, 255, 255, 255)

  love.keyboard.setKeyRepeat(true)

  title = love.graphics.newImage("assets/title.png")

  world = {
    gravity = 0.8,
    velocity = -10,
    ground = love.graphics.getHeight() - 80,

    -- x, w, h, float.
    levels = {
      { {160, 20, 20, 0}, {360, 20, 20, 0}, {440, 60, 5, 17}, {600, 20, 20, 0} },
      { {120, 20, 20, 0}, {300, 20, 20, 0}, {400, 20, 20, 0}, {520, 20, 30, 0}, {700, 35, 15, 0} },
      { {60, 100, 5, 29}, {190, 20, 20, 0}, {290, 40, 10, 0}, {300, 20, 20, 0}, {400, 20, 20, 0}, {550, 45, 10, 0}, {720, 30, 15, 0} },
    }
  }

  player = Player:new{world=world}
end

function love.update(dt)
  if not player.alive then
    return
  end

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

  for i, c in ipairs(player.corpses) do
    if not c:progress(dt) then
      player:removeCorpse(i)
    end
  end
end

function love.draw(dt)
  if player.alive then
    drawScore()
    drawFloor()
    drawLevel()
    drawPlayer()
    drawCorpses()
  else
    drawGameOver()
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
  love.graphics.draw(title, 10, 10)
  love.graphics.setColor(191, 161, 43)
  love.graphics.print("Deaths: " .. player.deaths, 270, 10)
  love.graphics.print("Level: " .. player.level .. " / " .. #world.levels, 270, 30)
  love.graphics.setColor(255, 255, 255)
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
