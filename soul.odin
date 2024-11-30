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
        ent = createEntity(position = position, coll = SetCollider(.OVAL, Vec2f{5, 0}), spr = createSprite(
            g_Game_State.assets["atlas"],
            {2,1},
            {16,16}
            ),),
        active = false,
        particleEmitter = createParticleEmitter(
            position,
            Vec2f{0, -1},
             .1,
            //  g_Game_State.whiteSquareTexture, 
             createSprite(
                g_Game_State.assets["atlas"],
                {3,1},
                {16,16}
                ),
            1000000,
            .FOUNTAIN,
            rl.WHITE,
            nil)
            }
    // soul.collider = SetCollider(.OVAL, Vec2f{10, 0})
    soul.id = genRandString(20)
    soul.speed = 150
    TIMERS[soul.id] = 0
    return soul
}

SoulsUpdate :: proc(souls : ..^Soul) {
    for &soul, index in souls {
        if checkCollisionCollider(soul.collider, g_Game_State.player.dropCollider) {
            soul.active = true
        }
        if soul.active {
            timerRun(&TIMERS[soul.id], .1, rl.GetTime(), soul ,proc(soul : ^Soul) {soul.speed += 10})
            soul.pos = rl.Vector2MoveTowards(soul.pos, g_Game_State.player.pos,soul.speed*rl.GetFrameTime())
            soul.particleEmitter.pos = soul.pos
            
        }
        if rl.Vector2Distance(soul.pos, g_Game_State.player.pos) < 3 {
            append(
                &g_Game_State.particleEmitters, 
                createParticleEmitter(
                    g_Game_State.player.pos,
                    {-1, -1},
                    1,
                    Sprite{
                        texture = g_Game_State.assets["atlas"],
                        atlas_pos = {3, 1},
                        texture_scale = {16, 16},
                    },
                    4,
                    .EXPLOSION,
                    rl.WHITE
                ))
            g_Game_State.collected_souls += 1
            RemoveFromArray(&g_Game_State.souls_drops, soul)
        }
        ParticleEmitterUpdate(&soul.particleEmitter)
        // fmt.println(TIMERS[soul.particleEmitter.id])
    }
    
}
