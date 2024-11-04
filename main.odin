package main

import "core:fmt"
import rl "vendor:raylib"

SFPS :: struct {
	show:  bool,
	pos:   Vec2i,
	size:  i32,
	color: rl.Color,
}

sFPS := SFPS {
	show  = false,
	pos   = {10, 10},
	size  = 69,
	color = rl.WHITE,
}

DRAW_COLLIDERS := false
LOOP_STATE: LOOP_STATE_VALUES = .INIT
main :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	init()
	for !rl.WindowShouldClose() {
		TICK_TIMER -= rl.GetFrameTime() //get delta time
		LATE_TICK_TIMER -= rl.GetFrameTime()
		rl.BeginDrawing()
		rl.ClearBackground(rl.Color(BACKGROUND_COLOR))
		rl.BeginMode2D(camera^)

		if TICK_TIMER <= 0 {
			LOOP_STATE = .UPDATE
			update()
			draw()
			TICK_TIMER = TICK_RATE + TICK_TIMER
		}

		rl.EndMode2D()
		LOOP_STATE = .DRAW_GUI
		drawGui()
		if sFPS.show {
			rl.DrawText(
				rl.TextFormat("%i", rl.GetFPS()),
				i32(sFPS.pos.x),
				i32(sFPS.pos.y),
				sFPS.size,
				sFPS.color,
			)
		}
		rl.EndDrawing()
		free_all(context.temp_allocator)
	}

	/*high risk! maybe move to main game loop 
			TODO: DO SOMETHING WITH THIS SHIT!
	*/
	for asset in g_Game_State.assets {
		rl.UnloadTexture(g_Game_State.assets[asset])
	}

	rl.CloseWindow()
}
