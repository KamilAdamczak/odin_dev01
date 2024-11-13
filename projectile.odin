package main

import rl "vendor:raylib"
import "core:fmt"

Projectile :: struct {
	using ent: EntityAtlas,
	dmg:       int,
	particleEmitter : ParticleEmitter
}

spawProjectile :: proc(position: Vec2f, direction: Vec2f) {
	projectile := Projectile {
		ent = EntityAtlas {
			pos = g_Game_State.player.pos,
			texture = Sprite {
				texture = g_Game_State.assets["atlas"],
				atlas_pos = {0, 1},
				texture_scale = {16, 16},
			},
			health = 1,
			speed = 3,
			color = rl.WHITE,
			direction = direction,
			id = int(rl.GetRandomValue(0, 1000000000))
		},
		dmg = 10,
	}
	projectile.collider = SetCollider(.OVAL, Vec2f{4.0, 0.0})
	projectile.particleEmitter = createParticleEmmiter(projectile.pos, projectile.direction, 1.0, projectile.texture, 100000000)
	append(&g_Game_State.projectiles, projectile)
	// fmt.print(g_Game_State.particleManager.emitters)
}

updateProjectiles :: proc() {
	for &projectile, index in g_Game_State.projectiles {
		if projectile.health <= 0 ||
		   abs(projectile.pos.x - g_Game_State.player.pos.x) > 1000 ||
		   abs(projectile.pos.y - g_Game_State.player.pos.y) > 1000 {
			projectile.dmg = 0
			projectile.color = rl.Color {0,0,0,0}
			clearTimers(projectile.particleEmitter)
			ordered_remove(&g_Game_State.projectiles, index)
			continue
		}
		EntityMove(&projectile)
		projectile.particleEmitter.pos = projectile.pos
		ParticleEmitterUpdate(&projectile.particleEmitter)
		ParticleEmitterDraw(projectile.particleEmitter)
		// for number in 0..<4 {
		// 	append(&g_Game_State.particleManager.particles, createParticle(projectile.pos+{f32(number), f32(number)}, -projectile.direction, projectile.texture, 0.1))
		// }
	}
}
