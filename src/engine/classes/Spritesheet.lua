local Spritesheet = Class:extend({
   cell_padding = nil, -- set to 0 by default
})

function Spritesheet:new(o)
   assert(o.src)

   return Class.new(self, o)
end

function Spritesheet:init()
   self.w = self.src:getWidth()
   self.h = self.src:getHeight()

   self.cell_padding = self.cell_padding or 0
   self.cell_width = self.cell_width or self.w
   self.cell_height = self.cell_height or self.h

   local horiz_size = self.cell_padding * 2 + self.cell_width
   self.col_count = math.floor(self.w / horiz_size)

   local vert_size = self.cell_padding * 2 + self.cell_height
   self.row_count = math.floor(self.h / vert_size)

   self.cells = {}
   for r=1, self.row_count do
      local columns = {}
      local y = r * vert_size - self.cell_height - self.cell_padding
      for c=1, self.col_count do
         table.insert(columns, {
            x = c * horiz_size - self.cell_width - self.cell_padding,
            y = y,
        })
      end
      table.insert(self.cells, columns)
   end
end

function Spritesheet:make_sprite(cell_x, cell_y, q)
   local cell = self.cells[cell_y][cell_x]
   return Sprite:new({
      src = self.src,
      quad = {
         x = cell.x,
         y = cell.y,
         w = (q and q.w) or self.cell_width,
         h = (q and q.h) or self.cell_height,
      },
   })
end

function Spritesheet:make_all_sprites(sprite_opts)
   local sprites = {}

   for cell_x=1, self.col_count do
      for cell_y=1, self.row_count do
         local cell = self.cells[cell_y][cell_x]
         local spr = Sprite:new(table.deep_merge({
            src = self.src,
            quad = {
               x = cell.x,
               y = cell.y,
               w = self.cell_width,
               h = self.cell_height,
            },
         }, sprite_opts))
         table.insert(sprites, spr)
      end
   end

   return sprites
end

return Spritesheet
