package main

import rl "vendor:raylib"
import "core:fmt"

Entety :: struct {
	pos:       Vec2f,
	speed:     f32,
	direction: Vec2f,
	texture:   rl.Texture2D,
	health : int
}

EntetyMove :: proc(body: ^Entety) {
	body.pos +=
		Vec2f{f32(body.direction.x), f32(body.direction.y)} *
		body.speed *
		f32(rl.GetFrameTime() * 100)
}

EntetyDraw :: proc {
	EntetyDrawNormal,
	EntetyDrawTint,
}

EntetyDrawNormal :: proc(ent: Entety) {
	rl.DrawTextureEx(ent.texture, ent.pos, 0.0, camera.zoom,rl.WHITE)
}

EntetyDrawTint :: proc(ent: Entety, tint : rl.Color) {
	rl.DrawTextureEx(ent.texture, ent.pos, 0.0, camera.zoom, tint)
}