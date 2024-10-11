local Joystick_Manager = Class:new({
   poll_timeout = 1,
   joysticks = nil,
   on_joysticks_removed = nil,
   on_joysticks_added = function(added, self)
      for i, j in ipairs(added) do
         j:setVibration(1, 1, 0.2)
      end
   end,
})

function Joystick_Manager:init()
   self.poll_timer = Timer:new()
   self.poll_timer:every(self.poll_timeout, function()
      self:poll()
   end)
end

function Joystick_Manager:update(dt)
   self.poll_timer:update(dt)
end

function Joystick_Manager:poll()
   local new_joysticks = love.joystick.getJoysticks()
   local added, removed = self:check_joysticks_changed(new_joysticks)

   -- Joysticks added
   if not table.is_empty(added) then
      if self.on_joysticks_added then
         self.on_joysticks_added(added, self)
      end
   end

   -- Joysticks removed
   if not table.is_empty(removed) then
      if self.on_joysticks_removed then
         self.on_joysticks_removed(removed, self)
      end
   end

   if new_joysticks == nil then
      self.joysticks = {}
   else
      self.joysticks = new_joysticks
   end
end

function Joystick_Manager:check_joysticks_changed(new_joysticks)
   -- Both are empty
   if self.joysticks == nil and new_joysticks == nil then
      return {}, {}
   end

   -- All added
   if self.joysticks == nil and new_joysticks then
      local added = table.deep_copy(new_joysticks)
      local removed = {}

      return added, removed
   end

   -- All removed
   if self.joysticks and new_joysticks == nil then
      local added = {}
      local removed = table.deep_copy(self.joysticks)

      return added, removed
   end

   -- Check added
   local added = {}
   for i, j in ipairs(new_joysticks) do
      local j2 = self:find_joystick_by_id(j:getID(), self.joysticks)
      if not j2 then table.insert(added, j) end
   end

   -- Check removed
   local removed = {}
   for i, j in pairs(self.joysticks) do
      local j2 = self:find_joystick_by_id(j:getID(), new_joysticks)
      if not j2 then table.insert(removed, j) end
   end

   return added, removed
end

function Joystick_Manager:find_joystick_by_id(jid, joysticks)
   for i, j in ipairs(joysticks) do
      if j:getID() == jid then
         return j
      end
   end

   return nil
end

-- Fills the state of all joystick inputs in given array
function Joystick_Manager:capture_all(joystick_inputs_array)
   for i=1, math.min(#joystick_inputs_array, #self.joysticks) do
      joystick_inputs_array[i]:capture_all(self.joysticks[i])
   end

   return joystick_inputs_array
end

-- Returns console of first joystick "xbox"/"playstation"/"none"
function Joystick_Manager:get_console()
   for i, j in ipairs(self.joysticks) do
      local name = string.lower(j:getName())
      if name:match("playstation") or name:match("dualshock") or
         name:match("ps4") or name:match("ps3") or name:match("ps2") or 
         name:match("ps1") then
         return "playstation"
      else
         return "xbox"
      end
   end

   return nil
end

return Joystick_Manager
