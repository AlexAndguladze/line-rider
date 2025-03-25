Ui_Manager = require("ui_elements/Ui_Manager")
Button = require("ui_elements/Button")
Buttons_Panel = require("ui_elements/Buttons_Panel")

local ui_manager = Ui_Manager:new({
   elements = {}
})

function resize_on_hover(btn, dt)
   --reach button parameters
   local speed = 10
   btn.w = btn.w + (55 - btn.w) * speed * dt
   btn.h = btn.h + (55 - btn.h) * speed * dt


   local scale_x = btn.w / 50
   local scale_y = btn.h / 50
   btn.sprite:scale(scale_x) 
end

local draw_btn = Button:new({
   w=50,
   h=50,
   sprite = Sprite:new({
      src = lg.newImage("assets/img/ui_brush_btn.png"),
      origin = "cc"
   }),
   name = "draw_normal",
   on_hover = function(self, dt) 
      self.sprite:set_origin(self.w/2, self.h/2)
      resize_on_hover(self, dt) 
   end,
})
local draw_accelerator_btn = Button:new({
   w=50,
   h=50,
   sprite = Sprite:new({
      src = lg.newImage("assets/img/ui_accelerator_btn.png"),
      origin ="cc"
   }),
   name = "draw_accelerator",
   on_hover = function(self, dt) 
      self.sprite:set_origin(self.w/2, self.h/2)
      resize_on_hover(self, dt) 
   end,
})

local top_panel = Buttons_Panel:new({
   x = 50,
   y = 10,
   z =  -10,
   w = 300,
   h = 70,
   buttons = {draw_btn,draw_accelerator_btn},
})

ui_manager:add_element(draw_btn)
ui_manager:add_element(draw_accelerator_btn)
ui_manager:add_element(top_panel)

return ui_manager

