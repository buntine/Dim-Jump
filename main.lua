require "lib/fun" ()

function love.load(a)
  love.graphics.setBackgroundColor(255, 255, 255)
  love.graphics.setColor(80, 80, 80)

  world = {
    gravity = 0.8,
    velocity = -10,
    ground = love.graphics.getHeight() - 80
  }

  player = {
    x = 0,
    v = 0,
    sprite = love.graphics.newImage("assets/dim.gif"),
    jumping = false,
    deaths = 0,
    speed = 150,
    level = 1
  }
  player.w = player.sprite:getWidth()
  player.h = player.sprite:getHeight()
  player.y = world.ground - player.h

  -- width, x, y.
  levels = {
    { {160, 20, 20}, {360, 20, 20}, {600, 20, 20} },
    { {120, 20, 20}, {300, 20, 20}, {400, 20, 20}, {520, 20, 30}, {700, 20, 20} }
  }
end

function love.update(dt)
  if (player.x + player.w) > love.graphics.getWidth() then
    player.x = 0
    player.level = player.level + 1
  else
    player.x = player.x + (player.speed * dt)
  end

  if love.keyboard.isDown(" ") and not player.jumping then
    player.jumping = true
    player.v = world.velocity
  end

  if player.jumping then
    if player.y + player.v < (world.ground - player.h) then
      player.y = player.y + player.v
      player.v = player.v + world.gravity
    else
      player.y = world.ground - player.h
      player.jumping = false
    end
  end

  if collisionFound() then
    player.deaths = player.deaths + 1
    player.x = 0
  end
end

function love.draw(dt)
  drawFloor()
  drawPlayer()
  drawLevel()
  drawScore()
end

function drawPlayer()
  love.graphics.draw(player.sprite, player.x, player.y)
end

function drawFloor()
  love.graphics.rectangle("fill", 0, world.ground, love.graphics.getWidth(), world.ground)
end

function drawLevel()
  obstacles = levels[player.level]

  for _, o in ipairs(obstacles) do
    love.graphics.rectangle("fill", o[1], world.ground - o[3], o[2], o[3])
  end
end

function drawScore()
  love.graphics.print("Deaths: " .. player.deaths, 10, 10)
end

function collision(o)
  ox, ow, oh = o[1], o[2], o[3]
  oy = world.ground - oh

  return player.x < (ox + ow) and
    ox < (player.x + player.w) and
    player.y < (oy + oh) and
    oy < (player.y + player.h)
end

function collisionFound()
  obstacles = levels[player.level]
  return any(collision, obstacles)
end
