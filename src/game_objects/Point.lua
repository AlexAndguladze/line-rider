local Point = Class:extend({
   x = 0,
   y = 0,
})

function Point:init()

end

function Point:draw()
   lg.setColor(1, 1, 1)
   lg.circle("fill", self.x, self.y, 3)
end

return Point