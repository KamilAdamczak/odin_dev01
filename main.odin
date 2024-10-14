package main

import rl "vendor:raylib"

sFPS: bool = false

main :: proc() {
	init()

	for !rl.WindowShouldClose() {
		TICK_TIMER -= rl.GetFrameTime()
		rl.BeginDrawing()
		rl.ClearBackground(rl.Color(BACKGROUND_COLOR))
		rl.BeginMode2D(camera)

		if TICK_TIMER <= 0 {

			update()

			TICK_TIMER = TICK_RATE + TICK_TIMER

		}
		draw()

		rl.EndMode2D()
		if sFPS {
			rl.DrawText(rl.TextFormat("%i", rl.GetFPS()), 100, 100, 100, rl.WHITE)
		}
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
