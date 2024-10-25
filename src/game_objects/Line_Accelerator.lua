local Line = require("game_objects/Line")

local Line_Accelerator = Line:extend({
   line_type = "accelerator"
})

function Line_Accelerator:init()
   Line.init(self)
end

function Line_Accelerator:draw()
   lg.setColor(1, 0, 1, 1)
   -- if self.fixture:isSensor() then
   --    lg.setColor(1, 1, 1, 0.2)
   -- end
   lg.setLineWidth(4)
   lg.line(self.x1, self.y1, self.x2, self.y2)
end

return Line_Accelerator