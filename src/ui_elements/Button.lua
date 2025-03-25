local Button = Class:extend({
   x = 0,
   y = 0,
   z = 0,
   w = 10,
   h = 10,
   on_hover = nil,
   on_click = nil,
   on_mouse_down = nil,
   mouse_btn = 1,
   is_down = false,
   name = "",
   sprite = nil,
   color = {r = 1, g = 1, b = 1, a = 1}
})

function Button:is_hovered(mx, my)
   if x == nil and y == nil then
      mx, my = love.mouse.getPosition()
   end
   return mx >= self.x and mx < self.x + self.w and my >= self.y and my < self.y + self.h
end

function Button:update(dt)
   -- button click once
   if self.on_hover and self:is_hovered() then 
      self.on_hover(self, dt)
   end
   if self.is_down == false and love.mouse.isDown(self.mouse_btn) and self:is_hovered() then
      self.is_down = true
   elseif self.is_down == true and not love.mouse.isDown(self.mouse_btn) then
      self.is_down = false
      if self.on_click and self:is_hovered() then -- call if only mouse is still hovered above
         self.on_click()
      end
   end

   if self.on_mouse_down then
      if self.is_down == true and love.mouse.isDown(self.mouse_btn) and self:is_hovered() then
         self.on_mouse_down()
      end
   end
end

function Button:draw()
   
   lg.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
   if self.sprite then
      self.sprite:draw(self.x + self.w/2, self.y + self.h/2)
   else 
      lg.rectangle("fill", self.x, self.y, self.w, self.h)
   end
end

return Button