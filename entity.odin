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
	collider : Collider,
}

Collider :: struct {
	type: ColliderType,
	size: Vec2f,
}

SetColliderEnt :: proc(type : ColliderType, ent : EntityAtlas) -> Collider {
	col : Collider
	col.type = type
	switch type {
		case .BOX: col.size = {f32(ent.texture.texture_scale.x), f32(ent.texture.texture_scale.x)}
		case .RECT: col.size = {f32(ent.texture.texture_scale.x), f32(ent.texture.texture_scale.x)}
		case .OVAL: col.size = {f32(ent.texture.texture_scale.x)/2,0}
	}
	return col
}

SetColliderSize :: proc(type : ColliderType, size : Vec2f) -> Collider {
	col : Collider
	col.type = type
	switch type {
		case .BOX: col.size = size
		case .RECT: col.size = size
		case .OVAL: col.size = size
	}
	return col
}

SetCollider :: proc {
	SetColliderEnt,
	SetColliderSize,
}

ColliderType :: enum {
	BOX,
	RECT,
	OVAL,
}

EntityAtlas :: struct {
	pos:       Vec2f,
	speed:     f32,
	direction: Vec2f,
	texture:   Sprite,
	color:     rl.Color,
	health:    int,
	collider: Collider,
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
	if DRAW_COLLIDERS {
		switch ent.collider.type {
			case .BOX: rl.DrawRectangleLines(i32(ent.pos.x) - i32(ent.texture.texture_scale.x)/2, i32(ent.pos.y)  - i32(ent.texture.texture_scale.y)/2, i32(ent.collider.size.x), i32(ent.collider.size.y), tint)
			case .OVAL: rl.DrawCircleLines(i32(ent.pos.x) , i32(ent.pos.y) , ent.collider.size.x, tint)
			case .RECT: rl.DrawRectangleLines(i32(ent.pos.x) - i32(ent.texture.texture_scale.x)/2, i32(ent.pos.y)  - i32(ent.texture.texture_scale.y)/2, i32(ent.collider.size.x), i32(ent.collider.size.y), tint)
		}
		
	}
	
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
