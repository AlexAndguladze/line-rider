local Collider = Class:extend({
   -- events
   EV_ENTER = 1,
   EV_EXIT = 2,
   EV_NO_CHANGE = 3,
   EV_COLLIDING = 4,
   EV_NOT_COLLIDING = 5,

   print_debug_info = false,
   debug_colors = {
      ["active"] = {
         border = { 80/255, 110/255, 1, 0.8 },
         inside = { 80/255, 110/255, 1, 0.1 },
      },
      ["inactive"] = {
         border = { 0, 180/255, 0.5, 0.8 },
         inside = { 0, 180/255, 0.5, 0.1},
      },
      ["sensor"] = {
         border = { 0.4, 0.4, 0.5, 0.8 },
         inside = { 0.4, 0.4, 0.5, 0.1 },
      },
   },

   origin = "cc",

   x = 0,   y = 0,   -- top-left point
   w = 20,  h = 20,  -- used for init, then calculated based on scale each frame
   sx = 1,  sy = 1,
   lox = 0, loy = 0, -- lerp origin x and y (fractional, relative to top-left)

   ix = 0, iy = 0, -- center-center point (internal)
   iw = 0, ih = 0, -- size before scaling (internal)

   active = true,
   sensor = false,
   parent = nil,
})

function Collider:new(o)
   assert(o and type(o) == "table")
   assert(o.x ~= nil and o.y ~= nil)

   return Class.new(self, o)
end

function Collider:alt_new(parent_obj)
   return self:new({
      x = parent_obj.spawn_x,
      y = parent_obj.spawn_y,
      w = parent_obj.collider_w,
      h = parent_obj.collider_h,
      tag = parent_obj.collider_tag,
      origin = parent_obj.collider_origin,
      sensor = parent_obj.collider_sensor,
      parent = parent_obj,
   })
end

function Collider:init()
   Class.init(self)

   self.collisions = {}

   -- Set internal values
   self.ix = self.x
   self.iy = self.y
   self.iw = self.w
   self.ih = self.h

   -- Set origin
   local lox, loy = math.npg2xyl(self.origin)
   if lox then self.lox = lox end
   if loy then self.loy = loy end

   self:recalc()
end

function Collider:aabb(x1, y1, w1, h1)
   return x1 < self.x + self.w and self.x < x1 + w1 and
          y1 < self.y + self.h and self.y < y1 + h1
end

function Collider:aabb_point(px, py)
   return px >= self.x and px <= self.x + self.w and
          py >= self.y and py <= self.y + self.h
end

local function aabb_tbl(r1, r2)
   return
      r1.x < r2.x + r2.w and r2.x < r1.x + r1.w and
      r1.y < r2.y + r2.h and r2.y < r1.y + r1.h
end

function Collider:aabb_tbl(bb2)
   return aabb_tbl(self, bb2)
end

function Collider:recalc()
   self.w = self.iw * self.sx
   self.h = self.ih * self.sy

   self.x = self.ix - self.lox * self.w
   self.y = self.iy - self.loy * self.h
end

function Collider:set_position(x, y)
   self.ix = x or self.ix
   self.iy = y or self.iy
   self:recalc()
end

function Collider:set_position_by_nps(nps, x, y)
   self:set_position(x, y)
   local cx, cy = self:get_point(nps)
   local dx, dy = cx - x, cy - y
   self:set_position(x - dx, y - dy)
end

function Collider:get_position()
   return self.x + self.lox * self.w, self.y + self.loy * self.h
end

-- Returns point on collider based on x and y values in range [0, 1].
-- First arg can also be a 9-point string.
function Collider:get_point(lx, ly)
   if not lx then return self:get_position() end
   if not ly then
      -- lx is a 9-point string
      lx, ly = math.nps2xyl(lx)
   end

   return self.x + self.w * lx, self.y + self.h * ly
end

function Collider:get_rect()
   return self.x, self.y, self.w, self.h
end

