local Line = require("game_objects/Line")

local Line_Accelerator = Line:extend({
   line_type = "accelerator"
})

function Line_Accelerator:init()
   Line.init(self)
end

function Line_Accelerator:draw()
   lg.setColor(1, 1, 1, 1)
   -- if self.fixture:isSensor() then
   --    lg.setColor(1, 1, 1, 0.2)
   -- end
   lg.setLineWidth(4)
   lg.line(self.x1, self.y1, self.x2, self.y2)

   lg.setLineWidth(4)
   lg.line(self.x1, self.y1, self.x2, self.y2)

   local dx, dy = self.x2 - self.x1, self.y2 - self.y1
   local offset = 4
   local length = math.sqrt(dx^2 + dy^2)
   local perp_x = -dy / length
   local perp_y = dx / length
   
   local bottom_x1 = self.x1 + perp_x * offset
   local bottom_y1 = self.y1 + perp_y * offset
   local bottom_x2 = self.x2 + perp_x * offset
   local bottom_y2 = self.y2 + perp_y * offset

   lg.setColor(1, 1, 0)
   lg.setLineWidth(2)
   lg.line(bottom_x1, bottom_y1, bottom_x2, bottom_y2)
end

return Line_Accelerator