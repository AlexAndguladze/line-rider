local Ui_Manager = Class:extend({
   elements = {}
})

function Ui_Manager:init()
   self:sort_by_z()
end

function Ui_Manager:update()
   for _, element in ipairs(self.elements) do
      element:update()
   end
end

function Ui_Manager:draw()
   for _, element in ipairs(self.elements) do
      element:draw()
   end   
end

function Ui_Manager:sort_by_z()
   table.sort(self.elements, function(a, b)
      return a.z < b.z
   end)
end

function Ui_Manager:add_element(element)
   table.insert(self.elements, element)
   self:sort_by_z()
end

function Ui_Manager:is_cursor_hovering_any()
   local mx, my = love.mouse.getPosition()
   for _, element in ipairs(self.elements) do 
      if element:is_hovered(mx,my) then
         return true
      end
   end
   return false
end

return Ui_Manager