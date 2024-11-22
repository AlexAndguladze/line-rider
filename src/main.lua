require("engine/init")
function love.run()
   return runtime.run()
end
go_layer = Deep:new()

Point = require("game_objects/Point")
Line = require("game_objects/Line")
Line_Accelerator = require("game_objects/Line_Accelerator")
Cart = require("game_objects/Cart")
Camera = require("game_objects/Camera")
Buttons_Panel = require("ui_elements/Buttons_Panel")
Button = require("ui_elements/Button")


local button_1 = Button:new({
   w=20,
   h=20,
})
local button_2 = Button:new({
   w=50,
   h=20,
})
local button_3 = Button:new({
   w=20,
   h=20,
})
local button_4 = Button:new({
   w=20,
   h=20,
})
local button_5 = Button:new({
   w=20,
   h=20,
})
local top_panel = Buttons_Panel:new({
   x = 50,
   y = 10,
   w = 300,
   h = 80,
   buttons = {button_1, button_2, button_3,button_4, button_5, button_6 },
})

local main_camera
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
local current_draw_line = 2

function love.load(args)
   love.physics.setMeter(64)
   local PIXELS_PER_METER = 100
   world = love.physics.newWorld(0, 9.81 * PIXELS_PER_METER, true)
   world:setCallbacks(beginContact, endContact)
   main_camera = Camera:new()
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
function convert_to_world_coordinates(x, y)
   local cam_x, cam_y = main_camera:get_offset()
   local adjusted_x, adjusted_y = x + cam_x, y + cam_y
   adjusted_x = adjusted_x / main_camera.zoom
   adjusted_y = adjusted_y / main_camera.zoom
   return adjusted_x, adjusted_y
end

function love.mousepressed(_x, _y, button)
   --Add first point in line buffer
   if button == 1 then
      points_buffer = {}
      local world_x, world_y = convert_to_world_coordinates(_x, _y)
      local point = Point:new({x = world_x, y = world_y})
      table.insert(points_buffer, point)
   elseif button == 2 then
      local world_x, world_y = convert_to_world_coordinates(_x, _y)
      local cart = Cart:new({x = world_x, y = world_y, phy_world = world})
      table.insert(game_objects, cart)
   elseif button == 3 then
      main_camera:start_drag(_x, _y)
   end

end

function love.mousereleased(_x, _y, button)
   if button == 1 and #points_buffer > 1 then
      set_lines()
      points_buffer = {}
   end
   if button == 3 then
      main_camera:end_drag()
   end
end

function love.wheelmoved(x, y)
   local zoom_speed = main_camera.zoom_unit
   if y > 0 then 
      main_camera:set_zoom_offset(1)
   elseif y < 0 then
      main_camera:set_zoom_offset(-1)
   end
end

function distance_between(x1, y1, x2, y2)
   return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end


function when_mouse_down(_x, _y, buttom)
   if #points_buffer > 0 then
      local world_x, world_y = convert_to_world_coordinates(_x, _y)
      local latest_point = points_buffer[#points_buffer]
      
      local distance = distance_between(world_x, world_y, latest_point.x, latest_point.y)
      if distance > draw_threshold then
         local point = Point:new({x = world_x, y = world_y})
         table.insert(points_buffer, point)
      end
   end
end

function beginContact(a, b, col)
   local cat_a = a:getCategory()
   local cat_b = b:getCategory()


   if cat_a == col_categories.line_sensors or cat_b == col_categories.line_sensors then
      if cat_a == col_categories.line_sensors then
         local data = a:getUserData()
         table.insert(deferred_sensor_changes, {fixture = data.fixture, sensor_state = true})
      elseif cat_b == col_categories.line_sensors then
         local data = b:getUserData()
         table.insert(deferred_sensor_changes, {fixture = data.fixture, sensor_state = true})
      end
   end
   --check for accelerator lines 
   if cat_a == col_categories.cart or cat_b == col_categories.cart then
      if cat_b == col_categories.lines and b:getUserData().line_type == "accelerator" then
         local cart = a:getUserData()
         if cart.accelerator_count then -- keep count of accelerator colliders currently touching
         cart.accelerator_count = car.accelerator_count + 1
         else 
            cart.accelerator_count = 1
         end
      elseif cat_a == col_categories.lines and a:getUserData().line_type == "accelerator" then
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
   if cat_a == col_categories.line_sensors or cat_b == col_categories.line_sensors then
      if cat_a == col_categories.line_sensors then
         local data = a:getUserData()
         table.insert(deferred_sensor_changes, {fixture = data.fixture, sensor_state = false})
      elseif cat_b == col_categories.line_sensors then
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
   main_camera:update(dt)

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

   top_panel:update()
end

function love.draw()
   lg.push()
   lg.translate(main_camera.x, main_camera.y)
   lg.scale(main_camera.zoom, main_camera.zoom)
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
    --camera drag end
   -- lg.setColor(1, 1, 1)
   -- lg.setLineWidth(5)
   -- for _, g in ipairs(ground) do
   --     love.graphics.line(g.shape:getPoints())
   -- end
   for _, g in ipairs(ground) do
      g:draw()
      --g:debug()
   end
   lg.pop()

   top_panel:draw()
   
   
   go_layer:draw()
end
