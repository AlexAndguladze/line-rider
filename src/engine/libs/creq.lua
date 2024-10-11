-- Safely requires C library with the correct extension (.dll, .so ...)

assert(love and love.filesystem and love.filesystem.getSourceBaseDirectory)
assert(os.is_windows)
assert(os.is_linux)
assert(os.is_osx)
assert(printf)
assert(pathlib)
local fmt = string.format

local src_dir = ""
if arg and arg[1] and #arg[1] > 0 then
   src_dir = arg[1]
end

local creq = function(path)
   local file_name = pathlib.filename(path)
   local exe_dir = love.filesystem.getSourceBaseDirectory()

   local req_abs_path = pathlib.join(exe_dir, src_dir, pathlib.dirname(path))
   local old_cpath = package.cpath

   if os.is_windows() then
      package.cpath =
         req_abs_path .. "\\windows\\?.dll;" ..
         req_abs_path .. "\\windows\\?.lib;" ..
         "?.lib;" ..
         "?.dll;" .. package.cpath
   elseif os.is_osx() then
      package.cpath =
         -- When launched using directory (e.g. 'love .' or 'love src/')
         req_abs_path .. "/osx/?.dylib;" ..
         req_abs_path .. "/osx/?.so;" ..

         -- When launched as an .app or with .love file
         -- (e.g. 'open mygame.app' or 'love mygame.love')
         exe_dir .. "/?.dylib;" ..
         exe_dir .. "/?.so;" ..

         "?.dylib;" ..
         "?.so;" .. package.cpath
   elseif os.is_linux() then
      package.cpath =
         req_abs_path .. "/linux/?.so;" ..
         req_abs_path .. "/linux/?.a;" ..

         -- When launched using an appimage build
         exe_dir .. "/?.so;" ..
         exe_dir .. "/?.a;" ..

         "?.so;" ..
         "?.a;" .. package.cpath
   end

   local suc, ret = pcall(require, file_name)
   package.cpath = old_cpath

   if suc then return ret end
   printf("creq(\"%s\") failed in \"%s\": %s", path, req_abs_path, ret)

   return nil
end

return creq
