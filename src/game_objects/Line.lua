local Line = Class:extend({
   x1 = 0,
   y1 = 0,
   x2 = 0,
   y2 = 0,
   x = 0,
   y = 0,
   sensor_w = 5,
   sensor_h = 5,
   phy_world = nil,
})
local sensor_extra_offset = 3
function Line:init()
   self.body = love.physics.newBody(self.phy_world, 0, 0, "static")
   self.shape = love.physics.newEdgeShape(self.x1, self.y1, self.x2, self.y2)
   self.fixture = love.physics.newFixture(self.body, self.shape)
   self.fixture:setUserData(self)
   self.fixture:setCategory(col_categories.lines)
   self.fixture:setMask(col_categories.lines)
   self.fixture:setSensor(false)
   self.sensor_h = 30
   self.x = self.x2 - self.x1
   self.y = self.y2 - self.y1
   self.sensor_w = math.sqrt(self.x^2 + self.y^2)
   -- (-y x) clockwise perpendicular direction vector
   local mid_offset_magnitude = math.sqrt(self.x^2 + self.y^2)
   local mid_x, mid_y = (self.x1 + self.x2) / 2, (self.y1 + self.y2) / 2
   -- offset mids
   local mid_x_new = mid_x + ((self.sensor_h / 2) + sensor_extra_offset) * (-self.y / mid_offset_magnitude)
   local mid_y_new = mid_y + ((self.sensor_h /2) + sensor_extra_offset) * (self.x / mid_offset_magnitude) 

   local sensor_angle = math.atan2(self.y2 - self.y1, self.x2 - self.x1)

   self.sensorBody = love.physics.newBody(self.phy_world, mid_x_new, mid_y_new, "static")
   self.sensorShape = love.physics.newRectangleShape(0, 0, self.sensor_w, self.sensor_h)
   self.sensorFixture = love.physics.newFixture(self.sensorBody, self.sensorShape)
   self.sensorBody:setAngle(sensor_angle)
   self.sensorFixture:setUserData(self)
   self.sensorFixture:setSensor(true)
   self.sensorFixture:setCategory(col_categories.line_sensors)
   --self.sensorFixture:setMask(col_categories.line_sensors, col_categories.lines)
end
function Line:destroy()
   self.body:destroy()
   self.fixture:destroy()
   self.sensorBody:destroy()
   self.sensorFixture:destory()
end

function Line:draw()
   lg.setColor(1, 1, 1, 1)
   -- if self.fixture:isSensor() then
   --    lg.setColor(1, 1, 1, 0.2)
   -- end
   lg.setLineWidth(4)
   lg.line(self.x1, self.y1, self.x2, self.y2)
end

function Line:debug()
   lg.setColor(1, 0.5, 0)

   lg.setLineWidth(1)
   local sensor_x, sensor_y = self.sensorBody:getPosition()
   local sensor_angle = self.sensorBody:getAngle()

   -- Midpoint between the two points (line's midpoint)
   local mid_x, mid_y = (self.x1 + self.x2) / 2, (self.y1 + self.y2) / 2

   -- Adjust the midpoint to position the sensor slightly off the line
   local mid_offset_magnitude = math.sqrt(self.x^2 + self.y^2)
   local mid_x_new = mid_x + ((self.sensor_h / 2) + sensor_extra_offset) * (-self.y / mid_offset_magnitude)
   local mid_y_new = mid_y + ((self.sensor_h / 2) + sensor_extra_offset) * (self.x / mid_offset_magnitude)

   -- Translate and rotate the sensor rectangle
   lg.push()
   lg.translate(sensor_x, sensor_y)
   lg.rotate(sensor_angle)

   -- Draw the rectangle
   -- Adjust position to center the sensor around mid_x_new, mid_y_new
   lg.rectangle("line", -self.sensor_w / 2, -self.sensor_h / 2, self.sensor_w, self.sensor_h)
   lg.pop()
end

return Line