package main

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"

camera: rl.Camera2D

Tile :: struct {
	neighbourMask: int,
	isVisible:     bool,
}

Game_State :: struct {
	initialized: bool,
	playerPos:   Vec2i,
	worldGrid:   [WORLD_GRID.x][WORLD_GRID.y]Tile,
}

g_Game_State := Game_State {
	initialized = false,
}

get_tile :: proc {
	get_tile_Vec2i,
	get_tile_xy,
}

get_tile_xy :: proc(x: int, y: int) -> ^Tile {
	tile: ^Tile = nil

	if x >= 0 && x <= WORLD_GRID.x && y >= 0 && y <= WORLD_GRID.y {
		tile = &g_Game_State.worldGrid[x][y]
	}

	return tile
}

get_tile_Vec2i :: proc(worldPos: Vec2i) -> ^Tile {
	x := worldPos.x / TILE_SIZE
	y := worldPos.y / TILE_SIZE

	return get_tile(x, y)
}

screen_to_world :: proc(screen_pos: rl.Vector2) -> Vec2i {
	xPos := f32(screen_pos.x) / TILE_SIZE / camera.zoom
	xPos += camera.offset.x
	yPos := f32(screen_pos.y) / TILE_SIZE / camera.zoom
	yPos += camera.offset.y


	return {int(xPos), int(yPos)}
}


init :: proc() {
	rl.SetTargetFPS(60)
	sFPS.show = true
	camera = rl.Camera2D {
		offset = rl.Vector2{160, 90},
		zoom   = 1,
	}
	rl.InitWindow(WORLD_WIDTH * TILE_SIZE / 2, WORLD_HEIGHT * TILE_SIZE / 2, "celeste")
	icon: rl.Image
	icon = rl.LoadImage("./assets/ico.png")
	rl.SetWindowIcon(icon)
}

update :: proc() {

	if rl.IsMouseButtonPressed(.LEFT) {
		worldPos := screen_to_world(rl.GetMousePosition())
		tile := get_tile(worldPos)
		if tile != nil {
			tile.isVisible = true
		}
	}
	if rl.IsMouseButtonPressed(.RIGHT) {
		worldPos := screen_to_world(rl.GetMousePosition())
		tile := get_tile(worldPos)
		if tile != nil {
			tile.isVisible = false
		}
	}


	// camera.zoom += rl.GetMouseWheelMove() * 0.05
}

late_update :: proc() {
}

draw :: proc() {
	for x in 0 ..< WORLD_GRID.x {
		for y in 0 ..< WORLD_GRID.y {
			tile := get_tile(x, y)
			if (!tile.isVisible) {
				continue
			}
			rl.DrawRectangleRec(
				rl.Rectangle {
					f32(x) * TILE_SIZE * 2 - camera.offset.x,
					f32(y) * TILE_SIZE * 2 - camera.offset.y,
					8 * TILE_SIZE * 2,
					8 * TILE_SIZE * 2,
				},
				rl.RED,
			)
		}
	}
}
