package main

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


main :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	init()
	for !rl.WindowShouldClose() {
		TICK_TIMER -= rl.GetFrameTime()
		LATE_TICK_TIMER -= rl.GetFrameTime()
		rl.BeginDrawing()
		rl.ClearBackground(rl.Color(BACKGROUND_COLOR))
		rl.BeginMode2D(camera)

		if TICK_TIMER <= 0 {

			update()

			TICK_TIMER = TICK_RATE + TICK_TIMER

		}

		if LATE_TICK_TIMER <= 0 {
			late_update()

			LATE_TICK_TIMER = LATE_TICK_RATE + LATE_TICK_TIMER
		}

		draw()

		rl.EndMode2D()
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
	}

	rl.CloseWindow()
}
