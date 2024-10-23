package main

import "core:fmt"
import "core:math/rand"
import "core:math"
import "core:slice"
import rl "vendor:raylib"

Player :: struct {
	using ent: Entety,
}

Enemy :: struct {
	using ent: Entety,
	color : rl.Color,
}

Game_State :: struct {
	initialized: bool,
	playerPos:   Vec2i,
	worldGrid:   [WORLD_GRID.x][WORLD_GRID.y]Tile,
	camera:      rl.Camera2D,
	player: Player,
	enemy : [dynamic] Enemy,
	enemySpawnTime : f64,
	assets : map[string]rl.Texture,
}

g_Game_State := Game_State {
	initialized = false,
	camera = rl.Camera2D{offset = {1280/2, 720/2}, zoom = 2},
	enemySpawnTime = 5,
}

camera := &g_Game_State.camera

init :: proc() {
	sFPS.show = true
	rl.InitWindow(1280, 720, "vampire")

	//WINDOW ICON
	icon: rl.Image
	icon = rl.LoadImage("./assets/ico.png")
	rl.SetWindowIcon(icon)
	
	//LOAD ASSETS	
	g_Game_State.assets = {"player" = rl.LoadTexture("./assets/tile_texture.png"), "enemy" = rl.LoadTexture("./assets/tile_texture.png")}
	//PLAYER
	g_Game_State.player.ent = Entety{ pos = {1280/2, 720/2}, speed = 2, health = 100} 
	g_Game_State.player.texture = g_Game_State.assets["player"]
	//CAMERA
	camera.target = g_Game_State.player.pos
	//INIT TIMERS
	TIMERS["one"] = 0.0
}


update :: proc() {
	TimerRun(&TIMERS["one"],g_Game_State.enemySpawnTime,rl.GetTime(),spawnEnemy)
	//PLAYER
	playerMove()

	//ENEMY
	for &ent in g_Game_State.enemy {
		ent.direction = calcDirection(ent.pos, g_Game_State.player.pos)
		EntetyMove(&ent)
	}
}

draw :: proc() {
	{
		EntetyDraw(g_Game_State.player)
	}

	
		for ent in g_Game_State.enemy {
			EntetyDraw(ent, ent.color)
		}
	

}
		/*
		ENEMY FUNCTIONS
		TODO: Move to other file
*/
spawnEnemy :: proc() {
	enemy := Enemy {
		ent = Entety {
			pos = g_Game_State.player.pos + {f32(rl.GetRandomValue(-3,3)*20), f32(rl.GetRandomValue(-3,3)*20)},
			texture = g_Game_State.assets["enemy"],
			health = 20, 
			speed = .4,
		},
		color = rl.Color {cast(u8)rl.GetRandomValue(0,255),cast(u8)rl.GetRandomValue(0,255), cast(u8)rl.GetRandomValue(0,255), 255}
	}
	append(&g_Game_State.enemy, enemy)
}

calcDirection :: proc(pointA : Vec2f, pointB : Vec2f) -> Vec2f {
	delta_x := pointB.x - pointA.x 
	delta_y := pointB.y - pointA.y

	length := math.sqrt(delta_x*delta_x + delta_y*delta_y)
	if length == 0 {
		return {0,0} 
	}

	direction_x := delta_x/length
	direction_y := delta_y/length
	return {direction_x, direction_y}
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