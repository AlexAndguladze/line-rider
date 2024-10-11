local eng_dir = (...):match("(.-)[^/]*$")

-- Load extensions (global namespaced functions)
require(eng_dir .. "extensions/print")
require(eng_dir .. "extensions/pairs")
require(eng_dir .. "extensions/string")
require(eng_dir .. "extensions/table")
require(eng_dir .. "extensions/math")
require(eng_dir .. "extensions/rand")
require(eng_dir .. "extensions/os")
require(eng_dir .. "extensions/graphics")

-- Aliases/shorthands
fmt = string.format
lg = love.graphics
lm = love.math

-- Load libraries
inspect  = require(eng_dir .. "libs/inspect")
pathlib  = require(eng_dir .. "libs/pathlib")
filelib  = require(eng_dir .. "libs/filelib")
dirload  = require(eng_dir .. "libs/dirload")
lfs      = require(eng_dir .. "libs/lfs_ffi")
colorhex = require(eng_dir .. "libs/colorhex")
uuid     = require(eng_dir .. "libs/uuid")
json     = require(eng_dir .. "libs/json")
creq     = require(eng_dir .. "libs/creq")
https    = creq(eng_dir .. "clibs/https")
steam    = creq(eng_dir .. "clibs/luasteam")
fetch    = require(eng_dir .. "libs/fetch")

-- Load mixins
mixins = dirload("mixins")

-- Load shaders
--shaders = dirload("shaders")

-- Load classes
Class =        require(eng_dir .. "classes/Class")
Vector =       require(eng_dir .. "classes/Vector")
Stack =        require(eng_dir .. "classes/Stack")
Sprite =       require(eng_dir .. "classes/Sprite")
Spritesheet =  require(eng_dir .. "classes/Spritesheet")
Tween =        require(eng_dir .. "classes/Tween")
Timer =        require(eng_dir .. "classes/Timer")
Anim =         require(eng_dir .. "classes/Anim")
Camera_Shake = require(eng_dir .. "classes/Camera_Shake")
Camera =       require(eng_dir .. "classes/Camera")
Deep =         require(eng_dir .. "classes/Deep")
Collider =     require(eng_dir .. "classes/Collider")
Shake =        require(eng_dir .. "classes/Shake")
Spring =       require(eng_dir .. "classes/Spring")
Term   =       require(eng_dir .. "classes/Term")
Sound_Def =    require(eng_dir .. "classes/Sound_Def")

-- Input handling classes
Input =            require(eng_dir .. "classes/Input")
Keyboard_Input =   require(eng_dir .. "classes/Keyboard_Input")
Mouse_Input =      require(eng_dir .. "classes/Mouse_Input")
Joystick_Input =   require(eng_dir .. "classes/Joystick_Input")
Joystick_Manager = require(eng_dir .. "classes/Joystick_Manager")
Input_Mapper =     require(eng_dir .. "classes/Input_Mapper")
Input_Stream =     require(eng_dir .. "classes/Input_Stream")

-- Runtime
runtime = require(eng_dir .. "runtime")
