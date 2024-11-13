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
    speed : f32
}

createParticle :: proc(pos : Vec2f, dir : Vec2f, sprite : Sprite, life : f32, size : f32 = 1) -> Particle{
    return Particle {pos, dir, sprite, life, size, 0, 0}
}

ParticleEmitter :: struct {
    pos: Vec2f,
    emmisionDirection: Vec2f,
    emmisionPower: f32,
    sprite : Sprite,
    emmisionLife : f32,
    particles : [dynamic] Particle,
    emissionType : EmittType,
    emissionShape : EmittShape,
    id : string,
}

ParticleEmitterID : [dynamic]string = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","R","S","T","U","V","X","Y","Z"}

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

createParticleEmmiter :: proc(pos : Vec2f, emmisionDirection: Vec2f, emmisionPower : f32, sprite : Sprite, emmisionLife : f32, emissiontype : EmittType = .TRAIL, emissionshape : EmittShape = nil) -> ParticleEmitter {
    // rand.reset(u64(emmisionDirection.x*emmisionDirection.y+f32(rl.GetTime())*f32(rl.GetRandomValue(0,100))))
    id := strings.join({rand.choice(ParticleEmitterID[:]),rand.choice(ParticleEmitterID[:]),rand.choice(ParticleEmitterID[:]),rand.choice(ParticleEmitterID[:]),rand.choice(ParticleEmitterID[:]),rand.choice(ParticleEmitterID[:]),rand.choice(ParticleEmitterID[:]),rand.choice(ParticleEmitterID[:]),rand.choice(ParticleEmitterID[:]),rand.choice(ParticleEmitterID[:]),rand.choice(ParticleEmitterID[:]),rand.choice(ParticleEmitterID[:])}, rand.choice(ParticleEmitterID[:]))
    TIMERS[id] = 0.0
    emissionshaper : EmittShape
    if (emissionshape == nil) {
        emissionshaper = rand.choice_enum(EmittShape)
    } else {
        emissionshaper = emissionshape
    }
    // TIMERS[string(id)] = 1.0
    return ParticleEmitter {pos, emmisionDirection, emmisionPower, sprite, emmisionLife, {}, emissiontype, emissionshaper,id}
}

destroyGlobalParticleEmmiter :: proc(gameState : ^Game_State ,particleEmmiter : ^ParticleEmitter) {
    for emmiter, index in gameState.particleEmmiters {
        if emmiter.id == particleEmmiter.id {
            delete_key(&TIMERS, particleEmmiter.id)
            ordered_remove(&gameState.particleEmmiters, index)
        }
    }
}

clearTimers :: proc(particleEmitter : ParticleEmitter) {
    delete_key(&TIMERS, particleEmitter.id)
}

partEm : ^ParticleEmitter
ParticleEmitterUpdate :: proc(particleEmitter : ^ParticleEmitter) {
    // fmt.println(TIMERS)
    partEm = particleEmitter
    if (particleEmitter.emmisionLife < 0) {
        destroyGlobalParticleEmmiter(&g_Game_State, particleEmitter)
    } else {
        timerRun(&TIMERS[particleEmitter.id], .1, rl.GetTime(), proc() {partEm.emmisionLife -= 1})
    }

    switch particleEmitter.emissionType {
    case .TRAIL:
        append(&particleEmitter.particles, createParticle(
            particleEmitter.pos, 
            -particleEmitter.emmisionDirection,
            particleEmitter.sprite,
            particleEmitter.emmisionLife))
        for &particle, index in particleEmitter.particles {
            particle.size -= 5 * rl.GetFrameTime()
            // particle.life -= .1
            if particle.size <= .0 {
                ordered_remove(&particleEmitter.particles, index)
            }
        }
    case .EXPLOSION:
        for index in len(particleEmitter.particles)..<36 {
            append(&particleEmitter.particles, createParticle(
                particleEmitter.pos, 
                -particleEmitter.emmisionDirection,
                particleEmitter.sprite,
                particleEmitter.emmisionLife,
                .7))
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
    }
}

ParticleEmitterDraw :: proc(particleEmitter : ParticleEmitter) {
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
                rl.WHITE - {0,0,0,particle.alpha},
            )
    }
}


