package main

import "core:fmt"
import "core:slice"
import "core:math"
import rl "vendor:raylib"

Entity :: struct {
	pos:       Vec2f,
	speed:     f32,
	direction: Vec2f,
	texture:   Sprite,
	color:     rl.Color,
	health:    int,
	collider:  Collider,
	id:        string,
	rotation:  f32,
}

Collider :: struct {
	pos : Vec2f,
	type: ColliderType,
	size: Vec2f,
}

ColliderType :: enum {
	BOX,
	RECT,
	OVAL,
}

createEntity :: proc(
	position : Vec2f = 0, spd : f32 = 0, dir : Vec2f = {0,0}, 
	spr : Sprite = g_Game_State.whiteSquareTexture, col : rl.Color = rl.WHITE, 
	hp : int = 0, coll : Collider, identification : string = "", 
	rot : f32 = 0.0) -> (ent : Entity) {
	ent = Entity {
		pos  = position,
		speed     = spd,
		direction = dir,
		texture   = spr,
		color     = col,
		health    = hp,
		collider  = coll,
		id        = identification,
		rotation  = rot,
	}
	ent.collider.pos = ent.pos
	return ent
}

getColliderRect :: proc(ent: Entity) -> rl.Rectangle {
	rect := rl.Rectangle {
		f32(ent.pos.x) - f32(ent.texture.texture_scale.x) / 2,
		f32(ent.pos.y) - f32(ent.texture.texture_scale.y) / 2,
		ent.collider.size.x,
		ent.collider.size.y,
	}
	return rect
}

getColliderCircle :: proc(ent: Entity) -> Circle {
	circ := Circle{rl.Vector2{ent.pos.x, ent.pos.y}, ent.collider.size.x}
	return circ
}

checkCollision :: proc(entA: Entity, entB: Entity) -> bool {
	switch entA.collider.type {
	case .OVAL:
		switch entB.collider.type {
		case .OVAL:
			return rl.CheckCollisionCircles(
				getColliderCircle(entA).center,
				getColliderCircle(entA).r,
				getColliderCircle(entB).center,
				getColliderCircle(entB).r,
			)
		case .RECT, .BOX:
			return rl.CheckCollisionCircleRec(
				getColliderCircle(entA).center,
				getColliderCircle(entA).r,
				getColliderRect(entB),
			)
		}
	case .RECT, .BOX:
		switch entB.collider.type {
		case .OVAL:
			return rl.CheckCollisionCircleRec(
				getColliderCircle(entB).center,
				getColliderCircle(entB).r,
				getColliderRect(entA),
			)
		case .RECT, .BOX:
			return rl.CheckCollisionRecs(getColliderRect(entA), getColliderRect(entB))
		}
	}
	return false
}



SetColliderEnt :: proc(type: ColliderType, ent: Entity) -> Collider {
	col: Collider
	col.type = type
	switch type {
	case .BOX:
		col.size = {f32(ent.texture.texture_scale.x), f32(ent.texture.texture_scale.x)}
	case .RECT:
		col.size = {f32(ent.texture.texture_scale.x), f32(ent.texture.texture_scale.x)}
	case .OVAL:
		col.size = {f32(ent.texture.texture_scale.x) / 2, 0}
	}
	return col
}

SetColliderSize :: proc(type: ColliderType, size: Vec2f) -> Collider {
	col: Collider
	col.type = type
	switch type {
	case .BOX:
		col.size = size
	case .RECT:
		col.size = size
	case .OVAL:
		col.size = size
	}
	return col
}
SetCollider :: proc {
	SetColliderEnt,
	SetColliderSize,
}

EntityMove :: proc(body: ^Entity) {
	body.pos +=
	rl.Vector2Normalize(body.direction) *
		body.speed *
		f32(rl.GetFrameTime() * 100)
	if body.direction.x < 0 {
		body.texture.flip = true
	} else if body.direction.x > 0 {
		body.texture.flip = false
	}
	body.collider.pos = body.pos
}

EntityFutureMove :: proc(body: Entity) -> Entity {
	body := body
	body.pos +=
		Vec2f{f32(body.direction.x), f32(body.direction.y)} *
		body.speed *
		f32(rl.GetFrameTime() * 100)
	return body
}

EntityDraw :: proc {
	EntityDrawNormal,
	EntityDrawTint,
}

