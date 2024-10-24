package main

import "core:fmt"
import "core:slice"
import rl "vendor:raylib"

Entety :: struct {
	pos:       Vec2f,
	speed:     f32,
	direction: Vec2f,
	texture:   rl.Texture2D,
	color:     rl.Color,
	health:    int,
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
	rl.DrawTextureEx(ent.texture, ent.pos, 0.0, camera.zoom, rl.WHITE)
}

EntetyDrawTint :: proc(ent: Entety, tint: rl.Color) {
	rl.DrawTextureEx(ent.texture, ent.pos, 0.0, camera.zoom, tint)
}

EntetySortList :: proc(
	arrayOfEnteties: [dynamic]Entety,
	arrayOfArrays: [dynamic][dynamic]Entety,
) -> [dynamic]Entety {
	arrayOfEnteties := arrayOfEnteties
	for array in arrayOfArrays {
		append(&arrayOfEnteties, ..array[:])
	}
	return EntetySortArray(arrayOfEnteties)
}

EntetySortArray :: proc(arrayOfEnteties: [dynamic]Entety) -> [dynamic]Entety {
	slice.sort_by(arrayOfEnteties[:], proc(entA: Entety, entB: Entety) -> bool {
		return entA.pos.y < entB.pos.y
	})
	return arrayOfEnteties
}

EntetySort :: proc {
	EntetySortArray,
	EntetySortList,
}
