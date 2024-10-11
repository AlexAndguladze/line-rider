-- Functions for the table namespace

table.default_sort = table.sort
function table.sort(t, fn)
   table.default_sort(t, fn)
   return t
end

function table.is_empty(tbl)
   if not tbl then return true end

   local k = next(tbl)
   return k == nil
end

-- Return next value from the table and cycle if last
function table.cycle_fwd(tbl, cur)
   if not tbl then return nil end

   local idx = table.find(tbl, cur)

   if not idx or idx == #tbl then -- loop forwards
      return tbl[1]
   else
      return tbl[idx+1]
   end
end

-- Return previous value from the table and cycle if first
function table.cycle_bwd(tbl, cur)
   if not tbl then return nil end

   local idx = table.find(tbl, cur)

   if not idx or idx == 1 then -- loop backwards
      return tbl[#tbl]
   else
      return tbl[idx-1]
   end
end

-- Shuffles in-place
function table.shuffle(arr)
   local shuf_count = #arr-1
   for i=1, shuf_count do
      local j = rand.int(i, #arr)
      arr[i], arr[j] = arr[j], arr[i]
   end

   return arr
end

function table.wrap_idx(tbl, idx)
   local sz = #tbl
   local i = idx % sz
   return i == 0 and sz or i
end

function table.assign(into, from)
   if not from then return into end
   if not into then return from end

   for k, v in pairs(from) do
      into[k] = v
   end
   return into
end

function table.reverse(arr)
   local len = #arr
   for i=1, math.floor(len/2) do
      arr[i], arr[len-i+1] = arr[len-i+1], arr[i]
   end
   return arr
end

-- Fills in the holes in an array, but disregards the ordering
function table.quick_squash(arr, len)
   local i = 1
   while true do
      if i >= len then break end
      if arr[i] == nil then
         arr[i] = arr[len]
         arr[len] = nil
         len = len - 1
      end
      i = i + 1
   end

   return arr, len
end

function table.shallow_copy(t, except)
   except = except or {}
   local newt = {}
   for k, v in pairs(t) do
      if not except[k] then
         newt[k] = v
      end
   end
   return newt
end

-- Copies the table deeply, INCLUDING metatables
function table.deep_copy(t)
   if type(t) ~= "table" then return t end

   local ret = {}
   for k, v in pairs(t) do
      ret[table.deep_copy(k)] = table.deep_copy(v)
   end
   setmetatable(ret, table.deep_copy(getmetatable(t)))
   return ret
end

-- Copies the table deeply, EXCLUDING metatables
function table.deep_copy_no_mt(t)
   if type(t) ~= "table" then return t end

   local ret = {}
   for k, v in pairs(t) do
      ret[table.deep_copy(k)] = table.deep_copy(v)
   end
   return ret
end

-- Merge t1 <- t2. Fields in t2 overwrite those in t1.
function table.deep_merge(t1, t2)
   if t1 == nil then t1 = {} end
   if t2 == nil then return t1 end

   for k, v in pairs(t2) do
      if type(v) == "table" and type(t1[k]) == "table" then
         table.deep_merge(t1[k], v)
      else
         t1[k] = v
      end
   end

   return t1
end

function table.deep_equals(tbl1, tbl2)
   if type(tbl1) ~= "table" or type(tbl2) ~= "table" then
      return false
   end

   -- Check tbl1 subset of tbl2
   for k, v1 in pairs(tbl1) do
      local v2 = tbl2[k]

      -- Call comparison function if values are tables
      if type(v1) == "table" then
         if not table.deep_equals(v1, v2) then
            return false
         end
      else
         if v1 ~= v2 then
            return false
         end
      end
   end

   -- Check tbl2 subset of tbl1
   -- Here we only need to check if keys that tbl2 has exist in tbl1
   -- because if we reached this line, that means each value at `key`
   -- in tbl1 was also present in tbl2 in the same location
   for k, _ in pairs(tbl2) do
      if tbl1[k] == nil then
         return false
      end

      -- No need to check for table comparison, because if v1 and v2
      -- are tables, that means they were compared in the previous
      -- loop and ended up equal
   end

   return true
end

function table.filter(tbl, fn)
   if not tbl then return nil end
   if not fn then return nil end

   local ret = {}
   for idx, v in ipairs(tbl) do
      if fn(v, idx, tbl) then
         table.insert(ret, v)
      end
   end
   return ret
end

function table.find_fn(tbl, fn)
   if not tbl then return nil end
   if not fn then return nil end

   for k, v in pairs(tbl) do
      if fn(v, k) then
         return k
      end
   end

   return nil
end

function table.find(tbl, val)
   if not tbl then return nil end
   if not val then return nil end

   for k, v in pairs(tbl) do
      if v == val then
         return k
      end
   end

   return nil
end

function table.filter_fn(tbl, fn)
   if not tbl then return nil end

   local filtered = {}

   for _, v in pairs(tbl) do
      if fn(v, k, tbl) then
         table.insert(filtered, v)
      end
   end

   return filtered
end

function table.keys(tbl)
   local keys = {}

   for k in pairs(tbl) do
      table.insert(keys, k)
   end

   return keys
end

function table.values(tbl)
   local values = {}

   for _, v in pairs(tbl) do
      table.insert(values, v)
   end

   return values
end

-- Like Array.prototype.filter in js
function table.filter(tbl, fn)
   local ret = {}

   for i, v in ipairs(tbl) do
      if fn(v, i, tbl) then
         table.insert(ret, v)
      end
   end

   return ret
end

function table.shallow_append(arr1, arr2)
   for i in ipairs(arr2) do
      table.insert(arr1, arr2[i])
   end

   return arr1
end
