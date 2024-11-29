package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"

Soul :: struct {
	using ent: Entity,
	active:       bool,
	particleEmitter : ParticleEmitter
}

createSoul :: proc(position : Vec2f)->Soul{ 
    soul := Soul{
        ent = createEntity(position = position, coll = SetCollider(.OVAL, Vec2f{10, 0})),
        active = false,
        particleEmitter = createParticleEmmiter(
            position,
            Vec2f{0, -1},
             .1, 
             createSprite(
                g_Game_State.assets["atlas"],
                {2,2},
                {16,16}
                ),
            .1,
            .FOUNTAIN,
            rl.WHITE,
            nil)
            }
    return soul
}
soulDraw :: proc(souls : ..Soul) {
    for soul in souls {
        fmt.println("ADD SOUL DRAW IN soul.odin line 35")
    }
}