-- Extensions for the math namespace

math.inf = 1/0
math.nan = 0/0

function math.round(n)
   return math.floor(n + 0.5)
end

function math.trunc(n)
   return n >= 0 and n-n%1 or n-n%-1
end

function math.floor_towards_zero(n)
   return math.trunc(n)
end

function math.frac(n)
   return n < 0 and (n%(-1)) or (n%1)
end

function math.ceil_away_from_zero(n)
   return n >= 0 and n-n%-1 or n-n%1
end

function math.sign(n)
   if n > 0 then
      return 1
   elseif n < 0 then
      return -1
   else
      return 0
   end
end

-- 9-point string to x-y lerp.
-- Returns 2 numbers in the range [0, 1] based on input 9-point string. The
-- returned values are relative to top-left. For example, "bc" (bottom-center)
-- returns 0.5 and 1, "tr" (top-right) returns 1 and 0 and so on.
function math.nps2xyl(str)
   -- Determine y lerp
   local char_y = str:sub(1, 1)
   local y = 0
   if char_y == "t" then
      y = 0
   elseif char_y == "c" then
      y = 0.5
   elseif char_y == "b" then
      y = 1
   end

   -- Determine x lerp
   local char_x = str:sub(2, 2)
   local x = 0
   if char_x == "l" then
      x = 0
   elseif char_x == "c" then
      x = 0.5
   elseif char_x == "r" then
      x = 1
   end

   return x, y
end

-- 9-point-generic-to-x-y-lerp.
-- Returns lerped x and y just like nps2xyl but can take both a table or a string.
function math.npg2xyl(str_or_tbl)
   if type(str_or_tbl) == "string" then
      return math.nps2xyl(str_or_tbl)
   elseif type(str_or_tbl) == "table" then
      return str_or_tbl[1], str_or_tbl[2]
   else
      return nil, nil
   end
end

function math.clamp(x, min, max)
   if x < min then return min end
   if x > max then return max end
   return x
end

-- The same as pingpong
function math.snap(x, min, max)
   local d1 = math.abs(x - min)
   local d2 = math.abs(x - max)

   if d1 == d2 then
      return x
   elseif d1 < d2 then
      return min
   else
      return max
   end
end

function math.dampen(x, damping, deadzone)
   deadzone = deadzone or 0

   local damp_x = x * (1 - damping)

   if math.abs(damp_x) - deadzone <= 0 then
      return 0
   else
      return damp_x
   end
end

function math.lerp(from, to, amount)
   return from + (to - from) * amount
end

function math.slerp(from, to, amount)
   local smooth_amount = amount * amount * (3 - 2 * amount)
   return from + (to - from) * smooth_amount
end

function math.aabb(x1, y1, w1, h1, x2, y2, w2, h2)
   return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

function math.aabb_tbl(r1, r2)
   return
      r1.x < r2.x + r2.w and r2.x < r1.x + r1.w and
      r1.y < r2.y + r2.h and r2.y < r1.y + r1.h
end

function math.aabb_point(px, py, x, y, w, h)
   return px >= x and px <= x + w and
          py >= y and py <= y + h
end

function math.magnitude(x, y)
   return math.sqrt(x * x + y * y)
end
