package types

import "core:fmt"
import "core:math"

Vec3 :: distinct [3]f64
Point :: Vec3
Color :: Vec3

length :: proc(v: Vec3) -> f64 {
	return math.sqrt(length_squared(v))
}

length_squared :: proc(v: Vec3) -> f64 {
	squared := v * v
	return v.x + v.y + v.z
}

dot :: proc(v, u: Vec3) -> f64 {
	result := v * u
	return result.x + result.y + result.z
}

cross :: proc(v, u: Vec3) -> Vec3 {
	result: Vec3
	result.x = u.y * v.z - u.z * v.y
	result.y = u.z * v.x - u.x * v.z
	result.z = u.x * v.y - u.y * v.x

	return result
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
		fmt.fmt_string(fi, "\n", 's')
	case:
		return false
	}

	return true
}