EntityDrawNormal :: proc(ent: Entity) {
	// rl.DrawTextureEx(ent.texture, ent.pos, 0.0, camera.zoom, rl.WHITE)
	rl.DrawTexturePro(
		ent.texture.texture,
		{
			f32(ent.texture.atlas_pos.x) * 16,
			f32(ent.texture.atlas_pos.y) * 16,
			f32(ent.texture.texture_scale.x),
			f32(ent.texture.texture_scale.y),
		},
		{f32(ent.pos.x), f32(ent.pos.y), 16.0, 16.0},
		{8, 8},
		0.0,
		rl.WHITE,
	)
}

EntityDrawTint :: proc(entities: ..Entity, tint: rl.Color = rl.WHITE) {
	for ent in entities {
		if DRAW_COLLIDERS && LOOP_STATE == .DRAW_SPRITES {
			switch ent.collider.type {
			case .BOX:
				rl.DrawRectangleLines(
					i32(ent.pos.x) - i32(ent.texture.texture_scale.x) / 2,
					i32(ent.pos.y) - i32(ent.texture.texture_scale.y) / 2,
					i32(ent.collider.size.x),
					i32(ent.collider.size.y),
					ent.color != {} ? ent.color : tint,
				)
			case .OVAL:
				rl.DrawCircleLines(i32(ent.pos.x), i32(ent.pos.y), ent.collider.size.x, ent.color != {} ? ent.color : tint,)
			case .RECT:
				rl.DrawRectangleLines(
					i32(ent.pos.x) - i32(ent.texture.texture_scale.x) / 2,
					i32(ent.pos.y) - i32(ent.texture.texture_scale.y) / 2,
					i32(ent.collider.size.x),
					i32(ent.collider.size.y),
					ent.color != {} ? ent.color : tint,
				)
			}
		}

		rl.DrawTexturePro(
			ent.texture.texture,
			{
				f32(ent.texture.atlas_pos.x) * 16,
				f32(ent.texture.atlas_pos.y) * 16,
				!ent.texture.flip ? f32(ent.texture.texture_scale.x) : -f32(ent.texture.texture_scale.x),
				f32(ent.texture.texture_scale.y),
			},
			{f32(ent.pos.x)+ent.texture.offset.x, f32(ent.pos.y)+ent.texture.offset.y, f32(ent.texture.texture_scale.x), f32(ent.texture.texture_scale.y)},
			{8, 8},
			ent.rotation,
			ent.color != {} ? ent.color : tint,
		)
	}
}

EntitySortList :: proc(	arrayOfEntities: [dynamic]Entity,	arrayOfArrays: [dynamic][dynamic]Entity,) -> [dynamic]Entity {
	arrayOfEntities := arrayOfEntities
	for array in arrayOfArrays {
		// fmt.println(array)
		append(&arrayOfEntities, ..array[:]) 
	}
	return EntitySortArray(arrayOfEntities)
}

EntitySortArray :: proc(arrayOfEntities: [dynamic]Entity) -> [dynamic]Entity {
	slice.sort_by(arrayOfEntities[:], proc(entA: Entity, entB: Entity) -> bool {
		return entA.pos.y < entB.pos.y
	})
	return arrayOfEntities
}

EntitySort :: proc {
	EntitySortArray,
	EntitySortList,
}

getColliderRectCol :: proc(coll: Collider) -> rl.Rectangle {
	rect := rl.Rectangle {
		f32(coll.pos.x) - f32(coll.size.x) / 2,
		f32(coll.pos.y) - f32(coll.size.y) / 2,
		coll.size.x,
		coll.size.y,
	}
	return rect
}

getColliderCircleCol :: proc(coll: Collider) -> Circle {
	circ := Circle{rl.Vector2{coll.pos.x, coll.pos.y}, coll.size.x}
	return circ
}

checkCollisionCollider :: proc(collA: Collider, collB: Collider) -> bool {
	switch collA.type {
	case .OVAL:
		switch collB.type {
		case .OVAL:
			return rl.CheckCollisionCircles(
				getColliderCircleCol(collA).center,
				getColliderCircleCol(collA).r,
				getColliderCircleCol(collB).center,
				getColliderCircleCol(collB).r,
			)
		case .RECT, .BOX:
			return rl.CheckCollisionCircleRec(
				getColliderCircleCol(collA).center,
				getColliderCircleCol(collA).r,
				getColliderRectCol(collB),
			)
		}
	case .RECT, .BOX:
		switch collB.type {
		case .OVAL:
			return rl.CheckCollisionCircleRec(
				getColliderCircleCol(collB).center,
				getColliderCircleCol(collB).r,
				getColliderRectCol(collB),
			)
		case .RECT, .BOX:
			return rl.CheckCollisionRecs(getColliderRectCol(collA), getColliderRectCol(collB))
		}
	}
	return false
}