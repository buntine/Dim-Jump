function love.load(a)
  love.graphics.setBackgroundColor(255, 255, 255)
  love.graphics.setColor(80, 80, 80)

  player = {
    x = 0,
    y = (love.graphics.getHeight() - 100),
    w = 20,
    h = 20,
    speed = 120
  }
end

function love.update(dt)
  if (player.x + player.w) > love.graphics.getWidth() then
    player.x = 0
  else
    player.x = player.x + (player.speed * dt)
  end
end

function love.draw(dt)
  drawFloor()
  drawPlayer()
end

function drawPlayer()
  love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)
end

function drawFloor()
  love.graphics.rectangle("fill", 0, (player.y + player.h), love.graphics.getWidth(), 80)
end
