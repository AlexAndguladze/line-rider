require("engine/init")
function love.run()
   return runtime.run()
end
go_layer = Deep:new()

Point = require("game_objects/Point")

game_objects = {
}
local world

function love.load(args)
   love.physics.setMeter(64)
   world = love.physics.newWorld(0, 0, true)
   
end

function love.mousepressed(_x, _y, button)
   if button == 1 then
      -- add projectile
      local point = Point:new({x = _x, y = _y})
      print("yay")
      table.insert(game_objects, point)
   end
end

function love.update(dt)
   world:update(dt)

   for _, obj in pairs(game_objects) do
      if obj.update then obj:update(dt) end
   end
end

function love.draw()
   lg.setColor(1, 1, 1, 1)

   for _, obj in pairs(game_objects) do
      if obj.draw then obj:draw() end
   end

   go_layer:draw()
end
