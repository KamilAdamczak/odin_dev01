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

GAME_SCREEN :: enum {
	MENU,
	GAME,
	DEATH,
	EXIT,
}

CURRENT_SCREEN : GAME_SCREEN = .MENU
changeScreenBool : bool = false

DRAW_COLLIDERS := false
LOOP_STATE: LOOP_STATE_VALUES = .INIT
main :: proc() {
	
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(1280, 720, "vampire")
	// rl.SetTargetFPS(140)
	for !rl.WindowShouldClose() {
		switch CURRENT_SCREEN  {
			case .MENU:
				menu_screen()
			case .GAME:
				game_screen()
			case .DEATH:
			case .EXIT: 
				rl.CloseWindow()
		}
	}

}

menu_screen :: proc() {
	changeScreenBool = false
	menu_screen_init()

	for !changeScreenBool {
		TICK_TIMER -= rl.GetFrameTime() //get delta time
		LATE_TICK_TIMER -= rl.GetFrameTime()
		if TICK_TIMER <= 0 {
			LOOP_STATE = .UPDATE
			menu_screen_update()
			TICK_TIMER = (TICK_RATE + TICK_TIMER) 
		}
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		rl.BeginMode2D(camera^)
		menu_screen_draw()
		rl.EndMode2D()
		LOOP_STATE = .DRAW_GUI
		menu_screen_drawGui()
		if sFPS.show {
			rl.DrawFPS(i32(sFPS.pos.x),i32(sFPS.pos.y))
			// fmt.print(rl.GetFPS())
		}
		rl.EndDrawing()
		free_all(context.temp_allocator)
		if rl.WindowShouldClose() { changeScreen(CURRENT_SCREEN, .EXIT) }
	}

	/*high risk! maybe move to main game loop 
			TODO: DO SOMETHING WITH THIS SHIT!
	*/
	for asset in g_Game_State.assets {
		rl.UnloadTexture(g_Game_State.assets[asset])
	}
}

game_screen :: proc() {
	changeScreenBool = false
	
	game_screen_init()
	for !changeScreenBool {
		TICK_TIMER -= rl.GetFrameTime() //get delta time
		LATE_TICK_TIMER -= rl.GetFrameTime()
		if TICK_TIMER <= 0 {
			LOOP_STATE = .UPDATE
			game_screen_update()
			TICK_TIMER = (TICK_RATE + TICK_TIMER) 
		}
		rl.BeginDrawing()
		rl.ClearBackground(rl.Color(BACKGROUND_COLOR))
		rl.BeginMode2D(camera^)
		game_screen_draw()
		rl.EndMode2D()
		LOOP_STATE = .DRAW_GUI
		game_screen_drawGui()
		if sFPS.show {
			rl.DrawFPS(i32(sFPS.pos.x),i32(sFPS.pos.y))
			// fmt.print(rl.GetFPS())
		}
		rl.EndDrawing()
		free_all(context.temp_allocator)
		if rl.WindowShouldClose() { changeScreen(CURRENT_SCREEN, .EXIT) }
	}
	fmt.println("asd")
	/*high risk! maybe move to main game loop 
			TODO: DO SOMETHING WITH THIS SHIT!
	*/
	for asset in g_Game_State.assets {
		rl.UnloadTexture(g_Game_State.assets[asset])
	}

	
}

death_screen :: proc() {
	changeScreenBool = false
	for !changeScreenBool {
		if rl.WindowShouldClose() { changeScreen(CURRENT_SCREEN, .EXIT) }
	}

}

changeScreen :: proc (currScreen : GAME_SCREEN, nextScreen : GAME_SCREEN) -> (ok:bool) {
	if currScreen == nextScreen {
		fmt.println("resettting")

	}
	CURRENT_SCREEN = nextScreen
	changeScreenBool = true
	return true

}

print :: proc(text : string) {
	fmt.println(text)
}