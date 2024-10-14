package main

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"

camera: rl.Camera2D

GameState :: struct {
	entities: [dynamic]Entity,
}

Entity :: struct {
	position:  Vec2i,
	direction: Vec2i,
	color:     rl.Color,
	state:     ENTITY_STATE,
}

ENTITY_STATE :: enum {
	IDLE,
	WALK,
}

g_game_state: GameState

init :: proc() {
	rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Mikołaj")
	// rl.SetTargetFPS(60)
	sFPS = true
	// number := int(rand.int31_max(2000) + 100)
	number := 100000
	for n in 0 ..< number {
		// fmt.println(rl.TextFormat("%i", n))
		ent: Entity
		ent.color = rl.Color {
			u8(rand.int31_max(255)),
			u8(rand.int31_max(255)),
			u8(rand.int31_max(255)),
			255,
		}
		ent.position = {int(rand.int31_max(3000)) + 10, int(rand.int31_max(3000)) + 10}
		ent.state = ENTITY_STATE.WALK
		ent.direction = {int(rand.int31_max(3)) - 1, int(rand.int31_max(3)) - 1}
		append(&g_game_state.entities, ent)
	}

	camera = rl.Camera2D {
		zoom = 0.5,
	}
	// fmt.println(g_game_state.entities)
}

update :: proc() {
	for &ent in g_game_state.entities {
		rect := rl.Rectangle{f32(ent.position.x), f32(ent.position.y), CELL_SIZE, CELL_SIZE}
		if !rl.CheckCollisionRecs(
			rect,
			(rl.Rectangle) {
				0 + camera.offset.x,
				0 + camera.offset.y,
				WINDOW_SIZE / camera.zoom,
				WINDOW_SIZE / camera.zoom,
			},
		) {
			continue
		}
		ent.position += ent.direction
		if int(rand.int31_max(100)) == 1 {
			ent.direction = {int(rand.int31_max(3)) - 1, int(rand.int31_max(3)) - 1}
		}
	}
	camera.zoom += rl.GetMouseWheelMove() * 0.05
}

draw :: proc() {
	for &ent in g_game_state.entities {
		// fmt.println(ent.position.x)
		rect := rl.Rectangle{f32(ent.position.x), f32(ent.position.y), CELL_SIZE, CELL_SIZE}
		if !rl.CheckCollisionRecs(
			rect,
			(rl.Rectangle) {
				0 + camera.offset.x,
				0 + camera.offset.y,
				WINDOW_SIZE / camera.zoom,
				WINDOW_SIZE / camera.zoom,
			},
		) {
			continue
		}
		rl.DrawRectangleRec(rect, ent.color)

	}
}
