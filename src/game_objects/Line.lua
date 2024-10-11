local Line = Class:extend({
   body = nil,
   shape = nil,
   fixture = nil,
})
function Line:destroy()
   self.body:destroy()
   self.fixture:destroy()
end

return Line