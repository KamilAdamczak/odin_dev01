package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:slice"
import rl "vendor:raylib"

Player :: struct {
	using ent: Entety,
}

Enemy :: struct {
	using ent: Entety,
}

Game_State :: struct {
	initialized:    bool,
	playerPos:      Vec2i,
	worldGrid:      [WORLD_GRID.x][WORLD_GRID.y]Tile,
	camera:         rl.Camera2D,
	player:         Player,
	enemy:          [dynamic]Entety,
	enemySpawnTime: f64,
	assets:         map[string]rl.Texture,
}

g_Game_State := Game_State {
	initialized = false,
	camera = rl.Camera2D{offset = {1280 / 2, 720 / 2}, zoom = 2},
	enemySpawnTime = .1,
}

spawnCount := 1

camera := &g_Game_State.camera

init :: proc() {
	sFPS.show = true
	rl.InitWindow(1280, 720, "vampire")

	//WINDOW ICON
	icon: rl.Image
	icon = rl.LoadImage("./assets/ico.png")
	rl.SetWindowIcon(icon)

	//LOAD ASSETS	
	g_Game_State.assets = {
		"player" = rl.LoadTexture("./assets/tile_texture.png"),
		"enemy"  = rl.LoadTexture("./assets/tile_texture.png"),
	}
	//PLAYER
	g_Game_State.player.ent = Entety {
		pos    = {1280 / 2, 720 / 2},
		speed  = 2,
		health = 100,
		color  = rl.WHITE,
	}

	g_Game_State.player.texture = g_Game_State.assets["player"]
	//CAMERA
	camera.target = g_Game_State.player.pos
	//INIT TIMERS
	TIMERS["one"] = 0.0
}


update :: proc() {
	TimerRun(&TIMERS["one"], g_Game_State.enemySpawnTime, rl.GetTime(), spawnEnemy)
	//PLAYER
	playerMove()

	//ENEMY
	for &ent in g_Game_State.enemy {
		ent.direction = calcDirection(ent.pos, g_Game_State.player.pos)
		EntetyMove(&ent)
	}
}

draw :: proc() {

	entetySort := EntetySort({g_Game_State.player}, [dynamic][dynamic]Entety{g_Game_State.enemy})
	for ent in entetySort {
		EntetyDraw(ent, ent.color)
	}
	delete(entetySort)
}
/*
		ENEMY FUNCTIONS
		TODO: Move to other file
*/

drawGui :: proc() {
	rl.DrawText(rl.TextFormat("%f", rl.GetFrameTime()), i32(10), i32(120), 20, rl.WHITE)
	rl.DrawText(
		rl.TextFormat(
			"Next Spawn: %f",
			TIMERS["one"] + g_Game_State.enemySpawnTime - rl.GetTime(),
		),
		i32(10),
		i32(170),
		30,
		rl.WHITE,
	)
	rl.DrawText(rl.TextFormat("Enteties: %i", spawnCount), i32(10), i32(200), 30, rl.WHITE)
}
spawnEnemy :: proc() {
	enemy := Enemy {
		ent = Entety {
			pos = g_Game_State.player.pos +
			{f32(rl.GetRandomValue(-3, 3) * 20), f32(rl.GetRandomValue(-3, 3) * 20)},
			texture = g_Game_State.assets["enemy"],
			health = 20,
			speed = f32(rl.GetRandomValue(1, 5)) / 10,
			color = rl.Color {
				cast(u8)rl.GetRandomValue(0, 255),
				cast(u8)rl.GetRandomValue(0, 255),
				cast(u8)rl.GetRandomValue(0, 255),
				255,
			},
		},
	}
	append(&g_Game_State.enemy, enemy)
	spawnCount += 1
}


/*
		PLAYER FUNCTIONS - move to other file?
		TODO: Move to other file
*/
playerMove :: proc() {
	if rl.IsKeyDown(.A) {
		g_Game_State.player.direction.x = -1
	}
	if rl.IsKeyDown(.D) {
		g_Game_State.player.direction.x = 1
	}
	if rl.IsKeyDown(.W) {
		g_Game_State.player.direction.y = -1
	}
	if rl.IsKeyDown(.S) {
		g_Game_State.player.direction.y = 1
	}

	if rl.IsKeyReleased(.A) || rl.IsKeyReleased(.D) {
		g_Game_State.player.direction.x = 0
	}

	if rl.IsKeyReleased(.W) || rl.IsKeyReleased(.S) {
		g_Game_State.player.direction.y = 0
	}
	if g_Game_State.player.direction != {0, 0} {
		EntetyMove(&g_Game_State.player)
	}
}
