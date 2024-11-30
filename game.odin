package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:slice"
import rl "vendor:raylib"

Game_State :: struct {
	worldGrid          : [WORLD_GRID.x][WORLD_GRID.y]Tile,
	camera             : rl.Camera2D,
	player             : Player,
	enemy              : [dynamic]Enemy,
	enemySpawnTime     : f64,
	projectiles        : [dynamic]Projectile,
	assets             : map[string]rl.Texture2D,
	particleEmitters   : [dynamic]ParticleEmitter,
	whiteSquareTexture : Sprite,
	current_level      : int,
	level_state        : LEVEL_STATE,
	killed_mobs        : int,
	spawnedEnemies     : int,
	remaning_time      : int,
	souls_drops        : [dynamic]Soul,
	collected_souls    : int,
}

LEVEL_STATE :: enum {
	INIT,
	GO,
	SHOPPING,
	END,
}

g_Game_State := Game_State {
	camera = rl.Camera2D{
		offset = {1280 / 2, 720 / 2}, 
		zoom = 2
	},
	enemySpawnTime = .5,
}


waves_time := map[int]int {
	1 = 120,
	2 = 50,
	3 = 80,
}

levelUpWindow : [2]guiWindow

Creditsy : string = "GAME MADE BY KAMIL ADAMCZAK, and Kikołaj via Discord"

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
	g_Game_State.current_level = 1
	g_Game_State.remaning_time = -1000
	
	{ //WINDOW ICON
		icon: rl.Image
		icon = rl.LoadImageFromTexture(g_Game_State.assets["atlas"])
		icon = rl.ImageFromImage(icon, {0.0, 32.0, 16.0, 16.0})
		rl.SetWindowIcon(icon)
	}

	
	{ //PLAYER
		g_Game_State.player.ent = Entity {
			pos    = {1280 / 2, 720 / 2},
			speed  = 2,
			health = 100,
			color  = rl.WHITE,
		}

		g_Game_State.player.attackSpeed = 2

		g_Game_State.player.texture = Sprite {
			texture       = g_Game_State.assets["atlas"],
			atlas_pos     = {0, 2},
			texture_scale = {16, 16},
		}

		g_Game_State.player.collider = SetCollider(.OVAL, Vec2f{10, 0})
		g_Game_State.player.dropCollider = SetCollider(.OVAL, Vec2f{45, 0})
		g_Game_State.player.state = .IDLE
		g_Game_State.player.maxHP = 10
		g_Game_State.player.currentHP = g_Game_State.player.maxHP
		TIMERS["player"] = 0.0
	}

	
	{ //CAMERA
		camera.target = g_Game_State.player.pos
	}
	
	{ //INIT TIMERS
	TIMERS["one"] = 0.0
	TIMERS["two"] = 0.0
	TIMERS["COUNTDOWN"] = 0.0
	}

	g_Game_State.level_state = .INIT

	levelUpWindow[0] = createGuiWindow(
		createSprite(
			g_Game_State.assets["atlas"],
			{0,3},
			{16,16}),
		{
			cast(f32)rl.GetScreenWidth()/2,
			cast(f32)rl.GetScreenHeight()/2-300
		},
		{
			cast(f32)rl.GetScreenWidth()*0.75,
			60
		},
		{cast(f32)rl.GetScreenWidth()*0.75/2, 60/2},
		{
			7,
			7,
			7,
			7
		},
		.NINE_PATCH
	)
	levelUpWindow[1] = createGuiWindow(
		createSprite(
			g_Game_State.assets["atlas"],
			{0,4},
			{32,32}),
		{
			cast(f32)rl.GetScreenWidth()/2,
			cast(f32)rl.GetScreenHeight()/2
		},
		{
			cast(f32)rl.GetScreenWidth()*0.75,
			cast(f32)rl.GetScreenHeight()*0.75
		},
		{cast(f32)rl.GetScreenWidth()*0.75/2, cast(f32)rl.GetScreenHeight()*0.75/2},
		{
			7,
			7,
			7,
			7
		},
		.NINE_PATCH
	)
	

}

