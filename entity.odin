package main

import rl "vendor:raylib"

Entety :: struct {
	pos:       Vec2f,
	speed:     f64,
	direction: Vec2i,
	texture:   rl.Texture2D,
}

EntetyMove :: proc(body: ^Entety) {
	body.pos +=
		Vec2f{f64(body.direction.x), f64(body.direction.y)} *
		body.speed *
		f64(rl.GetFrameTime() * 100)
}

EntetyDraw :: proc(ent: Entety) {
	rl.DrawTextureV(ent.texture, {f32(ent.pos.x), f32(ent.pos.y)}, rl.WHITE)
}