function Collider:move(dx, dy)
   self.ix = self.ix + (dx or 0)
   self.iy = self.iy + (dy or 0)
   self:recalc()
end

function Collider:set_scale(sx, sy)
   self.sx = sx
   self.sy = sy
   self:recalc()
end

function Collider:set_size(w, h)
   self.iw = w or self.iw
   self.ih = h or self.ih
   self:recalc()
end

function Collider:check_self_collision(other_bb)
   local is_colliding = self.active and other_bb.active and aabb_tbl(self, other_bb)
   local was_colliding = self.collisions[other_bb] ~= nil

   if not was_colliding and is_colliding then
      self.collisions[other_bb] = other_bb
      return Collider.EV_ENTER
   end

   if not is_colliding and was_colliding then
      self.collisions[other_bb] = nil
      return Collider.EV_EXIT
   end

   return Collider.EV_NO_CHANGE
end

function Collider:check_both_collisions(other_bb)
   local is_colliding = self.active and other_bb.active and aabb_tbl(self, other_bb)
   local was_colliding = self.collisions[other_bb] ~= nil

   if not was_colliding and is_colliding then
      self.collisions[other_bb] = other_bb
      other_bb.collisions[self] = self
      return Collider.EV_ENTER
   end

   if not is_colliding and was_colliding then
      self.collisions[other_bb] = nil
      other_bb.collisions[self] = nil
      return Collider.EV_EXIT
   end

   return is_colliding and Collider.EV_COLLIDING or Collider.EV_NOT_COLLIDING
end

function Collider:exit_all_collisions()
   for other_bb in pairs(self.collisions) do
      self:exit_collision_with(other_bb)
   end
end

-- NOTE: To be used when other_bb was destroyed or is about to be destroyed
function Collider:exit_collision_with(other_bb)
   if other_bb and self.collisions[other_bb] then
      other_bb.collisions[self] = nil
      self.collisions[other_bb] = nil
   end

   return Collider.EV_EXIT
end

function Collider:get_overlap(other_bb)
   local bb1x, bb1y = self:get_point("cc")
   local bb1w, bb1h = self.w, self.h
   local bb2x, bb2y = other_bb:get_point("cc")
   local bb2w, bb2h = other_bb.w, other_bb.h

   -- Find horizontal overlap
   local overlap_x = 0
   if bb1x < bb2x then
      local rx = bb1x + bb1w/2 -- right edge of bb1 (bigger)
      local lx = bb2x - bb2w/2 -- left edge of bb2 (smaller)
      overlap_x = math.clamp(rx - lx, 0, math.inf)
   elseif bb2x < bb1x then
      local rx = bb2x + bb2w/2 -- right edge of bb2 (bigger)
      local lx = bb1x - bb1w/2 -- left edge of bb1 (smaller)
      overlap_x = math.clamp(lx - rx, -math.inf, 0)
   end

   -- Find vertical overlap
   local overlap_y = 0
   if bb1y < bb2y then
      local by = bb1y + bb1h/2 -- bottom edge of bb1 (bigger)
      local ty = bb2y - bb2h/2 -- top edge of bb2 (smaller)
      overlap_y = math.clamp(by - ty, 0, math.inf)
   elseif bb2y < bb1y then
      local by = bb2y + bb2h/2 -- bottom edge of bb2 (bigger)
      local ty = bb1y - bb1h/2 -- top edge of bb1 (smaller)
      overlap_y = math.clamp(ty - by, -math.inf, 0)
   end

   return overlap_x, overlap_y
end

function Collider:draw()
   -- Rectangle
   local colors = self.debug_colors[
      self.active and (self.sensor and "sensor" or "active") or "inactive"
   ]
   lg.bordered_rectangle(
      self.x,
      self.y,
      self.w,
      self.h,
      1,
      colors.inside,
      colors.border,
      0
   )

   -- Anchor point
   lg.setColor(0, 0, 0, 1)
   local x, y = self:get_position()
   lg.circle("fill", x, y, 2)
end

return Collider
