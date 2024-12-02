package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:slice"
import rl "vendor:raylib"

MENU_Game_State :: struct {
	// worldGrid          : [WORLD_GRID.x][WORLD_GRID.y]Tile,
	camera             : rl.Camera2D,
	// player             : Player,
	// enemy              : [dynamic]Enemy,
	// enemySpawnTime     : f64,
	// projectiles        : [dynamic]Projectile,
	assets             : map[string]rl.Texture2D,
	// particleEmitters   : [dynamic]ParticleEmitter,
	whiteSquareTexture : Sprite,
	// current_level      : int,
	// level_state        : LEVEL_STATE,
	// killed_mobs        : int,
	// spawnedEnemies     : int,
	// remaning_time      : int,
	// souls_drops        : [dynamic]Soul,
	// collected_souls    : int,
	// deathReaper        : Enemy,
	start : bool,
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
	sFPS.show = true

	//LOAD ASSETS	
	MENU_g_Game_State.assets = {
		"atlas" = rl.LoadTexture("./assets/atlas.png"),
	}

	MENU_g_Game_State.whiteSquareTexture = createSprite(MENU_g_Game_State.assets["atlas"], {1,2})
	
	{ //WINDOW ICON
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
	if rl.IsKeyDown(.ENTER) || MENU_g_Game_State.start{
		changeScreen(CURRENT_SCREEN, .GAME)
	}
}

/* ///////////////////////////////////////////////////////////////////////////////////////////
										DRAW
////////////////////////////////////////////////////////////////////////////////////////// */
menu_screen_draw :: proc() {
	
}

menu_screen_drawGui :: proc() {
	MENU_g_Game_State.start = rl.GuiButton(rl.Rectangle{100,100,120,50},"START")
}


