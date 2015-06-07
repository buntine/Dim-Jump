function love.load(a)
  love.graphics.setBackgroundColor(255, 255, 255)
  love.graphics.setColor(80, 80, 80)
end

function love.update(td)
end

function love.draw(td)
  makeFloor()
end

function makeFloor()
end

function makeFloor()
  love.graphics.rectangle("fill", 0, (love.graphics.getHeight() - 80),
                          love.graphics.getWidth(), 80)
end
