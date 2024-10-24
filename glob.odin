package main

import "core:math"
import "core:slice"

//GLOBALS VALUES
WORLD_WIDTH :: 1
WORLD_HEIGHT :: 1
TILE_SIZE :: 8
WORLD_GRID: Vec2i : {WORLD_WIDTH * TILE_SIZE, WORLD_HEIGHT * TILE_SIZE}
TICK_RATE :: 1 / 60
LATE_TICK_RATE :: 1
TICK_TIMER: f32 = TICK_RATE
LATE_TICK_TIMER: f32 = LATE_TICK_RATE
BACKGROUND_COLOR :: [4]u8{75, 42, 25, 0}
//GLOBAL TYPES
Vec2i :: [2]int
Vec2f :: [2]f32

Tile :: struct {
	neighbourMask: int,
	isVisible:     bool,
}

TIMERS := map[string]f64 {
	"one" = 0.0,
}

//UTILITY PROC


calcDirection :: proc(pointA: Vec2f, pointB: Vec2f) -> Vec2f {
	delta_x := pointB.x - pointA.x
	delta_y := pointB.y - pointA.y

	length := math.sqrt(delta_x * delta_x + delta_y * delta_y)
	if length == 0 {
		return {0, 0}
	}

	direction_x := delta_x / length
	direction_y := delta_y / length
	return {direction_x, direction_y}
}

getIndex :: proc(array: [dynamic]Entety, object: Enemy) -> int {
	for index in 00 ..< len(array) {
		if array[index] == object {
			return index
		}
	}
	return 0
}

TimerRun :: proc(timer: ^f64, timeToWait: f64, currentTime: f64, callProcedure: proc()) {
	if (timer^ + timeToWait < currentTime) {
		callProcedure()
		timer^ = currentTime
	}
}

ScreenToWorld :: proc(screen_pos: Vec2f) -> Vec2i {
	xPos := f32(screen_pos.x) / TILE_SIZE / g_Game_State.camera.zoom
	yPos := f32(screen_pos.y) / TILE_SIZE / g_Game_State.camera.zoom
	return {int(xPos), int(yPos)}
}

getTile :: proc {
	getTileVec2i,
	getTileXY,
}

getTileXY :: proc(x: int, y: int) -> ^Tile {
	tile: ^Tile = nil

	if x >= 0 && x <= WORLD_GRID.x && y >= 0 && y <= WORLD_GRID.y {
		tile = &g_Game_State.worldGrid[x][y]
	}

	return tile
}
getTileVec2i :: proc(worldPos: Vec2i) -> ^Tile {
	x := worldPos.x
	y := worldPos.y

	return getTile(x, y)
}
