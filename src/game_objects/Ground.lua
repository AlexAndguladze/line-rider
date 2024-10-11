local Ground = Class:extend({
   body = nil,
   shape = nil,
   fixture = nil,
})
function Ground:destroy()
   self.body:destroy()
   self.fixture:destroy()
end