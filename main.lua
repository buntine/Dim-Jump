function love.load(a)
  love.graphics.setBackgroundColor(255, 255, 255)
  love.graphics.setColor(80, 80, 80)

  player = {
    x = 0,
    y = (love.graphics.getHeight() - 100),
    w = 20,
    h = 20,
    deaths = 0,
    speed = 130,
    level = 1,
    collisionFound = function ()
      return false
    end
  }

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

  if player.collisionFound() then
    player.deaths = player.death + 1
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
  love.graphics.rectangle("fill", 0, (player.y + player.h), love.graphics.getWidth(), 80)
end

function drawLevel()
  obstacles = levels[player.level]

  for _, o in ipairs(obstacles) do
    love.graphics.rectangle("fill", o[1], (player.y + player.h) - o[3], o[2], o[3])
  end
end
