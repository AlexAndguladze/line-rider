local Sound_Def = Class:extend({

   -- All vols are in range [0, 1]
   max_vol = 1, -- the base max volume, does not change at runtime
   global_vol = 1, -- passed to play() functions, global volume setting
   rel_vol = 1, -- passed to play() functions to change relative volume per play
   -- NOTE: rel_vol can't be larger than 1 so that we don't play louder than
   -- max_vol. If we did, we could accidentally disrespect the player's global
   -- sound settings when calculating final volume at play() invocation.

   source_type = "static",
   sources = nil, -- map of "name" -> Sound_Src
   loop = false,
   pitch = 1,
   min_delay = nil,
   max_inst = 1,
   last_play_timestamp = nil,
})

--[[
   shape of Sound_Src {
      instances = { array of objects like
         { timestamp = float, love_source = love.audio.Source }
      }
      file_path = "string",
      duration = float,
   }
--]]

function Sound_Def:init()
   self.sources = {}
   self.source_names = {}
end

function Sound_Def:add_source(name, path)
   -- Set up sound src
   local sound_src = {
      name = name,
      file_path = path,
      instances = {
         {
            timestamp = nil,
            love_source = love.audio.newSource(path, self.source_type)
         }
      },
   }
   sound_src.duration = sound_src.instances[1].love_source:getDuration("seconds")

   -- Insert into our sources table
   self.sources[name] = sound_src
   table.insert(self.source_names, name)
end

-- Returns a table of options for a single play invocation
function Sound_Def:opts_override(opts)
   if not opts then
      return self
   elseif not opts.__index then
      opts.__index = self
      setmetatable(opts, opts)
   end
   return opts
end

function Sound_Def:play_random(opts)
   if table.is_empty(self.sources) then
      printf("Error no Sound_Src to play for Sound_Def \"%s\".", self.name)
      return
   end

   opts = self:opts_override(opts)

   if opts.min_delay and self.last_play_timestamp and
         self.last_play_timestamp + opts.min_delay > love.timer.getTime() then
      return
   end

   local src = self.sources[rand.choice(self.source_names)]

   -- Find free instance that's not currently playing
   local instance = nil
   for i, inst in ipairs(src.instances) do
      if not inst.love_source:isPlaying() then
         instance = inst
         break
      end
   end
   if not instance then
      -- Create new instance if limit not reached
      if #src.instances < opts.max_inst then
         instance = table.deep_copy(src.instances[1])
         instance.love_source = src.instances[1].love_source:clone()
         table.insert(src.instances, instance)
         instance.love_source:stop()
      else
         -- Max limit reached, won't create new instance
         return
      end
   end

   -- Options are set at playtime (lazily)
   self:mod_instance(instance, opts)

   instance.love_source:play()
   instance.timestamp = love.timer.getTime()
   self.last_play_timestamp = instance.timestamp

   return src, instance
end

function Sound_Def:mod_instance(instance, opts)
   opts = self:opts_override(opts)

   instance.love_source:setLooping(opts.loop)
   instance.love_source:setPitch(opts.pitch)
   instance.love_source:setVolume(
      math.clamp(opts.rel_vol, 0, 1) *
      math.lerp(0, opts.max_vol, opts.global_vol)
   )
end

function Sound_Def:is_playing_any()
   for _, src in pairs(self.sources) do
      for _, inst in pairs(src.instances) do
         if inst.love_source:isPlaying() then
            return true
         end
      end
   end

   return false
end

function Sound_Def:stop_all()
   for _, src in pairs(self.sources) do
      for _, inst in pairs(src.instances) do
         inst.love_source:stop()
      end
   end
end

return Sound_Def
