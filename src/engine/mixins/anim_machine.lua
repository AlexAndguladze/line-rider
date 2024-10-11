local anim_machine = {}

function anim_machine.set_anim(obj, new_anim)
   if not new_anim then return end
   if obj.anims.current == new_anim then return end
   obj.anims.current:reset()
   obj.anims.current = new_anim
end

return anim_machine
