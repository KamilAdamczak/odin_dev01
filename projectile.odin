package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"

Projectile :: struct {
	using ent: Entity,
	dmg:       int,
	particleEmitter : ParticleEmitter
}

spawnProjectile :: proc(position: Vec2f, direction: Vec2f) {
	projectile := Projectile {
		ent = Entity {
			pos = position,
			texture = Sprite {
				texture = g_Game_State.assets["atlas"],
				atlas_pos = {0, 1},
				texture_scale = {16, 16},
			},
			health = 1,
			speed = 3,
			color = rl.WHITE,
			direction = direction,
			id = genRandString(20)
		},
		dmg = 10,
	}
	projectile.collider = SetCollider(.OVAL, Vec2f{4.0, 0.0})
	projectile.particleEmitter = createParticleEmmiter(projectile.pos, projectile.direction, 1.0, projectile.texture, 100000000)
	append(&g_Game_State.projectiles, projectile)
}

updateProjectiles :: proc(projectiles : ..^Projectile) {
	print(cast(string)rl.TextFormat("%i",(len(projectiles))))
	for &projectile, index in  projectiles{
		if projectile.health <= 0 ||
		   abs(projectile.pos.x - g_Game_State.player.pos.x) > 1000 ||
		   abs(projectile.pos.y - g_Game_State.player.pos.y) > 1000 {
			projectile.dmg = 0
			projectile.color = rl.Color {0,0,0,0}
			clearTimers(projectile.particleEmitter)
			ordered_remove(&g_Game_State.projectiles, index)
			continue
		}
		EntityMove(projectile)
		projectile.particleEmitter.pos = projectile.pos
		ParticleEmitterUpdate(&projectile.particleEmitter)
		append(&g_Game_State.thigs_to_draw, procCall{SpriteDraw, particleEmittersReturnSprite(projectile.particleEmitter)})
		// ParticleEmitterDraw(projectile.particleEmitter)
		// projectile.direction = calcDirection(projectile.pos, closesTarget(childToParent(g_Game_State.enemy), projectile).pos)
	}
}

