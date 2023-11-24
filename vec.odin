package main

import "core:fmt"
import "core:math"

Vec3 :: distinct [3]f64
Point :: Vec3
Color :: Vec3

length :: proc(v: Vec3) -> f64 {
	return math.sqrt(vec_length_squared(v))
}

vec_length_squared :: proc(v: Vec3) -> f64 {
	squared := v * v
	return squared.x + squared.y + squared.z
}

dot :: proc(v, u: Vec3) -> f64 {
	result := v * u
	return result.x + result.y + result.z
}

cross :: proc(v, u: Vec3) -> (res: Vec3) {
	res.x = u.y * v.z - u.z * v.y
	res.y = u.z * v.x - u.x * v.z
	res.z = u.x * v.y - u.y * v.x
	return
}

negate :: proc(v: ^Vec3) {
	v^ *= -1
}

unit :: proc(v: Vec3) -> Vec3 {
	return v / length(v)
}

Color_Formatter :: proc(fi: ^fmt.Info, arg: any, verb: rune) -> bool {
	v := cast(^Color)arg.data
	switch verb {
	case 'v':
		fmt.fmt_int(fi, u64(255.999 * v.r), false, size_of(int), 'd')
		fmt.fmt_string(fi, " ", 's')
		fmt.fmt_int(fi, u64(255.999 * v.g), false, size_of(int), 'd')
		fmt.fmt_string(fi, " ", 's')
		fmt.fmt_int(fi, u64(255.999 * v.b), false, size_of(int), 'd')
	case:
		return false
	}

	return true
}
