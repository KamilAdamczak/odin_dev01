package main

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"

Player :: struct {
	using ent: Entety,
}

Tile :: struct {
	neighbourMask: int,
	isVisible:     bool,
}

Game_State :: struct {
	initialized: bool,
	playerPos:   Vec2i,
	worldGrid:   [WORLD_GRID.x][WORLD_GRID.y]Tile,
	camera:      rl.Camera2D,
}

g_Game_State := Game_State {
	initialized = false,
	camera = rl.Camera2D{offset = rl.Vector2{120, 80}, zoom = 1},
}


player := Player {
	ent = Entety{pos = {0, 0}, speed = 5},
}
camera := g_Game_State.camera
init :: proc() {
	sFPS.show = true
	rl.InitWindow(1280, 720, "vampire")
	icon: rl.Image
	icon = rl.LoadImage("./assets/ico.png")
	rl.SetWindowIcon(icon)
	player.texture = rl.LoadTexture("./assets/tile_texture.png")
}

update :: proc() {
	// if rl.IsMouseButtonDown(.LEFT) {
	// 	worldPos := screen_to_world(rl.GetMousePosition())
	// 	tile := get_tile(worldPos)
	// 	if tile != nil {
	// 		tile.isVisible = true
	// 	}
	// }
	// if rl.IsMouseButtonPressed(.RIGHT) {
	// 	worldPos := screen_to_world(rl.GetMousePosition())
	// 	tile := get_tile(worldPos)
	// 	if tile != nil {
	// 		tile.isVisible = false
	// 	}
	// }

	player_move()

	// g_Game_State.camera.zoom += rl.GetMouseWheelMove() * 0.1
}

late_update :: proc() {
}

player_move :: proc() {
	if rl.IsKeyDown(.A) {
		player.direction.x = -1
	}
	if rl.IsKeyDown(.D) {
		player.direction.x = 1
	}
	if rl.IsKeyDown(.W) {
		player.direction.y = -1
	}
	if rl.IsKeyDown(.S) {
		player.direction.y = 1
	}

	if rl.IsKeyReleased(.A) || rl.IsKeyReleased(.D) {
		player.direction.x = 0
	}

	if rl.IsKeyReleased(.W) || rl.IsKeyReleased(.S) {
		player.direction.y = 0
	}
	if player.direction != {0, 0} {
		EntetyMove(&player)
	}
}
// @(optimization_mode="favor_size")
draw :: proc() {
	worldPos := screen_to_world(rl.GetMousePosition())
	rl.DrawRectangleLines(
		i32(worldPos.x) * TILE_SIZE - i32(g_Game_State.camera.offset.x / g_Game_State.camera.zoom),
		i32(worldPos.y) * TILE_SIZE - i32(g_Game_State.camera.offset.y / g_Game_State.camera.zoom),
		TILE_SIZE,
		TILE_SIZE,
		rl.BLUE,
	)
	EntetyDraw(player)
}
