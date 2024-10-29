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

EntetyAtlas :: struct {
	pos:       Vec2f,
	speed:     f32,
	direction: Vec2f,
	texture:   Sprite,
	color:     rl.Color,
	health:    int,
}

Sprite :: struct {
	texture : rl.Texture2D,
	atlas_pos : Vec2i,
	texture_scale : Vec2i,
}

EntetyMove :: proc(body: ^EntetyAtlas) {
	body.pos +=
		Vec2f{f32(body.direction.x), f32(body.direction.y)} *
		body.speed *
		f32(rl.GetFrameTime() * 100)
}

EntetyDraw :: proc {
	EntetyDrawNormal,
	EntetyDrawTint,
}

EntetyDrawNormal :: proc(ent: EntetyAtlas) {
	// rl.DrawTextureEx(ent.texture, ent.pos, 0.0, camera.zoom, rl.WHITE)
	rl.DrawTexturePro(ent.texture.texture, {f32(ent.texture.atlas_pos.x)*16, f32(ent.texture.atlas_pos.y)*16, f32(ent.texture.texture_scale.x), f32(ent.texture.texture_scale.y)}, {f32(ent.pos.x), f32(ent.pos.y), 16.0, 16.0}, {0,0}, 0.0,rl.WHITE)
}

EntetyDrawTint :: proc(ent: EntetyAtlas, tint: rl.Color) {
	rl.DrawTexturePro(ent.texture.texture, {f32(ent.texture.atlas_pos.x)*16, f32(ent.texture.atlas_pos.y)*16, f32(ent.texture.texture_scale.x), f32(ent.texture.texture_scale.y)}, {f32(ent.pos.x), f32(ent.pos.y), 16.0, 16.0}, {0,0}, 0.0,ent.color)
	// rl.DrawTextureEx(ent.texture, ent.pos, 0.0, camera.zoom, tint)
}

EntetySortList :: proc(
	arrayOfEnteties: [dynamic]EntetyAtlas,
	arrayOfArrays: [dynamic][dynamic]EntetyAtlas,
) -> [dynamic]EntetyAtlas {
	arrayOfEnteties := arrayOfEnteties
	for array in arrayOfArrays {
		append(&arrayOfEnteties, ..array[:])
	}
	return EntetySortArray(arrayOfEnteties)
}

EntetySortArray :: proc(arrayOfEnteties: [dynamic]EntetyAtlas) -> [dynamic]EntetyAtlas {
	slice.sort_by(arrayOfEnteties[:], proc(entA: EntetyAtlas, entB: EntetyAtlas) -> bool {
		return entA.pos.y < entB.pos.y
	})
	return arrayOfEnteties
}

EntetySort :: proc {
	EntetySortArray,
	EntetySortList,
}
