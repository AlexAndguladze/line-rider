local Stack = Class:extend({
   arr = {}
})

function Stack:init()
   self.arr = {}
end

function Stack:top()
   return self.arr[#self.arr]
end

function Stack:pop()
   if #self.arr == 0 then return nil end

   local item = self.arr[#self.arr]
   table.remove(self.arr, #self.arr)
   return item
end

function Stack:pop_all()
   while self:size() > 0 do
      self:pop()
   end
end

function Stack:push(item)
   table.insert(self.arr, item)
   return item
end

function Stack:size()
   return #self.arr
end

return Stack
