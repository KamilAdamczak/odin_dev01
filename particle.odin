package main

import rl "vendor:raylib"
import "core:fmt"
Particle :: struct {
    pos : Vec2f,
    dir : Vec2f,
    sprite : Sprite,
    life : f32,
    size : f32,
}

createParticle :: proc(pos : Vec2f, dir : Vec2f, sprite : Sprite, life : f32) -> Particle{
    return Particle {pos, dir, sprite, life, 1}
}

ParticleEmitter :: struct {
    pos: Vec2f,
    emmisionDirection: Vec2f,
    emmisionPower: f32,
    sprite : Sprite,
    emmisionLife : f32,
    particles : [dynamic] Particle,
    emissiontype : EmityType,
}

EmityType :: enum {
	EXPLOSION,
	TRAIL,
	FOUNTAIN,
}

createParticleEmmiter :: proc(pos : Vec2f, emmisionDirection: Vec2f, emmisionPower : f32, sprite : Sprite, emmisionLife : f32, emissiontype : EmityType = .TRAIL) -> ParticleEmitter {
    return ParticleEmitter {pos, emmisionDirection, emmisionPower, sprite, emmisionLife, {}, emissiontype}
}

ParticleEmitterUpdate :: proc(particleEmitter : ^ParticleEmitter) {
    switch particleEmitter.emissiontype {
    case .TRAIL:
        append(&particleEmitter.particles, createParticle(
            particleEmitter.pos, 
            -particleEmitter.emmisionDirection,
            particleEmitter.sprite,
            particleEmitter.emmisionLife))
        for &particle, index in particleEmitter.particles {
            particle.size -= .1
            // particle.life -= .1
            if particle.size <= .0 {
                ordered_remove(&particleEmitter.particles, index)
            }
        }
    case .EXPLOSION:
        if len(particleEmitter.particles) < 36 {
            append(&particleEmitter.particles, createParticle(
                particleEmitter.pos, 
                -particleEmitter.emmisionDirection,
                particleEmitter.sprite,
                particleEmitter.emmisionLife))
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
                rl.WHITE - {0,0,0,0},
            )
    }
}


