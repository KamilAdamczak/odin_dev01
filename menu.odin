package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:slice"
import rl "vendor:raylib"

MENU_Game_State :: struct {
	camera             : rl.Camera2D,
	assets             : map[string]rl.Texture2D,
	whiteSquareTexture : Sprite,
	start : bool,
	menuItems : [dynamic]MenuItem,
}

MenuItem :: struct {
	name : cstring,
	boolean : bool,
	screen : GAME_SCREEN
}


MENU_g_Game_State : MENU_Game_State
MENU_camera := &MENU_g_Game_State.camera

menu_screen_init :: proc() {
	MENU_g_Game_State = MENU_Game_State {
		camera = rl.Camera2D{
			offset = {1280 / 2, 720 / 2}, 
			zoom = 2
		},
		start = false
	}
	sFPS.show = false

	append(&MENU_g_Game_State.menuItems,
		MenuItem{"Start", false, .GAME},
		// MenuItem{"Options", false, .GAME},
		MenuItem{"Exit", false, .EXIT})

	//LOAD ASSETS	
	MENU_g_Game_State.assets = {
		"atlas" = rl.LoadTexture("./assets/atlas.png"),
	}

	MENU_g_Game_State.whiteSquareTexture = createSprite(MENU_g_Game_State.assets["atlas"], {1,2})
	
	{ //WINDOW ICON TODO: Create .ico file and move this to main with load
		icon: rl.Image
		icon = rl.LoadImageFromTexture(MENU_g_Game_State.assets["atlas"])
		icon = rl.ImageFromImage(icon, {0.0, 32.0, 16.0, 16.0})
		rl.SetWindowIcon(icon)
    }

}

/* ///////////////////////////////////////////////////////////////////////////////////////////
										UPDATE
////////////////////////////////////////////////////////////////////////////////////////// */
menu_screen_update :: proc() {
	for &item, i in MENU_g_Game_State.menuItems {
		if item.boolean {
			changeScreen(CURRENT_SCREEN, item.screen)
		}
	}
}

/* ///////////////////////////////////////////////////////////////////////////////////////////
										DRAW
////////////////////////////////////////////////////////////////////////////////////////// */
menu_screen_draw :: proc() {
	
}
menu_screen_drawGui :: proc() {
	{
		menuposition := rl.Rectangle{cast(f32)rl.GetScreenWidth()/2-110,150,220,100}
		for &item, i in MENU_g_Game_State.menuItems {
			menuposition := rl.Rectangle{cast(f32)rl.GetScreenWidth()/2-110,200+110*f32(i),220,100}
			item.boolean = rl.GuiButton(menuposition,item.name)
		}
	}
}


