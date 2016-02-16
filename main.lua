require "lib/fun" ()
require "player"
require "world"

function love.load(a)
  love.graphics.setBackgroundColor(171, 205, 236)
  love.graphics.setColor(255, 255, 255, 255)
  love.audio.setVolume(0.1)
  love.keyboard.setKeyRepeat(true)

  sounds = {
    splat = love.audio.newSource("assets/sounds/splat.wav"),
    theme = love.audio.newSource("assets/sounds/invaded_city.mp3")
  }

  images = {
    title = love.graphics.newImage("assets/images/title.png"),
    blood = love.graphics.newImage("assets/images/blood.png"),
    queue = love.graphics.newImage("assets/images/dim_queue.png")
  }

  fonts = {
    small = love.graphics.newFont("assets/fonts/addstandard.ttf", 18),
    big = love.graphics.newFont("assets/fonts/addstandard.ttf", 42)
  }

  local jumpDir = "assets/sounds/jumps/"
  sounds.jumps = map(function (f)
    return love.audio.newSource(jumpDir..f)
  end, love.filesystem.getDirectoryItems(jumpDir))

  love.graphics.setFont(fonts.small)

  sounds.theme:setLooping(true)
  love.audio.play(sounds.theme)

  world = World:new{ground=love.graphics.getHeight() - 80}
  player = Player:new{world=world}

  player:continue(loadPlayer())
end

function love.quit()
  savePlayer()
end

function love.update(dt)
  if love.keyboard.isDown(" ") or love.keyboard.isDown("up") then
    startJump()
  end

  if not player.alive then
    return
  end

  if not player.visible then
    world:moveQueue(dt)

    if world:queueHitGround() then
      player.visible = true
      world:resetQueue()
    end
  else
    local obstacles = world.levels[player.level]

    player.animation:update(dt)
    player:accellerate(dt, love.graphics.getWidth())

    for i, o in ipairs(obstacles) do
      if collision(o) then
        world:addCollisionPoint(i, player.x - (player.w / 2), player.y - (player.h / 6))
        love.audio.play(sounds.splat)
        player:kill()
      end
    end

    if player.jumping then
      player:progressJump(dt)
    end

    -- Move to keypressed?
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

function startJump()
  if player.alive and not player.jumping then
    local sfx = nth(math.random(length(sounds.jumps)), sounds.jumps)

    love.audio.play(sfx)
    player:jump()
  elseif not player.alive then
    player = Player:new{world=world}
  end
end

function love.keyreleased(key)
  if key == "down" and player.ducking then
    player:stand{setY = not player.jumping}
  end
end

function drawQueue()
  love.graphics.draw(images.queue, 5, world.queueOffset)
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
  local r

  for i, o in ipairs(obstacles) do
    r = function ()
      for _, p in pairs(love.math.triangulate(o[3])) do
        love.graphics.polygon("fill", p)
      end
    end

    r()

    withStencil(r, function ()
      for _, pos in ipairs(world.collisionPoints[i]) do
        love.graphics.draw(images.blood, pos[1], pos[2])
      end
    end)
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
  if player.alive then
    love.graphics.draw(images.title, 10, love.graphics.getHeight() - images.title:getHeight() - 10)

    withColour(226, 182, 128, 255, function ()
      love.graphics.print("Level " .. player.level, images.title:getWidth() + 30, love.graphics.getHeight() - 24)
    end)
  else
    withColour(186, 142, 88, 255, function ()
      withFont("small", function ()
        printInCenter("Congratulations! You died " .. player.deaths .. " times", 0, -38)
      end)

      withFont("big", function ()
        printInCenter("Press UP to play again", 0, 24)
      end)
    end)
  end
end

function collision(o)
  local ox, oy, ow, oh = o[3][1], o[3][2], o[1], o[2]

  return player.x < (ox + ow) and
    ox < (player.x + player.w) and
    player.y < (oy + oh) and
    oy < (player.y + player.h)
end

function collisionFound()
  return any(collision, world.levels[player.level])
end

function savePlayer()
  love.filesystem.write("save", player.level .. " " .. player.deaths)
end

function loadPlayer()
  if not love.filesystem.exists("save") then
    savePlayer()

    return player.level, player.deaths
  else
    local loadData = {}

    for s in love.filesystem.read("save"):gmatch("%S+") do
      table.insert(loadData, tonumber(s))
    end

    return unpack(loadData)
  end
end

-- Helper functions to get around Love2D oddities.
function withColour(r, g, b, a, f)
  local _r, _g, _b, _a = love.graphics.getColor()

  love.graphics.setColor(r, g, b, a)
  f()
  love.graphics.setColor(_r, _g, _b, _a)
end

function withFont(name, f)
  local _f = love.graphics.getFont()

  love.graphics.setFont(fonts[name])
  f()
  love.graphics.setFont(_f)
end

function withStencil(s, f)
  love.graphics.setStencil(s)
  f()
  love.graphics.setStencil()
end

function printInCenter(s, xo, yo)
  local f = love.graphics.getFont()
  local fw = f:getWidth(s)
  local fh = f:getHeight(s)

  xo = xo or 0
  yo = yo or 0

  love.graphics.print(s,
                      ((love.graphics.getWidth() / 2) - (fw / 2)) + xo,
                      ((love.graphics.getHeight() / 2) - (fh / 2)) + yo)
end
