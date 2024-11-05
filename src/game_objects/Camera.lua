local Camera = Class:extend({
   x = 0, 
   y = 0,
   is_drag = false,
   drag_start = {x = 0, y = 0},
   zoom = 1,
   zoom_unit = 0.1,
})

function Camera:start_drag(x, y)
   self.is_drag = true
   self.drag_start.x, self.drag_start.y = x, y
end

function Camera:end_drag()
   self.is_drag = false
end

function Camera:update(dt)
   if self.is_drag then
      local mouse_x, mouse_y = love.mouse.getPosition()
      self.x = self.x + (mouse_x - self.drag_start.x)
      self.y = self.y + (mouse_y - self.drag_start.y)
      self.drag_start.x, self.drag_start.y = mouse_x, mouse_y
   end
end
function Camera:get_offset()
   return -self.x, -self.y
end

function Camera:set_zoom_offset(sign)
   local mouse_x, mouse_y = love.mouse.getPosition()
   
   local world_x = (mouse_x - self.x) / self.zoom
   local world_y = (mouse_y - self.y) / self.zoom

   self.zoom = self.zoom + sign * self.zoom_unit
   self.zoom = math.max(0.1, math.min(self.zoom, 5))

   self.x = mouse_x - world_x * self.zoom
   self.y = mouse_y - world_y * self.zoom
end

function Camera:draw()
   lg.push()
   lg.translate(-self.x, -self.y)
   lg.pop()
end

return Camera