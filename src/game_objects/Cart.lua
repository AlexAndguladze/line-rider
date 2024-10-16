local Cart = Class:extend({
   x = 0,
   y = 0,
   w = 64,
   h = 30,
   phy_world = nil,
   accelerator_count = 0,
})

function Cart:init()
   self.body = love.physics.newBody(self.phy_world, self.x, self.y, "dynamic")
   self.shape = love.physics.newRectangleShape(self.w, self.h)
   self.fixture = love.physics.newFixture(self.body, self.shape)
   self.body:setMass(2)
   self.fixture:setFriction(0.02)
   self.fixture:setCategory(col_categories.cart)
   self.fixture:setUserData(self)

end

function Cart:update(dt)
   if self.accelerator_count > 0 then
      self.body:applyForce(1000, 0)
   end
end

function Cart:draw()
   lg.setColor(1, 1, 1)

   local x, y = self.body:getPosition()
   local angle = self.body:getAngle()

   lg.push()
   lg.translate(x, y)
   lg.rotate(angle)
   lg.rectangle("fill", -self.w / 2, -self.h /2, self.w, self.h)
   lg.pop()

end

return Cart