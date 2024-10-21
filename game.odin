package main

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"

camera: rl.Camera2D

Tile :: struct {
	neighbourMask: int,
	isVisible:     bool,
}

tileTexture: rl.Texture2D

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
	x := worldPos.x
	y := worldPos.y

	return get_tile(x, y)
}

screen_to_world :: proc(screen_pos: rl.Vector2) -> Vec2i {
	xPos := f32(screen_pos.x) / TILE_SIZE / camera.zoom
	yPos := f32(screen_pos.y) / TILE_SIZE / camera.zoom

	return {int(xPos), int(yPos)}
}


init :: proc() {
	// rl.SetTargetFPS(60)
	sFPS.show = true
	camera = rl.Camera2D {
		offset = rl.Vector2{180, 90},
		zoom   = 1,
	}

	rl.InitWindow(1280, 720, "celeste")
	icon: rl.Image
	icon = rl.LoadImage("./assets/ico.png")
	rl.SetWindowIcon(icon)
	tileTexture = rl.LoadTexture("./assets/tile_texture.png")
}

update :: proc() {

	if rl.IsMouseButtonDown(.LEFT) {
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


	camera.zoom += rl.GetMouseWheelMove() * 0.1
}

late_update :: proc() {
}
draw :: proc() {
	worldPos := screen_to_world(rl.GetMousePosition())
	// fmt.println(worldPos)
	rl.DrawRectangleLines(
		i32(worldPos.x) * TILE_SIZE - i32(camera.offset.x / camera.zoom),
		i32(worldPos.y) * TILE_SIZE - i32(camera.offset.y / camera.zoom),
		TILE_SIZE,
		TILE_SIZE,
		rl.BLUE,
	)
	for y in 0 ..< WORLD_HEIGHT {
		for x in 0 ..< WORLD_WIDTH {
			if (!g_Game_State.worldGrid[x][y].isVisible) {
				continue
			}
			rl.DrawTextureV(
				tileTexture,
				{
					f32(x) * TILE_SIZE - f32(camera.offset.x / camera.zoom),
					f32(y) * TILE_SIZE - f32(camera.offset.y / camera.zoom),
				},
				rl.WHITE,
			)


		}
	}
}

// for &tile in g_Game_State.worldGrid {
// 	fmt.println(tile)
// 	// for y in 0 ..< WORLD_GRID.y {
// 	tile := get_tile(0, 0)
// 	if (!tile.isVisible) {
// 		continue
// 	}
// 	rl.DrawRectangleRec(
// 		rl.Rectangle {
// 			f32(0) * TILE_SIZE * 2,
// 			f32(0) * TILE_SIZE * 2,
// 			8 * TILE_SIZE * 2,
// 			8 * TILE_SIZE * 2,
// 		},
// 		rl.RED,
// 	)
// 	// }
// }