/* ///////////////////////////////////////////////////////////////////////////////////////////
										UPDATE
////////////////////////////////////////////////////////////////////////////////////////// */
update :: proc() {
	
	switch g_Game_State.level_state {
		case .INIT:
			if len(g_Game_State.enemy) == 0 {
				g_Game_State.spawnedEnemies = 0
				g_Game_State.killed_mobs = 0
				g_Game_State.remaning_time = waves_time[g_Game_State.current_level]
				g_Game_State.level_state = .GO
			}
		case .GO:
			timerRun(&TIMERS["COUNTDOWN"], 1, rl.GetTime(), proc() {g_Game_State.remaning_time-=1})
			
			{//PLAYER
				playerUpdate()
			}

			{//ENEMY
				// if  g_Game_State.killed_mobs < waves_enemy_number[g_Game_State.current_level] && g_Game_State.spawnedEnemies < waves_enemy_number[g_Game_State.current_level] {
				// 	timerRun(&TIMERS["one"], g_Game_State.enemySpawnTime, rl.GetTime(), spawnEnemy)
				// }
				timerRun(&TIMERS["one"], g_Game_State.enemySpawnTime, rl.GetTime(), spawnEnemy)
				updateEnemy()
			}

			{//PARTICLE EMMITTERS
				for &emitter in g_Game_State.particleEmitters {
					ParticleEmitterUpdate(&emitter)
				}
			}
			{//Souls
				SoulsUpdate(..convert_to_pointers(..g_Game_State.souls_drops[:])[:])
			}

			{//Projectilesarray_of_object
				updateProjectiles(..convert_to_pointers(..g_Game_State.projectiles[:])[:])
				// fmt.println(slice.as_ptr(g_Game_State.projectiles[:])[:])
				if len(g_Game_State.enemy) > 0 && plater_attack {
					timerRun(&TIMERS["two"], g_Game_State.player.attackSpeed, rl.GetTime(), proc() {
						spawnProjectile(
							g_Game_State.player.ent.pos,
							calcDirection(
										g_Game_State.player.pos, 
										closesTarget(
														g_Game_State.player, 
														..getFromStruct(
																		..g_Game_State.enemy[:], 
																		fieldAccessor = proc(ent: ^Enemy) -> Entity {return ent.ent;}
																		)[:]
													).pos
							)
						)
					})
				}
			}

			{ //CAMERA
				camera.offset = {f32(rl.GetScreenWidth()/2), f32(rl.GetScreenHeight()/2)}
				camera.target = g_Game_State.player.pos
				camera.zoom += rl.GetMouseWheelMove()/10
				camera.zoom = rl.Clamp(g_Game_State.camera.zoom, 1,5)
			}

			if g_Game_State.remaning_time <= 0 {
				// g_Game_State.current_level += 1
				g_Game_State.level_state = .SHOPPING
			}

		case .SHOPPING:
			updateProjectiles(..convert_to_pointers(..g_Game_State.projectiles[:])[:])
		case .END:
	}



	{//GUI
		updateGuiWindow(&levelUpWindow[1])
	}

	{//DEBUG
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

		if rl.IsKeyPressed(.Y) {
			plater_attack = !plater_attack
		}
	}
}

