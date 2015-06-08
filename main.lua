require "lib/fun" ()

function love.load(a)
  love.graphics.setBackgroundColor(255, 255, 255)
  love.graphics.setColor(80, 80, 80)

  world = {
    gravity = 0.8,
    velocity = -10,
    ground = love.graphics.getHeight() - 80,

    -- x, w, h, float.
    levels = {
      { {160, 20, 20, 0}, {360, 20, 20, 0}, {600, 20, 20, 0} },
      { {120, 20, 20, 0}, {300, 20, 20, 0}, {400, 20, 20, 0}, {520, 20, 30, 0}, {700, 20, 20, 0} },
      { {60, 100, 5, 29}, {190, 20, 20, 0}, {290, 40, 10, 0}, {300, 20, 20, 0}, {400, 20, 20, 0}, {550, 50, 10, 0} }
    }
  }

  player = createPlayer()
end

function love.update(dt)
  if player.alive then
    accelleratePlayer(dt)

    if player.jumping then
      progressJump(dt)
    end

    if collisionFound() then
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
    drawPlayer()
    drawLevel()
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

  love.graphics.draw(player.sprite, player.x, player.y, player.rotation, 1, 1, tx, ty)
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
  local p = {
    x = 0,
    v = 0,
    rotation = 0,
    sprite = love.graphics.newImage("assets/dim.gif"),
    jumping = false,
    deaths = 0,
    speed = 160,
    level = 3,
    alive = true
  }

  p.w = p.sprite:getWidth()
  p.h = p.sprite:getHeight()
  p.y = world.ground - p.h

  return p
end
