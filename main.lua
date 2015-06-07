require "lib/fun" ()

function love.load(a)
  love.graphics.setBackgroundColor(255, 255, 255)
  love.graphics.setColor(80, 80, 80)

  world = {
    gravity = 0.9,
    velocity = -10,
    ground = love.graphics.getHeight() - 80
  }

  player = {
    x = 0,
    w = 20,
    h = 20,
    v = 0,
    jumping = false,
    deaths = 0,
    speed = 130,
    level = 1
  }
  player.y = world.ground - player.h

  -- width, x, y.
  levels = {
    { {100, 20, 20}, {360, 20, 20}, {600, 20, 20} },
    { {160, 20, 20}, {360, 20, 20}, {500, 20, 20}, {700, 20, 20} }
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
    if player.y + player.v < world.ground then
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
end

function drawPlayer()
  love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)
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

function collision(o)
  ox, ow, oh = o[1], o[2], o[3]
  oy = (player.y + player.h) - oh

  return player.x < (ox + ow) and
    ox < (player.x + player.w) and
    player.y < (oy + oh) and
    oy < (player.y + player.h)
end

function collisionFound()
  obstacles = levels[player.level]
  return any(collision, obstacles)
end