/* ///////////////////////////////////////////////////////////////////////////////////////////
										DRAW
////////////////////////////////////////////////////////////////////////////////////////// */
draw :: proc() {
	
	entitySort := EntitySort(
		{g_Game_State.player},
		[dynamic][dynamic]Entity{
									getFromStruct(..g_Game_State.enemy[:], fieldAccessor = proc(ent: ^Enemy) -> Entity {return ent.ent;}) , 
									getFromStruct(..g_Game_State.projectiles[:], fieldAccessor = proc(ent: ^Projectile) -> Entity {return ent.ent;}),
									getFromStruct(..g_Game_State.souls_drops[:], fieldAccessor = proc(ent: ^Soul) -> Entity {return ent.ent;})
								},
	)
	//getFromStruct(..g_Game_State.projectiles[:], fieldAccessor = proc(p: ^Projectile) -> ParticleEmitter {return p.particleEmitter;})
	
	if DRAW_SHADOWS {
		LOOP_STATE = .DRAW_SHADOWS
		{
			shadows : [dynamic]Entity
			for ent in entitySort {
				shadow := ent
				shadow.pos.x -= 2
				shadow.pos.y -= 3
				shadow.color = rl.Fade(rl.BLACK, .5)
				append(&shadows, shadow)
			}
			EntityDraw(..shadows[:])
		}
	}
	LOOP_STATE = .DRAW_SPRITES

	if(rl.IsKeyDown(.L)) {
		fmt.println("Start")
		fmt.println("Start")
		fmt.println(getFromStruct(..g_Game_State.projectiles[:], fieldAccessor = proc(p: ^Projectile) -> ParticleEmitter {return p.particleEmitter;})[:])
		fmt.println("STOP")
		fmt.println("STOP")
	}
	ParticleEmitterDraw(..getFromStruct(..g_Game_State.projectiles[:], fieldAccessor = proc(p: ^Projectile) -> ParticleEmitter {return p.particleEmitter;})[:])
	ParticleEmitterDraw(..getFromStruct(..g_Game_State.souls_drops[:], fieldAccessor = proc(p: ^Soul) -> ParticleEmitter {return p.particleEmitter;})[:])
	EntityDraw(..entitySort[:])
	if DRAW_COLLIDERS {
		rl.DrawCircleLines(i32(g_Game_State.player.pos.x), i32(g_Game_State.player.pos.y), g_Game_State.player.dropCollider.size.x, rl.BLUE,)
	}
	
	
	ParticleEmitterDraw(..g_Game_State.particleEmitters[:])
	
	
	delete(entitySort)

	//Before everything else
	playerDrawHealth()
}

drawGui :: proc() {
	
	text := rl.TextFormat("WELCOME IN SHOP")
	if(g_Game_State.level_state == .SHOPPING) {
		drawGuiWindow(..levelUpWindow[:])
		rl.DrawTextPro(
			rl.GetFontDefault(),
			text,
			{levelUpWindow[0].origin.x, levelUpWindow[0].rec.y},
			{0,0},
			0.0,
			30,
			1.0,
			rl.WHITE
		)
		// rl.DrawText(text, cast(i32)levelUpWindow[0].rec.x, cast(i32)levelUpWindow[0].rec.y, 50, rl.WHITE)
	}

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
		
		rl.DrawText(rl.TextFormat("Level: %i, Monster To Kill: %i, Entities: %i, Killed mobs %i",g_Game_State.current_level, waves_time[g_Game_State.current_level],spawnCount, g_Game_State.killed_mobs), i32(10), i32(200), 30, rl.WHITE)
		rl.DrawText(rl.TextFormat("Player State: %i", g_Game_State.player.state), i32(10), i32(240), 30, rl.WHITE)
	}

	{//DisplayTimer
		timerStr := rl.TextFormat("%i", g_Game_State.remaning_time)
		timerFont := rl.GetFontDefault()
		timerFontSize : f32 = 40
		timerSpacing : f32 = 2
		timerposition : rl.Vector2 = {cast(f32)rl.GetScreenWidth()/2, 20}
		timerOrigin := setTextAlign(timerStr, timerFont, timerFontSize, timerSpacing, .CENTER)
		rl.DrawTextPro(timerFont,timerStr,timerposition ,timerOrigin,0.0,timerFontSize,timerSpacing,rl.WHITE)
	}

		{//DisplaySouls
			timerStr := rl.TextFormat("Collected Souls: %i", g_Game_State.collected_souls)
			timerFont := rl.GetFontDefault()
			timerFontSize : f32 = 20
			timerSpacing : f32 = 2
			timerposition : rl.Vector2 = {10, 60}
			timerOrigin := setTextAlign(timerStr, timerFont, timerFontSize, timerSpacing, .LEFT)
			rl.DrawTextPro(timerFont,timerStr,timerposition ,timerOrigin,0.0,timerFontSize,timerSpacing,rl.WHITE)
		}
}


