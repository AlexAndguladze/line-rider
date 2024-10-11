require("engine/init")
function love.run()
   return runtime.run()
end
go_layer = Deep:new()

Point = require("game_objects/Point")
Line = require("game_objects/Line")
game_objects = {
   
}
points = {
   {100, 100},
   {100, 200},
   {150, 250},
   {200, 200},
   {200, 100},
}
ground = {

}
local world

function love.load(args)
   love.physics.setMeter(64)
   world = love.physics.newWorld(0, 0, true)
   draw_lines()
end

function draw_lines()
   for i = 1, #points - 1 do
      local p1, p2 = points[i], points[i + 1]
      local line = Line:new({})
      line.body = love.physics.newBody(world, 0, 0, "static")
      line.shape = love.physics.newEdgeShape(p1[1], p1[2], p2[1], p2[2])
      line.fixture = love.physics.newFixture(line.body, line.shape)
      table.insert(ground, line)
   end
end

function love.mousepressed(_x, _y, button)
   if button == 1 then
      -- add projectile
      local point = Point:new({x = _x, y = _y})
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

   love.graphics.setColor(1, 0, 0)
   for _, g in ipairs(ground) do
       love.graphics.line(g.shape:getPoints())
   end

   go_layer:draw()
end
