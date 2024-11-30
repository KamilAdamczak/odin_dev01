package main

import "core:math"
import "core:slice"
import "core:strconv"
import "core:fmt"
import "core:strings"
import "core:math/rand"
import rl "vendor:raylib"

//GLOBALS VALUES
WORLD_WIDTH :: 1
WORLD_HEIGHT :: 1
TILE_SIZE :: 8
WORLD_GRID: Vec2i : {WORLD_WIDTH * TILE_SIZE, WORLD_HEIGHT * TILE_SIZE}
TICK_RATE :: 1 / 60
LATE_TICK_RATE :: 1
TICK_TIMER: f32 = TICK_RATE
LATE_TICK_TIMER: f32 = LATE_TICK_RATE
BACKGROUND_COLOR :: [4]u8{75, 42, 25, 0}

//GLOBAL TYPES
Vec2i :: [2]int
Vec2f :: [2]f32

Tile :: struct {
	neighbourMask: int,
	isVisible:     bool,
}

LOOP_STATE_VALUES :: enum {
	INIT,
	UPDATE,
	DRAW_SHADOWS,
	DRAW_SPRITES,
	DRAW_GUI,
}

Sprite :: struct {
	texture:       rl.Texture2D,
	atlas_pos:     Vec2i,
	texture_scale: Vec2i,
	offset : Vec2f,
	flip : bool
}

createSprite :: proc(texture : rl.Texture2D, atlas_pos : Vec2i = {0,0}, texture_scale: Vec2i = {16,16}, offset : Vec2f = {0,0}, flip : bool = false) -> Sprite {
	return Sprite {texture, atlas_pos, texture_scale, offset, flip}
}

Circle :: struct {
	center: rl.Vector2,
	r:      f32,
}

TIMERS := map[string]f64 {}

//UTILITY PROC
calcDistance :: proc(pointA: Vec2f, pointB: Vec2f) -> f32 {
	delta_x := pointB.x - pointA.x
	delta_y := pointB.y - pointA.y

	return math.sqrt(delta_x * delta_x + delta_y * delta_y)
}

calcDirection :: proc(pointA: Vec2f, pointB: Vec2f) -> Vec2f {
	delta_x := pointB.x - pointA.x
	delta_y := pointB.y - pointA.y

	length := calcDistance(pointA, pointB)
	if length == 0 {
		return {0, 0}
	}

	direction_x := delta_x / length
	direction_y := delta_y / length
	return {direction_x, direction_y}
}

getIndex :: proc(array: [dynamic]Entity, object: Enemy) -> int {
	for index in 00 ..< len(array) {
		if array[index] == object.ent {
			return index
		}
	}
	return 0
}

hasID :: proc(array : [dynamic]$T, object : T) -> bool {
	for obj in array {
		if obj.id == object.id {
			return true
		} else {
			continue
		}
	}
	return false
}

timerRun :: proc {
	timeRunNormal,
	timeRunWithVariable,
}



timeRunNormal :: proc(timer: ^f64, timeToWait: f64, currentTime: f64, callProcedure: proc()) {
	if (timer^ + timeToWait < currentTime) {
		callProcedure()
		timer^ = currentTime
	}
}

timeRunWithVariable :: proc(timer: ^f64, timeToWait: f64, currentTime: f64 , var : ^$T , callProcedure: proc(var : ^T)) {
	if (timer^ + timeToWait < currentTime) {
		callProcedure(var)
		timer^ = currentTime
	}
}

combine :: proc(texts : ..string) -> string {
	return strings.join(texts[:],"")
}

IntToString :: proc(value:int) -> string {
	buf: [64]u8 = ---
	s := strconv.itoa(buf[:], value)
	return s
}

genChar :: proc() -> string {
	charSet : [24]string =  {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","R","S","T","U","V","X","Y","Z"}
	return rand.choice(charSet[:])
}

genRandString :: proc(lenght : int) -> (randomString : string) {
	for index in 0..<lenght {
		randomString = combine(randomString, genChar())
	}
	return randomString
}

// ScreenToWorld :: proc(screen_pos: Vec2f) -> Vec2i {
// 	xPos := f32(screen_pos.x) / g_Game_State.camera.zoom
// 	yPos := f32(screen_pos.y) / TILE_SIZE / g_Game_State.camera.zoom
// 	return {int(xPos), int(yPos)}
// }

screenToWorld :: proc(PosOnScreen: Vec2f) -> Vec2f {
	return (PosOnScreen + camera.offset) / camera.zoom
}

getTile :: proc {
	getTileVec2i,
	getTileXY,
}

getTileXY :: proc(x: int, y: int) -> ^Tile {
	tile: ^Tile = nil

	if x >= 0 && x <= WORLD_GRID.x && y >= 0 && y <= WORLD_GRID.y {
		tile = &g_Game_State.worldGrid[x][y]
	}

	return tile
}
getTileVec2i :: proc(worldPos: Vec2i) -> ^Tile {
	x := worldPos.x
	y := worldPos.y

	return getTile(x, y)
}

closesTarget :: proc(mainObject : Entity, arrayOfObjects : ..Entity) -> (cTarget : Entity) {
	cTarget = arrayOfObjects[0]
	old_cc := rl.Vector2Distance(cTarget.pos, mainObject.pos)
	for ent in arrayOfObjects {
		new_cc := rl.Vector2Distance(ent.pos, mainObject.pos)
		if new_cc < old_cc {
			cTarget = ent
			old_cc = new_cc
		}
	}
	return cTarget
}

// childToParent::proc(child : $T) -> (parent : [dynamic]Entity) {
// 	for ent in child {
// 		append(&parent, ent.ent)
// 	}
// 	return parent
// }

// getFromStruct :: proc(typePtr: ^S, structArr: ..T) -> (values: [dynamic]S)
//     where T: type {
//     for single_struct in structArr {
//         append(&values, typePtr^); // Dereference the field pointer to get its value
//         typePtr += 1;             // Move the pointer to the next struct
//     }
//     return values;
// }


getFromStruct :: proc(structArr: ..$T, fieldAccessor: proc(^T) -> $S = nil) -> (values: [dynamic]S) {
    for &single_struct in structArr {
        value := fieldAccessor(&single_struct);
        append(&values, value);
    }
    return values;
}

textAlign :: enum {
	LEFT,
	CENTER,
	RIGHT,
}

setTextAlign :: proc(txt : cstring, font : rl.Font , fontSize, fontSpacing : f32, alignType : textAlign) -> rl.Vector2 {
	switch alignType {
		case .LEFT:
			return {0,0}
		case .CENTER:
			return {rl.MeasureTextEx(font,txt,fontSize,fontSpacing).x/2,0}
		case .RIGHT:
			return {rl.MeasureTextEx(font,txt,fontSize,fontSpacing).x,0}
	}
	return {0,0}
}

convert_to_pointers :: proc(array_of_object : ..$T) -> []^T {
	// print(cast(string)rl.TextFormat("%i",(len(array_of_object))))
	pointers := make([]^type_of(array_of_object[0]), len(array_of_object))
	for &p, i in array_of_object {
		pointers[i] = &p
	}
	return pointers
}

RemoveFromArray :: proc(arr : ^$T, valueToRemove : $S) {
	cp_arr : T
	for item in arr {
		if item.id == valueToRemove.id {
			continue
		} else {
			append(&cp_arr, item)
		}
	}
	clear(arr)
	append(arr, ..cp_arr[:])
	// arr = make(cp_arr)
}