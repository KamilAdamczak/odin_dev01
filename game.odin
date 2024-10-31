package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:slice"
import rl "vendor:raylib"

Player :: struct {
	using ent : EntityAtlas,
	attackSpeed : f64,
}

Enemy :: struct {
	using ent: EntityAtlas,
}

Projectile :: struct {
	using ent: EntityAtlas,
	dmg : int,
}

Game_State :: struct {
	worldGrid:      [WORLD_GRID.x][WORLD_GRID.y]Tile,
	
	camera:         rl.Camera2D,
	
	player:         Player,
	
	enemy:          [dynamic]EntityAtlas,	
	enemySpawnTime: f64,

	projectiles:	[dynamic]EntityAtlas,
	
	assets:         map[string]rl.Texture2D,
}

g_Game_State := Game_State {
	camera = rl.Camera2D{offset = {1280 / 2, 720 / 2}, zoom = 2},
	enemySpawnTime = .1,
}
camera := &g_Game_State.camera

spawnCount := 1

init :: proc() {
	sFPS.show = true
	rl.InitWindow(1280, 720, "vampire")
	DRAW_COLLIDERS = true
	//LOAD ASSETS	
	g_Game_State.assets = {
		"atlas"  = rl.LoadTexture("./assets/atlas.png")
	}

	//WINDOW ICON
	icon: rl.Image
	icon = rl.LoadImageFromTexture(g_Game_State.assets["atlas"])
	icon = rl.ImageFromImage(icon, {0.0,32.0,16.0,16.0})
	rl.SetWindowIcon(icon)

	//PLAYER
	g_Game_State.player.ent = EntityAtlas {
		pos    = {1280 / 2, 720 / 2},
		speed  = 2,
		health = 100,
		color  = rl.WHITE,
	}
	g_Game_State.player.attackSpeed = .1
	g_Game_State.player.texture = Sprite {texture = g_Game_State.assets["atlas"], atlas_pos = {0,2}, texture_scale = {16,16},}
	g_Game_State.player.collider = SetCollider(.OVAL, Vec2f{6,0}) 
	//CAMERA
	camera.target = g_Game_State.player.pos
	//INIT TIMERS
	TIMERS["one"] = 0.0
	TIMERS["two"] = 0.0
}


update :: proc() {
	TimerRun(&TIMERS["one"], g_Game_State.enemySpawnTime, rl.GetTime(), spawnEnemy)
	//PLAYER
	playerMove()

	//Projectiles
	MoveProjectiles()
	if rl.IsMouseButtonDown(.LEFT) {
		TimerRun(&TIMERS["two"], 
		g_Game_State.player.attackSpeed, 
		rl.GetTime(), 
		proc() {
			spawProjectile(
				g_Game_State.player.ent.pos,
				calcDirection(
					g_Game_State.player.pos, 
					ScreenToWorld(rl.GetMousePosition()))
				)
			})
	}

	//ENEMY
	for &ent, index in g_Game_State.enemy {
		ent.direction = calcDirection(ent.pos, g_Game_State.player.pos)
		collision := false
		for entB in g_Game_State.enemy {
			if ent == entB || collision {
				continue
			}
			newPosEntA := EntityFutureMove(ent)
			if checkCollision(newPosEntA, entB) {
				collision = true
			}
		}
		if !collision {
			EntityMove(&ent)
		}
		
	}
}

draw :: proc() {
	EntitySort := EntitySort({g_Game_State.player}, [dynamic][dynamic]EntityAtlas{g_Game_State.enemy, g_Game_State.projectiles})
	
	for ent in EntitySort {
		shadow := ent
		shadow.pos.x -= 2
		shadow.pos.y -= 3
		EntityDraw(shadow, rl.Color {0,0,0,80})
	}

	for ent in EntitySort {
		EntityDraw(ent, ent.color)
	}
	delete(EntitySort)
}



/*
		PROJECTILES FUNCTIONS
		TODO: Move to other file

*/

spawProjectile :: proc(position : Vec2f, direction : Vec2f) {
	projectile := Projectile {
		ent = EntityAtlas {
			pos = g_Game_State.player.pos,
			texture = Sprite {texture = g_Game_State.assets["atlas"], atlas_pos = {0,1}, texture_scale = {16,16},},
			health = 1,
			speed = 4,
			color = rl.WHITE,
			direction = direction,
		},
		dmg = 4
	}
	projectile.collider = SetCollider(.OVAL, Vec2f{4.0, 0.0})
	append(&g_Game_State.projectiles, projectile)
}

MoveProjectiles :: proc() {
	for &projectile in g_Game_State.projectiles {
		EntityMove(&projectile)
	}
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
	rl.DrawText(rl.TextFormat("Entities: %i", spawnCount), i32(10), i32(200), 30, rl.WHITE)
}
spawnEnemy :: proc() {
	enemy := Enemy {
		ent = EntityAtlas {
			pos = g_Game_State.player.pos +
			{f32(rl.GetRandomValue(-3, 3) * 20), f32(rl.GetRandomValue(-3, 3) * 20)},
			texture = Sprite {texture = g_Game_State.assets["atlas"], atlas_pos = {int(rl.GetRandomValue(0,2)),0}, texture_scale = {16,16},},
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
	enemy.collider = SetCollider(.OVAL, Vec2f{6,0}) 
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
		EntityMove(&g_Game_State.player)
	}
}
