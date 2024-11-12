package main

import rl "vendor:raylib"
import "core:fmt"
Particle :: struct {
    pos : Vec2f,
    dir : Vec2f,
    sprite : Sprite,
    life : f32,
}

createParticle :: proc(pos : Vec2f, dir : Vec2f, sprite : Sprite, life : f32) -> Particle{
    return Particle {pos, dir, sprite, life}
}

ParticleEmitter :: struct {
    pos: Vec2f,
    emmisionDirection: Vec2f,
    emmisionPower: f32,
    sprite : Sprite,
    emmisionLife : f32,
    particles : [dynamic] Particle,
}

createParticleEmmiter :: proc(pos : Vec2f, emmisionDirection: Vec2f, emmisionPower : f32, sprite : Sprite, emmisionLife : f32) -> ParticleEmitter {
    return ParticleEmitter {pos, emmisionDirection, emmisionPower, sprite, emmisionLife, {}}
}

ParticleEmitterUpdate :: proc(particleEmitter : ^ParticleEmitter) {
    append(&particleEmitter.particles, createParticle(
        particleEmitter.pos, 
        -particleEmitter.emmisionDirection,
        particleEmitter.sprite,
        particleEmitter.emmisionLife))
    for &particle, index in particleEmitter.particles {
        particle.pos +=
        Vec2f{f32(particle.dir.x), f32(particle.dir.y)} *
        1 *
        f32(rl.GetFrameTime() * 100)
        
        particle.life -= .1
        if particle.life <= 0 {
            ordered_remove(&particleEmitter.particles, index)
        }
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
                {f32(particle.pos.x), f32(particle.pos.y), 8.0, 8.0},
                {8, 8},
                0.0,
                rl.WHITE,
            )
    }
}


