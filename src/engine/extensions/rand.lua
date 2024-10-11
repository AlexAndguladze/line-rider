rand = rand or {}

local rfn = math.random
if love and love.math and love.math.random then
   rfn = love.math.random
end

function rand.set_seed(seed)
   if rfn == love.math.random then
      love.math.setRandomSeed(seed)
   else
      math.randomseed(seed)
   end
end

function rand.int(min, max)
   return rfn(min, max)
end

function rand.normal(stddev, mean)
   return love.math.randomNormal(stddev, mean)
end

-- NOTE: Generates in range [min, max)
function rand.float(min, max)
   return min + rfn() * (max - min)
end

function rand.sign()
   return rfn() < 0.5 and -1 or 1
end

function rand.bool()
   return rfn() < 0.5
end

function rand.roll(chance)
   return rfn() < chance
end

function rand.choice(tbl)
   local idx = rand.int(1, #tbl)
   return tbl[idx], idx
end

-- choice => wieght mapping
function rand.weighted_choice(tbl)
   local sum = 0
   for _, v in pairs(tbl) do
      assert(v >= 0, "weight value less than zero")
      sum = sum + v
   end
   assert(sum ~= 0, "all weights are zero")
   local rnd = rand.float(0, sum)
   for k, v in pairs(tbl) do
      if rnd < v then return k end
      rnd = rnd - v
   end
end

-- choices is an array and weights is choice => weight
function rand.weighted_choice_two(choices, weights)
   local sum = 0
   for k, ch in pairs(choices) do
      local v = weights[ch] or 1
      sum = sum + v
   end
   assert(sum ~= 0, "all weights are zero")
   local rnd = rand.float(0, sum)
   for k, ch in pairs(choices) do
      local v = weights[ch] or 1
      if rnd < v then return ch end
      rnd = rnd - v
   end
end
