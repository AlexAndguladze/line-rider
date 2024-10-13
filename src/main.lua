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
col_categories = {
   lines = 2,
   line_sensors = 3,
}
deferred_sensor_changes = {}

local draw_threshold = 15

function love.load(args)
   love.physics.setMeter(64)
   local PIXELS_PER_METER = 100
   world = love.physics.newWorld(0, 9.81 * PIXELS_PER_METER, true)
   world:setCallbacks(beginContact)
end

-- set line from buffer
function set_lines()
   for i = 1, #points_buffer - 1 do
      local _x1, _y1 = points_buffer[i]:get_position()
      local _x2, _y2 = points_buffer[i + 1]:get_position()

      local line = Line:new({
         x1 = _x1,
         y1 = _y1,
         x2 = _x2,
         y2 = _y2,
         phy_world = world,
      })
      -- line.body = love.physics.newBody(world, 0, 0, "static")
      -- line.shape = love.physics.newEdgeShape(x1, y1, x2, y2)
      -- line.fixture = love.physics.newFixture(line.body, line.shape)

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

function beginContact(a, b, col)
   local cat_a = a:getCategory()
   local cat_b = b:getCategory()
   print("Collision detected between categories: ", cat_a, cat_b)

   if cat_a == 3 or cat_b == 3 then
      local normal_x, normal_y = col:getNormal()
      print(normal_x)
      -- if normal_x > 0 then
      --    if cat_a == col_categories.lines then
      --       table.insert(deferred_sensor_changes, {fixture = a, sensorState = false})
      --    elseif cat_b == col_categories.lines then
      --       table.insert(deferred_sensor_changes, {fixture = b, sensorState = false})
      --    end
      -- end
   end
end

-- function endContact(a, b, col)
--    local cat_a = a:getCategory()
--    local cat_b = b:getCategory()

--    if cat_a == col_categories.lines or cat_b == col_categories.lines then
--       if cat_a == col_categories.lines then
--          table.insert(deferred_sensor_changes, {fixture = a, sensorState = true})
--       elseif cat_b == col_categories.lines then
--          table.insert(deferred_sensor_changes, {fixture = b, sensorState = true})
--       end
--    end
-- end

function love.update(dt)
   world:update(dt)

   for i, change in ipairs(deferred_sensor_changes) do
      change.fixture:setSensor(change.sensorState)
   end
   deferred_sensor_changes = {}

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

   -- lg.setColor(1, 1, 1)
   -- lg.setLineWidth(5)
   -- for _, g in ipairs(ground) do
   --     love.graphics.line(g.shape:getPoints())
   -- end
   for _, g in ipairs(ground) do
      g:draw()
   end

   lg.setColor(1, 1, 1)
   local line_count = "lines:"..#ground
   lg.print(line_count, 10, 10)


   go_layer:draw()
end
