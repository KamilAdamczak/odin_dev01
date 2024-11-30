package main

import rl "vendor:raylib"
import "core:fmt"

Player :: struct {
	using ent:   Entity,
	attackSpeed: f64,
	state : playerState,
	currentDir : int,
	maxHP : f32,
	currentHP: f32,
	dropCollider : Collider,
}

playerState :: enum {
	IDLE,
	MOVE,
	ATTACK,
}
playerAnimation :: struct {
	startDir : int,
	rightAngle : f32,
	leftAngle : f32,
}
 
playerAnimations := map[string]playerAnimation {
	"RUN" = {1, 30,-30},
}

playerUpdate :: proc() {
	g_Game_State.player.dropCollider.pos = g_Game_State.player.pos
	if rl.IsKeyDown(.A) {
		g_Game_State.player.direction.x = -1
	}
	if rl.IsKeyDown(.D) {
		g_Game_State.player.direction.x = 1
	}
	if rl.IsKeyDown(.W) {
		g_Game_State.player.direction.y = -1
	}
	if rl.IsKeyDown(.S) {
		g_Game_State.player.direction.y = 1
	}

	if rl.IsKeyReleased(.A) || rl.IsKeyReleased(.D) {
		g_Game_State.player.direction.x = 0
	}

	if rl.IsKeyReleased(.W) || rl.IsKeyReleased(.S) {
		g_Game_State.player.direction.y = 0
	}
	if g_Game_State.player.direction != {0, 0} {
		g_Game_State.player.state = .MOVE
		EntityMove(&g_Game_State.player)
	} else {
		g_Game_State.player.state = .IDLE
	}

	switch g_Game_State.player.state {
		case .IDLE:
			if g_Game_State.player.rotation > 0 {
				g_Game_State.player.rotation -= 5
			} else if g_Game_State.player.rotation < 0 {
				g_Game_State.player.rotation += 5
			} else {
				g_Game_State.player.rotation = 0
			}
		case .ATTACK:
		case .MOVE:
			timerRun(&TIMERS["player"], .01, rl.GetTime(),playerRUN)
	}
}

playerRUN :: proc() {
	if g_Game_State.player.currentDir == 1 {
		if playerAnimations["RUN"].rightAngle > g_Game_State.player.rotation {
			g_Game_State.player.rotation += 5
		} else {
			g_Game_State.player.currentDir = -1

		}
	} else if g_Game_State.player.currentDir == -1 {
		if playerAnimations["RUN"].leftAngle < g_Game_State.player.rotation {

			g_Game_State.player.rotation -= 5
		} else {
			g_Game_State.player.currentDir = 1
		}
	} else {
		g_Game_State.player.currentDir = playerAnimations["RUN"].startDir
	}
	
}

playerDrawHealth :: proc() {
	rl.DrawTexturePro(
		g_Game_State.whiteSquareTexture.texture ,
		{
			f32(g_Game_State.whiteSquareTexture.atlas_pos.x) * 16,
			f32(g_Game_State.whiteSquareTexture.atlas_pos.y) * 16,
			f32(g_Game_State.whiteSquareTexture.texture_scale.x),
			f32(g_Game_State.whiteSquareTexture.texture_scale.y),
		},
		{f32(g_Game_State.player.pos.x), f32(g_Game_State.player.pos.y)+10, (1)*100*.2, 2.0},
		{10, 0},
		0.0,
		rl.BLACK,
	)
	rl.DrawTexturePro(
		g_Game_State.whiteSquareTexture.texture ,
		{
			f32(g_Game_State.whiteSquareTexture.atlas_pos.x) * 16,
			f32(g_Game_State.whiteSquareTexture.atlas_pos.y) * 16,
			f32(g_Game_State.whiteSquareTexture.texture_scale.x),
			f32(g_Game_State.whiteSquareTexture.texture_scale.y),
		},
		{f32(g_Game_State.player.pos.x), f32(g_Game_State.player.pos.y)+10, (g_Game_State.player.currentHP/g_Game_State.player.maxHP)*100*.2, 2.0},
		{10, 0},
		0.0,
		rl.GREEN,
	)
}