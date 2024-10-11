local http_client = (https or http)
if not http_client then return nil end

local fetch = {}
local src_dir = arg and arg[1] or ""
local eng_dir
-- NOTE: When launching the dist build .app on Macos, arg[1] is not needed.
if pathlib.ext(src_dir) == ".love" then
   eng_dir = "engine"
else
   eng_dir = src_dir .. "/" .. pathlib.dirname((...):match("(.-)[^/]*$"), 2)
end

local thread_code = string.gsub([[
   require("${eng_dir}/extensions/string")
   require("${eng_dir}/extensions/os")
   require("${eng_dir}/extensions/print")
   pathlib = require("${eng_dir}/libs/pathlib")
   creq = require("${eng_dir}/libs/creq")
   https = creq("${eng_dir}/clibs/https")
   fetch = require("${eng_dir}/libs/fetch")

   local url, body, channel = ...
   local response = fetch.request_sync(url, body)

   if channel then
      channel:push(response)
   end
]], "%${eng_dir}", eng_dir)

function fetch.request_threaded(url, body, channel)
   local thread = love.thread.newThread(thread_code)
   thread:start(url, body, channel)
end

function fetch.request_sync(url, body)
   local code, body, headers = http_client.request(url, body)
   return { code = code, body = body, headers = headers }
end

return fetch
