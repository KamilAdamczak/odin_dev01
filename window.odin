package main

import rl "vendor:raylib"

guiWindow :: struct {
    texture : rl.Texture2D,
    rec : rl.Rectangle,
    nPatchInfo : rl.NPatchInfo,
}
 
createGuiWindow :: proc(sprite : Sprite, pos : Vec2f, size : Vec2f, offsets : [4]i32, layout : rl.NPatchLayout) -> guiWindow {
    return {
        texture = sprite.texture,
        rec = {pos.x, pos.y, size.x, size.y},
        nPatchInfo = {
            {
                cast(f32)sprite.atlas_pos.x*16, 
                cast(f32)sprite.atlas_pos.y*16, 
                cast(f32)sprite.texture_scale.x, 
                cast(f32)sprite.texture_scale.y
            },
            offsets[0],
            offsets[1],
            offsets[2],
            offsets[3],
            layout
        }   
    }
}
drawGuiWindow :: proc {
    drawGuiWindowArray,
    drawGuiWindowSingle,
}

drawGuiWindowArray :: proc(guiWindows : ..guiWindow) {
    for guiWin in guiWindows {
        rl.DrawTextureNPatch(guiWin.texture, guiWin.nPatchInfo, guiWin.rec, {guiWin.rec.width/2, guiWin.rec.height/2}, 0, rl.WHITE)
    }
}


drawGuiWindowSingle :: proc(guiWin : guiWindow) {
    rl.DrawTextureNPatch(guiWin.texture, guiWin.nPatchInfo, guiWin.rec, {guiWin.rec.width/2, guiWin.rec.height/2}, 0, rl.WHITE)
}

updateGuiWindow :: proc(windows : ..^guiWindow) {
    for &window in windows {
    window.rec = {
        cast(f32)rl.GetScreenWidth()/2,
        cast(f32)rl.GetScreenHeight()/2,
        cast(f32)rl.GetScreenWidth()*0.75,
		cast(f32)rl.GetScreenHeight()*0.75
		}
    }
}