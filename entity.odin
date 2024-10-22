package main

import rl "vendor:raylib"

Entety :: struct {
	pos : Vec2f,
	speed : f64,
    texture : rl.Texture2D,
}

EntetyMove :: proc(body : ^Entety, dir : Vec2f) {
	body.pos += dir * body.speed * f64(rl.GetFrameTime()*100)
}

EntetyDraw :: proc(ent : Entety) {
    rl.DrawTextureV(
    ent.texture,
    {
        f32(ent.pos.x),
        f32(ent.pos.y),
    },
    rl.WHITE,
    ) 
	rl.DrawRectangleLines(
		i32(ent.pos.x) * TILE_SIZE - i32(g_Game_State.camera.offset.x / g_Game_State.camera.zoom),
		i32(ent.pos.y) * TILE_SIZE - i32(g_Game_State.camera.offset.y / g_Game_State.camera.zoom),
		TILE_SIZE,
		TILE_SIZE,
		rl.BLUE,
	)
}