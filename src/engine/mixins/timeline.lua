local timeline = {}

function timeline.reset_timeline(obj)
   obj.prev_ms_since_load = 0
   obj.ms_since_load = 0
   obj.tweens = {}
   obj.springs = {}
end

function timeline.update_timeline(obj, dt)
   -- Step through the timeline
   obj.ms_since_load = obj.ms_since_load + dt * 1000
   for i=obj.prev_ms_since_load, math.floor(obj.ms_since_load) do
      if obj.timeline_by_ms[i] then
         obj.timeline_by_ms[i](obj)
      end
   end
   obj.prev_ms_since_load = math.floor(obj.ms_since_load)

   -- Perform all tweens
   for _, t in pairs(obj.tweens) do
      t:update(dt)
   end

   -- Update all springs
   for _, s in pairs(obj.springs) do
      s:update(dt)
   end

   -- Skip
   if obj.timeline_skip_check and obj:timeline_skip_check(dt) then
      obj:finish_timeline(obj)
   end
end

return timeline
