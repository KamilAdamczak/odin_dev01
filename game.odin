package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:slice"
import rl "vendor:raylib"

Game_State :: struct {
	worldGrid:      [WORLD_GRID.x][WORLD_GRID.y]Tile,
	camera:         rl.Camera2D,
	player:        	Player,
	enemy:          [dynamic]Enemy,
	enemySpawnTime: f64,
	projectiles:    [dynamic]Projectile,
	assets:         map[string]rl.Texture2D,
	particleEmmiters : [dynamic]ParticleEmitter,
	whiteSquareTexture : Sprite
}

g_Game_State := Game_State {
	camera = rl.Camera2D{offset = {1280 / 2, 720 / 2}, zoom = 2},
	enemySpawnTime = 1,
}

camera := &g_Game_State.camera

spawnCount := 1
DRAW_SHADOWS := true
plater_attack := true

init :: proc() {
	sFPS.show = true
	rl.InitWindow(1280, 720, "vampire")
	//LOAD ASSETS	
	g_Game_State.assets = {
		"atlas" = rl.LoadTexture("./assets/atlas.png"),
	}
	
	g_Game_State.whiteSquareTexture = createSprite(g_Game_State.assets["atlas"], {1,2})

	//WINDOW ICON
	icon: rl.Image
	icon = rl.LoadImageFromTexture(g_Game_State.assets["atlas"])
	icon = rl.ImageFromImage(icon, {0.0, 32.0, 16.0, 16.0})
	rl.SetWindowIcon(icon)

	//PLAYER
	g_Game_State.player.ent = EntityAtlas {
		pos    = {1280 / 2, 720 / 2},
		speed  = 2,
		health = 100,
		color  = rl.WHITE,
	}

	g_Game_State.player.attackSpeed = 1.5

	g_Game_State.player.texture = Sprite {
		texture       = g_Game_State.assets["atlas"],
		atlas_pos     = {0, 2},
		texture_scale = {16, 16},
	}

	g_Game_State.player.collider = SetCollider(.OVAL, Vec2f{10, 0})
	g_Game_State.player.state = .IDLE
	g_Game_State.player.maxHP = 10
	g_Game_State.player.currentHP = g_Game_State.player.maxHP
	TIMERS["player"] = 0.0
	//CAMERA
	camera.target = g_Game_State.player.pos

	//INIT TIMERS
	TIMERS["one"] = 0.0
	TIMERS["two"] = 0.0

	// spawnEnemy()
}

update :: proc() {
	timerRun(&TIMERS["one"], g_Game_State.enemySpawnTime, rl.GetTime(), spawnEnemy)

	//PLAYER
	playerUpdate()
	
	//Projectiles
	updateProjectiles()
	if len(g_Game_State.enemy) > 0 && plater_attack {
		timerRun(&TIMERS["two"], g_Game_State.player.attackSpeed, rl.GetTime(),proc() {
			closesEnemy := g_Game_State.enemy[0]
			for ent in g_Game_State.enemy {
				new_cc := math.sqrt(
					(abs(ent.pos.x - g_Game_State.player.pos.x) *
						abs(ent.pos.x - g_Game_State.player.pos.x)) +
					(abs(ent.pos.y - g_Game_State.player.pos.y) *
							abs(ent.pos.y - g_Game_State.player.pos.y)),
				)
				old_cc := math.sqrt(
					(abs(closesEnemy.pos.x - g_Game_State.player.pos.x) *
						abs(closesEnemy.pos.x - g_Game_State.player.pos.x)) +
					(abs(closesEnemy.pos.y - g_Game_State.player.pos.y) *
							abs(closesEnemy.pos.y - g_Game_State.player.pos.y)),
				)
				if new_cc < old_cc {
					closesEnemy = ent
				}
			}
			spawProjectile(
				g_Game_State.player.ent.pos,
				calcDirection(g_Game_State.player.pos, closesEnemy.pos),
			)
		})
	}

	//ENEMY
	updateEnemy()

	//DEBUG
	if rl.IsKeyPressed(.SPACE) {
		DRAW_COLLIDERS = !DRAW_COLLIDERS
	}

	if rl.IsKeyPressed(.R) {
		fmt.println(
			"enemies count: ",
			len(g_Game_State.enemy),
			"projectiles count:	",
			len(g_Game_State.projectiles),
		)
	}

	if rl.IsKeyPressed(.T) {
		DRAW_SHADOWS = !DRAW_SHADOWS
	}

	for &emitter in g_Game_State.particleEmmiters {
		ParticleEmitterUpdate(&emitter)
	}

	if rl.IsKeyPressed(.Y) {
		plater_attack = !plater_attack
	}

	camera.offset = {f32(rl.GetScreenWidth()/2), f32(rl.GetScreenHeight()/2)}
	camera.target = g_Game_State.player.pos
}

childToParent::proc(child : $T) -> (parent : [dynamic]EntityAtlas) {
	for ent in child {
		append(&parent, ent.ent)
	}
	return parent
}

draw :: proc() {
	entitySort := EntitySort(
		{g_Game_State.player},
		[dynamic][dynamic]EntityAtlas{childToParent(g_Game_State.enemy) , childToParent(g_Game_State.projectiles)},
	)

	if DRAW_SHADOWS {
		LOOP_STATE = .DRAW_SHADOWS
		for ent in entitySort {
			shadow := ent
			shadow.pos.x -= 2
			shadow.pos.y -= 3
			EntityDraw(shadow, rl.Color{0, 0, 0, 80})
		}
	}

	LOOP_STATE = .DRAW_SPRITES

	for ent in entitySort {
		EntityDraw(ent, ent.color)
	}
	for emitter in g_Game_State.particleEmmiters {
		ParticleEmitterDraw(emitter)
	}
	delete(entitySort)

	//Before everything else
	playerDrawHealth()
}

drawGui :: proc() {
	if rl.IsKeyDown(.TAB) {
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
		rl.DrawText(rl.TextFormat("Player State: %i", g_Game_State.player.state), i32(10), i32(240), 30, rl.WHITE)
	}
}
