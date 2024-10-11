local utf8 = require("utf8")

local lg = lg or love.graphics

local function get_clean_error(msg)
   -- Sanitize the traceback
   local san = {}
   for char in msg:gmatch(utf8.charpattern) do
      table.insert(san, char)
   end
   local san = table.concat(san)

   -- Concatenate and shorten the error
   local err = table.concat({
      "Man Pit just crashed!\n",
      san,
      #san ~= #msg and "Invalid UTF-8 string in error message.\n" or "\n",
   })
   err = err:gsub("%[string \"(.-)\"%]", "%1")

   return err
end

local function get_trace(msg, layer)
   local trace = debug.traceback( msg, 1 + (layer or 1)):gsub("\n[^\n]+$", "")
   return trace
end

function love.errorhandler(error_message)
   error_message = tostring(error_message)

   -- Log the error
   local trace = get_trace(error_message)
   print("Error: " .. trace)
   local report_sent = pcall(function() A.send_event("crash", trace) end)
   if not report_sent then print("Couldn't send crash report") end

   -- Get a clean version to display the error to the player
   local clean_error = get_clean_error(trace)

   -- Can't show the message to player
   if not love.window or not love.graphics or not love.event then
      return
   end

   -- Make window if we don't have one (i.e. when we crash before windowing)
   if not love.graphics.isCreated() or not love.window.isOpen() then
      local success, status = pcall(love.window.setMode, 800, 600)
      if not success or not status then
         return
      end
   end

   -- Reset state
   if love.mouse then
      love.mouse.setVisible(true)
      love.mouse.setGrabbed(false)
      love.mouse.setRelativeMode(false)
      if love.mouse.isCursorSupported() then
         love.mouse.setCursor()
      end
   end
   if love.joystick then
      -- Stop all joystick vibrations
      for i,v in ipairs(love.joystick.getJoysticks()) do
         v:setVibration()
      end
   end
   if love.audio then love.audio.stop() end
   lg.reset()
   lg.setColor(1, 1, 1, 1)
   lg.origin()

   -- Clipboard stuff
   local display_text = clean_error
   if love.system then
      display_text = display_text .. "\n\nPress Ctrl+C to copy this error"
   end
   local function copy_to_clipboard()
      if not love.system then return end
      love.system.setClipboardText(clean_error)
      display_text = display_text .. "\nCopied to clipboard!"
   end

   -- Layout
   local w, h = lg.getDimensions()
   local err_text_x = 70
   local err_text_y = 250
   local header_x = err_text_x
   local header_y = err_text_y - 70
   local sprite = {
      src = lg.newImage("assets/img/error_man_dead.png"),
      desired_w = 86,
      desired_h = 86,
      origin = {69/128, 68/128},
      draw = function(self, x, y, r)
         local ow, oh = self.src:getDimensions()
         local ox, oy = self.origin[1] * ow, self.origin[2] * oh

         local sx, sy = 1, 1
         if self.desired_w then
            sx = self.desired_w / ow
            if not self.desired_h then
               sy = sx
            end
         end
         if self.desired_h then
            sy = self.desired_h / oh
            if not self.desired_w then
               sx = sy
            end
         end

         lg.draw(self.src, x, y, r, sx, sy, ox, oy)
      end
   }
   local sprite_x = header_x + sprite.desired_w/2 + 15
   local sprite_y = header_y - sprite.desired_h/2 - 15

   local function draw()
      if not lg.isActive() then return end

      -- Background
      lg.clear(78/255, 87/255, 84/255) 

      -- Man sprite
      local r = love.timer.getTime()
      sprite:draw(sprite_x, sprite_y, r)

      -- Header
      lg.setFont(G.fonts.dbg_big)
      lg.printf("ERROR!\n", header_x, header_y, w)

      -- Error message
      lg.setFont(G.fonts.dbg_small)
      lg.printf(display_text, err_text_x, err_text_y, w - err_text_x)

      lg.present()
   end

   return function()
      love.event.pump()

      for e, a, b, c in love.event.poll() do
         if e == "quit" then
            return 1
         elseif e == "keypressed" then
            if a == "escape" then
               return 1
            elseif a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
               copy_to_clipboard()
            end
         elseif e == "touchpressed" then
            local name = love.window.getTitle()
            local buttons = {"OK", "Cancel"}
            if love.system then
               buttons[3] = "Copy to clipboard"
            end
            local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
            if pressed == 1 then
               return 1
            elseif pressed == 3 then
               copy_to_clipboard()
            end
         end
      end

      draw()

      if love.timer then
         love.timer.sleep(1/60)
      end
   end
end
