package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"
import "core:strings"

Enemy :: struct {
	using ent: Entity,
	projectiles : [dynamic]Projectile,
	state : enemyState,
	currentDir : int,
	attackSpeed : f64,
}

enemyState :: enum {
	IDLE,
	MOVE,
	ATTACK,
}
enemyAnimation :: struct {
	valA : [dynamic]int,
	valB : [dynamic]f32,
	valC : [dynamic]f32,
}

enemyAnimations := map[string]enemyAnimation {
	"RUN" = {{1}, {20,-20},{}},
	"ATTACK" = {{1},{5},{}}
}

updateEnemy :: proc() {
	for &ent, index in g_Game_State.enemy {
		if ent.health <= 0 {
			delete_key(&TIMERS, ent.id)
			delete_key(&TIMERS, combine(ent.id,"ATTACK"))
			append(&g_Game_State.souls_drops, createSoul(ent.pos))
			unordered_remove(&g_Game_State.enemy, index)
			spawnCount -= 1
			g_Game_State.killed_mobs += 1
			continue
		}

		for &projectile in g_Game_State.projectiles {
			if checkCollision(ent, projectile) {
				if(!hasID(ent.projectiles,projectile)) {
					projectile.health -= 1
					ent.health -= projectile.dmg
					// projectile.direction = calcDirection(projectile.pos, rand.choice(g_Game_State.enemy[:]).pos) 
					append(
						&g_Game_State.particleEmitters, 
						createParticleEmitter(
							ent.pos,
							{-1, -1},
							1,
							Sprite{
								texture = g_Game_State.assets["atlas"],
								atlas_pos = {1, 1},
								texture_scale = {16, 16},
							},
							4,
							.EXPLOSION,
							ent.color))
					append(&ent.projectiles, projectile)
				}
			}
		}

		ent.direction = calcDirection(ent.pos, g_Game_State.player.pos)
		collision := false
		for entB in g_Game_State.enemy {
			if ent.ent == entB.ent ||
			   collision ||
			   abs(ent.pos.x - entB.pos.x) > 20 ||
			   abs(ent.pos.y - entB.pos.y) > 20 {

				continue
			}
			newPosEntA := EntityFutureMove(ent)
			if checkCollision(newPosEntA, entB) {
				if abs(ent.pos.x - entB.pos.x) < ent.collider.size.x ||
				   abs(ent.pos.y - entB.pos.y) < ent.collider.size.x {
					ent.direction = -(calcDirection(ent.pos, entB.pos) + {0.5, 0.5})
					collision = false
				} else {
					collision = true
				}
			}
		}
		if checkCollision(ent, g_Game_State.player) {
			collision = true
			
			ent.state = .ATTACK
			
		}
		if !collision {
			EntityMove(&ent)
			ent.state = .MOVE
		} else {
			if ent.state != .ATTACK {
				ent.state = .IDLE
			}
		}
	
		switch ent.state {
			case .IDLE:
				ent.rotation = 0
				TIMERS[combine(ent.id,"ATTACK")] = 0.0
			case .ATTACK:
				timerRun(&TIMERS[ent.id], .01, rl.GetTime(),&ent, enemyAttack)
			case .MOVE:
				timerRun(&TIMERS[ent.id], f64(10-ent.speed)*.003, rl.GetTime(),&ent, enemyRUN)
		}

	}
}

enemyRUN :: proc(current_enemy : ^Enemy) {
	current_enemy.texture.offset = {0,0}
	if current_enemy.currentDir == 1 {
		if enemyAnimations["RUN"].valB[0] > current_enemy.rotation {
			current_enemy.rotation += 5
		} else {
			current_enemy.currentDir = -1

		}
	} else if current_enemy.currentDir == -1 {
		
		if enemyAnimations["RUN"].valB[1] < current_enemy.rotation {

			current_enemy.rotation -= 5
		} else {
			current_enemy.currentDir = 1
		}
	} else {
		current_enemy.currentDir = enemyAnimations["RUN"].valA[0]
	}
}

enemyAttack :: proc(ent : ^Enemy) {
	ent.rotation = 0
	timerRun(&TIMERS[combine(ent.id,"ATTACK")], ent.attackSpeed, rl.GetTime(),proc() {g_Game_State.player.currentHP-=1})
	if(calcDistance(ent.pos, ent.pos+ent.texture.offset) > enemyAnimations["ATTACK"].valB[0]) {
		ent.currentDir = -1	
	} else if(calcDistance(ent.pos, ent.pos+ent.texture.offset) <= 0) {
		ent.currentDir = 1
	} 
	ent.texture.offset += ent.direction * f32(ent.currentDir)
	//error when enemy starto moving in wierd dir is caused becouse direction is calculated wrongly maybe player can push enemies?\
}

enemySpawnLocation :[4]i32 = {1,2,3,4}
spawnEnemy :: proc() {
	spawnLocation : Vec2f
	switch rand.choice(enemySpawnLocation[:]) {
		case 1: 
			spawnLocation = {f32(rl.GetScreenWidth()/2), f32(rl.GetRandomValue(-rl.GetScreenHeight()/2, rl.GetScreenHeight()/2))}
		case 2:
			spawnLocation = {-f32(rl.GetScreenWidth()/2), f32(rl.GetRandomValue(-rl.GetScreenHeight()/2, rl.GetScreenHeight()/2))}
		case 3:
			spawnLocation = {f32(rl.GetRandomValue(-rl.GetScreenWidth()/2, rl.GetScreenWidth()/2)), f32(rl.GetScreenHeight()/2)}
		case 4:
			spawnLocation = {f32(rl.GetRandomValue(-rl.GetScreenWidth()/2, rl.GetScreenWidth()/2)), f32(-rl.GetScreenHeight()/2)}
	}
	enemy := Enemy {
		ent = Entity {
			pos = g_Game_State.player.pos + (spawnLocation*0.5),
			texture = Sprite {
				texture = g_Game_State.assets["atlas"],
				atlas_pos = {int(rl.GetRandomValue(0, 2)), 0},
				texture_scale = {16, 16},
			},
			health = 20,
			speed = f32(rl.GetRandomValue(1, 5)) / 7,
			color = rl.Color {
				cast(u8)rl.GetRandomValue(0, 255),
				cast(u8)rl.GetRandomValue(0, 255),
				cast(u8)rl.GetRandomValue(0, 255),
				255,
			},
			id = genRandString(10)
		},
		projectiles = [dynamic]Projectile{},
		state = .IDLE,
		attackSpeed = .5
	}
	enemy.collider = SetCollider(.OVAL, Vec2f{3, 0})
	append(&g_Game_State.enemy, enemy)
	TIMERS[enemy.id] = 0.0
	TIMERS[combine(enemy.id,"ATTACK")] = 0.0
	spawnCount += 1
	g_Game_State.spawnedEnemies += 1  
}