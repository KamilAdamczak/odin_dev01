package main

import rl "vendor:raylib"

Projectile :: struct {
	using ent: EntityAtlas,
	dmg:       int,
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
			health = 3,
			speed = 4,
			color = rl.WHITE,
			direction = direction,
		},
		dmg = 4,
	}
	projectile.collider = SetCollider(.OVAL, Vec2f{4.0, 0.0})
	append(&g_Game_State.projectiles, projectile)
}

updateProjectiles :: proc() {
	for &projectile, index in g_Game_State.projectiles {
		if projectile.health <= 0 ||
		   abs(projectile.pos.x - g_Game_State.player.pos.x) > 1000 ||
		   abs(projectile.pos.y - g_Game_State.player.pos.y) > 1000 {
			ordered_remove(&g_Game_State.projectiles, index)
			continue
		}
		EntityMove(&projectile)
	}
}
