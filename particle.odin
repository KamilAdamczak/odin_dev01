package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strconv"
import "core:strings"

Particle :: struct {
    pos : Vec2f,
    dir : Vec2f,
    sprite : Sprite,
    life : f32,
    size : f32,
    alpha : u8,
    color : rl.Color,
    speed : f32,
}

createParticle :: proc(pos : Vec2f, dir : Vec2f, sprite : Sprite, life : f32, size : f32 = 1, color : rl.Color) -> Particle{
    return Particle {pos, dir, sprite, life, size, 0, color,0}
}

ParticleEmitter :: struct {
    pos: Vec2f,
    emmisionDirection: Vec2f,
    emmisionPower: f64,
    sprite : Sprite,
    emmisionLife : f32,
    particles : [dynamic] Particle,
    emissionType : EmittType,
    emissionShape : EmittShape,
    emissionColor : rl.Color,
    spawning : bool,
    id : string,
}

EmittType :: enum {
	EXPLOSION,
	TRAIL,
	FOUNTAIN,
}

EmittShape :: enum {
	A,
	B,
	C,
}

createParticleEmitter :: proc(pos : Vec2f, emmisionDirection: Vec2f, emmisionPower : f64, sprite : Sprite, emmisionLife : f32, emissiontype : EmittType = .TRAIL, emissionColor : rl.Color = rl.WHITE, emissionshape : EmittShape = nil) -> ParticleEmitter {
    // rand.reset(u64(emmisionDirection.x*emmisionDirection.y+f32(rl.GetTime())*f32(rl.GetRandomValue(0,100))))
    id := genRandString(10)
    TIMERS[id] = 0.0
    TIMERS[combine(id,"SPAWN")] = 0.0
    emissionshaper : EmittShape
    if (emissionshape == nil) {
        emissionshaper = rand.choice_enum(EmittShape)
    } else {
        emissionshaper = emissionshape
    }
    // TIMERS[string(id)] = 1.0
    return ParticleEmitter {pos, emmisionDirection, emmisionPower, sprite, emmisionLife, {}, emissiontype, emissionshaper,emissionColor,false,id}
}

destroyGlobalParticleEmitter :: proc(gameState : ^Game_State ,particleEmitter : ^ParticleEmitter) {
    for emitter, index in gameState.particleEmitters {
        
        if emitter.id == particleEmitter.id {
            delete_key(&TIMERS, particleEmitter.id)
            // unordered_remove(&gameState.particleEmitters, index)
            RemoveFromArray(&gameState.particleEmitters, emitter)
        }
    }
}

clearTimers :: proc(particleEmitter : ParticleEmitter) {
    delete_key(&TIMERS, particleEmitter.id)
}

ParticleEmitterUpdate :: proc(particleEmitter : ^ParticleEmitter) {
    // fmt.println(particleEmitter.id, particleEmitter.emmisionLife)
    if (particleEmitter.emmisionLife <= 0) {
        destroyGlobalParticleEmitter(&g_Game_State, particleEmitter)
    } else {
        timerRun(&TIMERS[particleEmitter.id], .1, rl.GetTime(), particleEmitter ,proc(partEm : ^ParticleEmitter) {partEm.emmisionLife -= 1})
    }
    timerRun(&TIMERS[combine(particleEmitter.id,"SPAWN")], particleEmitter.emmisionPower, rl.GetTime(), particleEmitter ,proc(partEm : ^ParticleEmitter) {partEm.spawning = true})
    
    switch particleEmitter.emissionType {
    case .TRAIL:
        if particleEmitter.spawning {append(&particleEmitter.particles, createParticle(
            particleEmitter.pos, 
            -particleEmitter.emmisionDirection,
            particleEmitter.sprite,
            particleEmitter.emmisionLife, 1, particleEmitter.emissionColor))}
        for &particle, index in particleEmitter.particles {
            particle.size -= 5 * rl.GetFrameTime()
            // particle.life -= .1
            if particle.size <= .0 {
                unordered_remove(&particleEmitter.particles, index)
            }
        }
    case .EXPLOSION:
        for index in len(particleEmitter.particles)..<36 {
            if particleEmitter.spawning {
                append(&particleEmitter.particles, createParticle(
                particleEmitter.pos, 
                -particleEmitter.emmisionDirection,
                particleEmitter.sprite,
                particleEmitter.emmisionLife,
                .7, particleEmitter.emissionColor))}
        }

        for &particle, index in particleEmitter.particles {
            particle.size -= 1 * rl.GetFrameTime()
            angle_in_degrees: f64 = f64(index) * 10.0
            angle_in_radians: f64 = angle_in_degrees * math.PI / 180.0
            particle.alpha += u8(200 * rl.GetFrameTime())
            particle.dir.x = f32(math.cos(angle_in_radians))
            particle.dir.y = f32(math.sin(angle_in_radians))
            switch particleEmitter.emissionShape {
                case .A:
                    if index % 2 == 0 {
                        particle.speed = 30
                    } else if index % 3 == 0 {
                        particle.speed = 80
                    }else {
                        particle.speed = 60
                    }
                case .B:
                    if index % 3 == 0 {
                        particle.speed = 30
                    } else if index % 4 == 0 {
                        particle.speed = 80
                    }else {
                        particle.speed = 60
                    }
                case .C:
                    if index % 4 == 0 {
                        particle.speed = 30
                    } else if index % 5 == 0 {
                        particle.speed = 80
                    }else {
                        particle.speed = 60
                    }
            }

            particle.pos += particle.dir * particle.speed * f32(rl.GetFrameTime())
            
        }
    case .FOUNTAIN:
        if particleEmitter.spawning {
            append(&particleEmitter.particles, createParticle(
                particleEmitter.pos, 
                -particleEmitter.emmisionDirection,
                particleEmitter.sprite,
                particleEmitter.emmisionLife, 1, particleEmitter.emissionColor))
        }
        for &particle, index in particleEmitter.particles {
            particle.size -= 3 * rl.GetFrameTime()
            // particle.life -= .1
            particle.dir = Vec2f{rand.float32_range(-1, 1),rand.float32_range(0, 1)}
            particle.pos = rl.Vector2MoveTowards(particle.pos, particle.pos-particle.dir, 200*rl.GetFrameTime())
            if particle.size <= .0 {
                unordered_remove(&particleEmitter.particles, index)
            }
        }
    }
    particleEmitter.spawning = false
}

//add Particle To Entity function then can y sort and draw with other
ParticleEmitterDraw :: proc(particleEmitters : ..ParticleEmitter) {
    for particleEmitter in particleEmitters {
        for particle in particleEmitter.particles {
            rl.DrawTexturePro(
                particle.sprite.texture,
                {
                    f32(particle.sprite.atlas_pos.x) * 16,
                    f32(particle.sprite.atlas_pos.y) * 16,
                    f32(particle.sprite.texture_scale.x),
                    f32(particle.sprite.texture_scale.y),
                },
                {f32(particle.pos.x), f32(particle.pos.y), f32(particle.sprite.texture_scale.x)*particle.size, f32(particle.sprite.texture_scale.y)*particle.size},
                {8, 8}*particle.size,
                0.0,
                particle.color - {0,0,0,particle.alpha},
            )
        }
    }
}