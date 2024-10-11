local Anim = {
   start_x = 0,
   start_y = 0,
   width = 64,
   height = 64,
   ox = nil,
   oy = nil,
   off_x = 0,
   off_y = 0,
   sx = 1,
   sy = 1,
   dir = "horiz", -- horiz/vert
   origin = "cc", -- bc/cc/tc/tl/tr
   frame_count = nil,
   delay = 0.1,
   delay_ms = nil,
   debug_mode = false,

   sheet_width = nil,
   sheet_height = nil,
   quads = nil,
   current_quad_idx = 1,
   frame_time = nil, -- How long we've been drawing the current frame
}

function Anim:new(o)
   assert(o and type(o) == "table")
   assert(o.spritesheet or o.src)

   local instance = o or {}
   setmetatable(instance, self)
   self.__index = self

   instance:init()
   return instance
end

local function min(a, b)
   return a < b and a or b
end

function Anim:init()
   self.spritesheet = self.spritesheet or self.src

   -- Defaults
   self.quads = {}
   self.sheet_width = self.spritesheet:getWidth()
   self.sheet_height = self.spritesheet:getHeight()
   self.width = min(self.width, self.sheet_width)
   self.height = min(self.height, self.sheet_height)
   if not rawget(self, "delay") and rawget(self, "delay_ms") then
      self.delay = self.delay_ms / 1000
   end
   self.current_quad_idx = 1
   self.frame_time = 0

   -- Set sx to scale to desired width
   if self.desired_w then
      self.sx = self.desired_w / self.width
      if not self.desired_h then
         self.sy = self.sx
      end
   end

   -- Set sy to scale to desired height
   if self.desired_h then
      self.sy = self.desired_h / self.height
      if not self.desired_w then
         self.sx = self.sy
      end
   end

   self:align_origin(self.origin)

   if self.dir ~= "horiz" and self.dir ~= "vert" then
      print("Anim: dir can only be \"horiz\" or \"vert\"")
      self.dir = "horiz"
   end

   if self.frame_count < 1 then
      print("Anim: frame_count < 1")
      return nil
   end

   if self.start_x > self.sheet_width then
      print("Anim: start_x > sheet_width")
      return nil
   end

   if self.start_y > self.sheet_height then
      print("Anim: start_y > sheet_width")
      return nil
   end

   local sheet_width = self.sheet_width
   local sheet_height = self.sheet_height

   -- Populate quads array
   local f = 0
   if self.dir == "horiz" then
      for y=self.start_y, sheet_height, self.height do
         for x=self.start_x, sheet_width, self.width do
            if x + self.width <= sheet_width and
               y + self.height <= sheet_height then
               table.insert(self.quads, love.graphics.newQuad(
                  x, y,
                  self.width, self.height,
                  sheet_width, sheet_height
               ))

               f = f + 1
               if f >= self.frame_count then
                  goto finish_iter
               end
            end
         end
      end
   elseif self.dir == "vert" then
      for x=self.start_x, sheet_width, self.width do
         for y=self.start_y, sheet_height, self.height do
            if x + self.width <= sheet_width and
               y + self.height <= sheet_height then
               table.insert(self.quads, love.graphics.newQuad(
                  x, y,
                  self.width, self.height,
                  sheet_width, sheet_height
               ))

               f = f + 1
               if f >= self.frame_count then
                  goto finish_iter
               end
            end
         end
      end
   end

   ::finish_iter::
   if #self.quads < 1 then
      if self.debug_mode then
         print(inspect(self))
      end
      print("Anim: no quads in animation!")
      print(debug.traceback())
      return nil
   end
   return self
end

function Anim:align_origin(origin)
   self.origin = origin

   local lox, loy = math.npg2xyl(self.origin)
   self.ox = self.ox or ((lox or 0.5) * self.width)
   self.oy = self.oy or ((loy or 0.5) * self.height)

   return self
end

-- Set the internal scale
function Anim:scale(sx, sy)
   self.sx = sx
   self.sy = sy
   return self
end

function Anim:update(dt)
   if #self.quads < 1 then
      return
   end
   
   if self.delay <= 0 then
      return
   end

   self.frame_time = self.frame_time + dt
   if self.frame_time > self.delay then
      self.frame_time = self.frame_time - self.delay
      self.current_quad_idx = self.current_quad_idx + 1
      if self.current_quad_idx > #self.quads then
         self.current_quad_idx = 1
      end
   end
end

function Anim:get_rect(x, y, sx, sy)
   local tsx = self.sx * (sx or 1)
   local tsy = self.sy * (sy or 1)

   return
      x + (self.off_x * tsx),
      y + (self.off_y * tsy),
      self.width * tsx,
      self.height * tsy
end

function Anim:draw(x, y, r, sx, sy, kx, ky, ox, oy)
   if #self.quads < 1 then
      return
   end

   local tsx = self.sx * (sx or 1)
   local tsy = self.sy * (sy or 1)
   kx = kx or 0
   ky = ky or 0

   love.graphics.draw(
      self.spritesheet,
      self.quads[self.current_quad_idx],
      x + tsx * self.off_x,
      y + tsy * self.off_y,
      r or 0,
      tsx,
      tsy,
      ox or self.ox,
      oy or self.oy,
      kx,
      ky
   )

   if self.debug_mode then
      love.graphics.print('frame idx: ' .. self.current_quad_idx, x, y)
      love.graphics.print('\nframe time: ' .. self.frame_time, x, y)
   end
end

Anim.draw_centered = Anim.draw

function Anim:reset()
   self.current_quad_idx = 1
end

return Anim
