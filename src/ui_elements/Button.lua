local Button = Class:extend({
   x = 0,
   y = 0,
   w = 10,
   h = 10,
   
   mouse_btn = 1,
   is_down = false,
})
function Button:is_hovered()
   local mx, my = love.mouse.getPosition()
   return mx >= self.x and mx < self.x + self.w and my >= self.y and my < self.y + self.h
end

function Button:update()
   -- button click once
   if self.is_down == false and love.mouse.isDown(self.mouse_btn) and self:is_hovered() then
      self.is_down = true
   elseif self.is_down == true and not love.mouse.isDown(self.mouse_btn) then
      self.is_down = false
      if self:is_hovered() then -- not call if mouse moved away
         self:on_click()
      end
   end
   
end

function Button:on_click()
   print("Clicked once")
end
-- function Button:on_mouse_down()
--    print("Click continuously")
-- end

function Button:draw()
   lg.setColor(1, 0.5, 1)
   lg.rectangle("fill", self.x, self.y, self.w, self.h)
end

return Button