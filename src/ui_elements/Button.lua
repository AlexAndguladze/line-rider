local Button = Class:extend({
   x = 0,
   y = 0,
   w = 10,
   h = 10,
   
})
function Button:is_hovered()
   local mx, my = love.mouse.getPosition()
   return mx >= self.x and mx < self.x + self.w and my >= self.y and my < self.y + self.h
end

function Button:update()
   if love.mouse.isDown(1) and self:is_hovered() then
      self:on_click()
   end
end

function Button:on_click()
 print("Clicked")
end

function Button:draw()
   lg.setColor(1, 0.5, 1)
   lg.rectangle("fill", self.x, self.y, self.w, self.h)
end

return Button