require("engine/init")
function love.run()
   return runtime.run()
end
go_layer = Deep:new()

Point = require("game_objects/Point")
Line = require("game_objects/Line")
Cart = require("game_objects/Cart")
game_objects = {
   
}

points_buffer = {

}
ground = {

}
local world

local draw_threshold = 15

function love.load(args)
   love.physics.setMeter(64)
   local PIXELS_PER_METER = 100
   world = love.physics.newWorld(0, 9.81 * PIXELS_PER_METER, true)
end

-- set line from buffer
function set_lines()
   for i = 1, #points_buffer - 1 do
      local x1, y1 = points_buffer[i]:get_position()
      local x2, y2 = points_buffer[i + 1]:get_position()

      local line = Line:new({})
      line.body = love.physics.newBody(world, 0, 0, "static")
      line.shape = love.physics.newEdgeShape(x1, y1, x2, y2)
      line.fixture = love.physics.newFixture(line.body, line.shape)

      table.insert(ground, line)
   end
end

function love.mousepressed(_x, _y, button)
   if button == 1 then
      points_buffer = {}
      local point = Point:new({x = _x, y = _y})
      table.insert(points_buffer, point)
   elseif button == 2 then
      local cart = Cart:new({x = _x, y = _y, phy_world = world})
      table.insert(game_objects, cart)
   end
end

function love.mousereleased(_x, _y, button)
   if #points_buffer > 1 then
      set_lines()
   end
   points_buffer = {}
end

function distance_between(x1, y1, x2, y2)
   return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end


function when_mouse_down(_x, _y, buttom)
   if #points_buffer > 0 then
      local latest_point = points_buffer[#points_buffer]
      local distance = distance_between(_x, _y, latest_point.x, latest_point.y)
      if distance > draw_threshold then
         local point = Point:new({x = _x, y = _y})
         table.insert(points_buffer, point)
      end
   end
end

function love.update(dt)
   world:update(dt)

   if love.mouse.isDown(1) then
      local x, y = love.mouse.getPosition()
      when_mouse_down(x, y, 1)
   end

   for _, obj in pairs(game_objects) do
      if obj.update then obj:update(dt) end
   end
end

function love.draw()
   lg.setColor(1, 1, 1, 1)

   for _, obj in pairs(game_objects) do
      if obj.draw then obj:draw() end
   end
   lg.setColor(0, 0.5, 1)
   for _, pb in ipairs(points_buffer) do
      if #points_buffer > 1 then
         for i = 1, #points_buffer - 1 do
            local x1, y1 = points_buffer[i]:get_position()
            local x2, y2 = points_buffer[i + 1]:get_position()

            lg.line(x1, y1, x2, y2)
         end
      end
   end

   love.graphics.setColor(1, 1, 1)
   love.graphics.setLineWidth(5)
   for _, g in ipairs(ground) do
       love.graphics.line(g.shape:getPoints())
   end

   go_layer:draw()
end
