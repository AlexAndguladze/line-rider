require("engine/init")
function love.run()
   return runtime.run()
end
go_layer = Deep:new()

Point = require("game_objects/Point")
Line = require("game_objects/Line")
Line_Accelerator = require("game_objects/Line_Accelerator")
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
   cart = 4,
}
deferred_sensor_changes = {}

local draw_threshold = 15
local draw_line_category = {
   normal = 1,
   accelerator = 2,
}
local current_draw_line = 1

function love.load(args)
   love.physics.setMeter(64)
   local PIXELS_PER_METER = 100
   world = love.physics.newWorld(0, 9.81 * PIXELS_PER_METER, true)
   world:setCallbacks(beginContact, endContact)
end

-- set line from buffer
function set_lines()
   for i = 1, #points_buffer - 1 do
      local _x1, _y1 = points_buffer[i]:get_position()
      local _x2, _y2 = points_buffer[i + 1]:get_position()

      if current_draw_line == draw_line_category.normal then
         local line = Line:new({
            x1 = _x1,
            y1 = _y1,
            x2 = _x2,
            y2 = _y2,
            phy_world = world,
         })
         table.insert(ground, line)
      elseif current_draw_line == draw_line_category.accelerator then
         print("accel setting")
         local line = Line_Accelerator:new({
            x1 = _x1,
            y1 = _y1,
            x2 = _x2,
            y2 = _y2,
            phy_world = world,
         })
         table.insert(ground, line)
      end
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


   if cat_a == 3 or cat_b == 3 then
      if cat_a == col_categories.line_sensors then
         local data = a:getUserData()
         table.insert(deferred_sensor_changes, {fixture = data.fixture, sensor_state = true})
      elseif cat_b == col_categories.line_sensors then
         local data = b:getUserData()
         table.insert(deferred_sensor_changes, {fixture = data.fixture, sensor_state = true})
      end
   end
   --check for accelerator lines 
   if cat_a == 4 or cat_b == 4 then
      if cat_b == col_categories.lines then
         local cart = a:getUserData()
         if cart.accelerator_count then -- keep count of accelerator colliders currently touching
         cart.accelerator_count = car.accelerator_count + 1
         else 
            cart.accelerator_count = 1
         end
      elseif cat_a == col_categories.lines then
         local cart = b:getUserData()
         if cart.accelerator_count then
         cart.accelerator_count = cart.accelerator_count + 1
         else 
            cart.accelerator_count = 1
         end
      end
   end
end

function endContact(a, b, col)
   local cat_a = a:getCategory()
   local cat_b = b:getCategory()
   if cat_a == 2 or cat_b == 2 then
      if cat_a == col_categories.lines then
         local data = a:getUserData()
         table.insert(deferred_sensor_changes, {fixture = data.fixture, sensor_state = false})
      elseif cat_b == col_categories.lines then
         local data = b:getUserData()
         table.insert(deferred_sensor_changes, {fixture = data.fixture, sensor_state = false})
      end
   end

   -- decrease accelerator count currently colliding
   if cat_a == 4 or cat_b == 4 then
      if cat_b == col_categories.lines then
         local cart = a:getUserData()
         if cart.accelerator_count then -- keep count of accelerator colliders currently touching
         cart.accelerator_count = car.accelerator_count - 1
         else 
            cart.accelerator_count = 0
         end
      elseif cat_a == col_categories.lines then
         local cart = b:getUserData()
         if cart.accelerator_count then
         cart.accelerator_count = cart.accelerator_count - 1
         else 
            cart.accelerator_count = 0
         end
      end
   end
end

function love.update(dt)
   world:update(dt)

   for i, change in ipairs(deferred_sensor_changes) do
      change.fixture:setSensor(change.sensor_state)
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
      g:debug()
   end

   lg.setColor(1, 1, 1)
   local line_count = "lines:"..#ground
   lg.print(line_count, 10, 10)


   go_layer:draw()
end
