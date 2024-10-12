local Line = Class:extend({
   x1 = 0,
   y1 = 0,
   x2 = 0,
   y2 = 0,
   phy_world = nil,
})
function Line:init()
   self.body = love.physics.newBody(self.phy_world, 0, 0, "static")
   self.shape = love.physics.newEdgeShape(self.x1, self.y1, self.x2, self.y2)
   self.fixture = love.physics.newFixture(self.body, self.shape)

   self.fixture:setCategory(col_categories.lines)
   self.fixture:setUserData(self)
   self.fixture:setMask(col_categories.lines)
   self.fixture:setSensor(false)
end
function Line:destroy()
   self.body:destroy()
   self.fixture:destroy()
end

return Line