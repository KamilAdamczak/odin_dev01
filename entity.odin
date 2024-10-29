package main

import "core:fmt"
import "core:slice"
import rl "vendor:raylib"

Entity :: struct {
	pos:       Vec2f,
	speed:     f32,
	direction: Vec2f,
	texture:   rl.Texture2D,
	color:     rl.Color,
	health:    int,
}

EntityAtlas :: struct {
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

EntityMove :: proc(body: ^EntityAtlas) {
	body.pos +=
		Vec2f{f32(body.direction.x), f32(body.direction.y)} *
		body.speed *
		f32(rl.GetFrameTime() * 100)
}

EntityDraw :: proc {
	EntityDrawNormal,
	EntityDrawTint,
}

EntityDrawNormal :: proc(ent: EntityAtlas) {
	// rl.DrawTextureEx(ent.texture, ent.pos, 0.0, camera.zoom, rl.WHITE)
	rl.DrawTexturePro(
		ent.texture.texture,
		{
			f32(ent.texture.atlas_pos.x)*16,
			f32(ent.texture.atlas_pos.y)*16, 
			f32(ent.texture.texture_scale.x), 
			f32(ent.texture.texture_scale.y)},
		{
			f32(ent.pos.x),
			f32(ent.pos.y),
			16.0,
			16.0},
		{8,8},
		0.0,
		rl.WHITE)
}

EntityDrawTint :: proc(ent: EntityAtlas, tint: rl.Color) {
	rl.DrawTexturePro(
		ent.texture.texture,
		{
			f32(ent.texture.atlas_pos.x)*16,
			f32(ent.texture.atlas_pos.y)*16,
			ent.direction.x >= 0 ? f32(ent.texture.texture_scale.x) : -f32(ent.texture.texture_scale.x), 
			f32(ent.texture.texture_scale.y)},
		{
			f32(ent.pos.x),
			f32(ent.pos.y),
			16.0,
			16.0},
		{8,8},
		0.0,
		tint)
	// rl.DrawTextureEx(ent.texture, ent.pos, 0.0, camera.zoom, tint)
}

EntitySortList :: proc(
	arrayOfEntities: [dynamic]EntityAtlas,
	arrayOfArrays: [dynamic][dynamic]EntityAtlas,
) -> [dynamic]EntityAtlas {
	arrayOfEntities := arrayOfEntities
	for array in arrayOfArrays {
		append(&arrayOfEntities, ..array[:])
	}
	return EntitySortArray(arrayOfEntities)
}

EntitySortArray :: proc(arrayOfEntities: [dynamic]EntityAtlas) -> [dynamic]EntityAtlas {
	slice.sort_by(arrayOfEntities[:], proc(entA: EntityAtlas, entB: EntityAtlas) -> bool {
		return entA.pos.y < entB.pos.y
	})
	return arrayOfEntities
}

EntitySort :: proc {
	EntitySortArray,
	EntitySortList,
}
