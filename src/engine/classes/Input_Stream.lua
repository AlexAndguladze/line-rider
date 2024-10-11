-- Used for recording/playback of joystick/keyboard/etc input events.
-- Doesn't replay the actual key events, but the ACTIONS.

local Input_Stream = Class:extend({
   recording_timestamp = 0,
   playback_idx = 1,
   playback_timestamp = 0,
   timeline = {},
})

function Input_Stream:init()
   self.timeline = self.timeline or {}

   -- This is used to return false when the state of a non-existent activity is
   -- requested so we avoid nil pointer exceptions
   local false_table = {}
   setmetatable(false_table, { __index = function() return false end })
   local mt = { __index = function() return false_table end }
   for frame_idx, frame in pairs(self.timeline) do
      setmetatable(frame.state, mt)
   end
end

function Input_Stream:record_frame(dt, actions_state)
   self.recording_timestamp = self.recording_timestamp + dt
   local frame = {
      timestamp = self.recording_timestamp,
      state = table.deep_copy_no_mt(actions_state)
   }
   table.insert(self.timeline, frame)
end

function Input_Stream:sort()
   table.sort(self.timeline, function(a, b)
      return a.timestamp < b.timestamp
   end)
end

-- NOTE: Assumes the stream timeline is sorted by timestamp ascending
function Input_Stream:advance(dt)
   local fuzz = 0.00002
   self.playback_timestamp = (self.playback_timestamp or 0) + dt

   local i = self.playback_idx

   if not self.timeline[i] then
      return self:get_state()
   end

   -- If index is ahead of playback time, don't advance (let it catch up)
   if self.timeline[i].timestamp >= self.playback_timestamp + fuzz then
      return self:get_state()
   end

   -- If index is behind playback time, advance
   while true do
      if not self.timeline[i+1] then break end
      if self.timeline[i+1].timestamp > self.playback_timestamp + fuzz then
         break
      end
      i = i + 1
   end
   self.playback_idx = i

   return self:get_state()
end

function Input_Stream:get_state()
   if self.timeline[self.playback_idx] then
      return self.timeline[self.playback_idx].state
   else
      return nil
   end
end

function Input_Stream:compress()
   for i=#self.timeline-1, 2, -1 do

      -- Squash duplicate frames
      local frame = self.timeline[i]
      local prev_frame = self.timeline[i-1]
      if table.deep_equals(frame.state, prev_frame.state) then
         table.remove(self.timeline, i)
      else

         -- Delete empty actions (where everything is false)
         for act_name, act_state in pairs(frame.state) do
            local can_delete = true
            for _, input_bool in pairs(act_state) do
               if input_bool == true then
                  can_delete = false
                  break
               end
            end
            if can_delete then
               frame.state[act_name] = nil
            end
         end
      end
   end

   return self
end

function Input_Stream:dump()
   return "return " .. inspect(self.timeline)
end

return Input_Stream
