package main

import rl "vendor:raylib"

Enemy :: struct {
	using ent: EntityAtlas,
}

updateEnemy :: proc() {
	for &ent, index in g_Game_State.enemy {
		if ent.health <= 0 {
			ordered_remove(&g_Game_State.enemy, index)
			spawnCount -= 1
			continue
		}

		for &projectile in g_Game_State.projectiles {
			if checkCollision(ent, projectile) {
				projectile.health -= 1
				ent.health -= projectile.dmg
				append(&g_Game_State.particleEmmiters, createParticleEmmiter(ent.pos,{-1, -1},1, projectile.texture, 1, .EXPLOSION))
			}
		}

		ent.direction = calcDirection(ent.pos, g_Game_State.player.pos)
		collision := false
		for entB in g_Game_State.enemy {
			if ent == entB ||
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
		}
		if !collision {
			EntityMove(&ent)
		}
	}

}

spawnEnemy :: proc() {
	enemy := Enemy {
		ent = EntityAtlas {
			pos = g_Game_State.player.pos +
			{f32(rl.GetRandomValue(-3, 3) * 100), f32(rl.GetRandomValue(-3, 3) * 100)},
			texture = Sprite {
				texture = g_Game_State.assets["atlas"],
				atlas_pos = {int(rl.GetRandomValue(0, 2)), 0},
				texture_scale = {16, 16},
			},
			health = 20,
			speed = f32(rl.GetRandomValue(1, 5)) / 10,
			color = rl.Color {
				cast(u8)rl.GetRandomValue(0, 255),
				cast(u8)rl.GetRandomValue(0, 255),
				cast(u8)rl.GetRandomValue(0, 255),
				255,
			},
			id = int(spawnCount),
		},
	}
	enemy.collider = SetCollider(.OVAL, Vec2f{3, 0})
	append(&g_Game_State.enemy, enemy)
	spawnCount += 1
}
