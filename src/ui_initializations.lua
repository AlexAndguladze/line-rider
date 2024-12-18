Ui_Manager = require("ui_elements/Ui_Manager")
Button = require("ui_elements/Button")
Buttons_Panel = require("ui_elements/Buttons_Panel")

local ui_manager = Ui_Manager:new({
   elements = {}
})

local button_1 = Button:new({
   w=50,
   h=50,
})
local button_2 = Button:new({
   w=50,
   h=50,
})
local button_3 = Button:new({
   w=50,
   h=50,
})
local button_4 = Button:new({
   w=50,
   h=50,
})
local button_5 = Button:new({
   w=50,
   h=50,
})
local top_panel = Buttons_Panel:new({
   x = 50,
   y = 10,
   z =  -10,
   w = 300,
   h = 70,
   buttons = {button_1, button_2, button_3,button_4, button_5 },
})

ui_manager:add_element(button_1)
ui_manager:add_element(button_2)
ui_manager:add_element(button_3)
ui_manager:add_element(button_4)
ui_manager:add_element(button_5)
ui_manager:add_element(top_panel)

return ui_manager

