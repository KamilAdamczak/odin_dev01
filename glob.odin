package main

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
Vec2f :: [2]f64
Vec2f32 :: [2]f32

//UTILITY PROC
screen_to_world :: proc(screen_pos: Vec2f32) -> Vec2i {
	xPos := f32(screen_pos.x) / TILE_SIZE / g_Game_State.camera.zoom
	yPos := f32(screen_pos.y) / TILE_SIZE / g_Game_State.camera.zoom
	return {int(xPos), int(yPos)}
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
