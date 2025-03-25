local Buttons_Panel = Class:extend({
   x = 0,
   y = 0,
   z = 0,
   w = 0,
   h = 0,
   buttons = {},
   display = "center",
   button_padding = 2
})
function Buttons_Panel:init()
   self:align_buttons()
end

function Buttons_Panel:is_hovered(mx, my)
   if x == nil and y == nil then
      mx, my = love.mouse.getPosition()
   end
   return mx >= self.x and mx < self.x + self.w and my >= self.y and my < self.y + self.h
end

function Buttons_Panel:update()
   -- for i, btn in ipairs(self.buttons) do
   --    btn:update()
   -- end
end

function Buttons_Panel:draw()
   lg.setColor(1, 0.8, 1, 1)
   lg.rectangle("fill", self.x, self.y, self.w, self.h)
  
   --self:draw_buttons()
end

function Buttons_Panel:align_buttons()
   local width_sum  = 0
   for i, btn in ipairs(self.buttons) do 
      width_sum = width_sum + btn.w + self.button_padding*2
   end

   --local current_x = (self.x + self.w - width_sum)/2 + self.button_padding
   local current_x = self.x +self.w/2 - width_sum/2
   for i, btn in ipairs(self.buttons) do
      local current_y = self.y + self.h/2 - btn.h/2
      btn.x = current_x
      btn.y = current_y 
      current_x = current_x + btn.w + self.button_padding * 2
   end
end

-- function Buttons_Panel:draw_buttons()
--    for i, btn in ipairs(self.buttons) do
--       btn:draw()
--    end
-- end

return Buttons_Panel