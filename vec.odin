package main

import "core:fmt"
import "core:math"
import "core:strings"

Vec3 :: distinct [3]f64
Point :: Vec3
Color :: Vec3

vec_length :: proc(v: Vec3) -> f64 {
	return math.sqrt(vec_length_squared(v))
}

vec_length_squared :: proc(v: Vec3) -> f64 {
	squared := v * v
	return squared.x + squared.y + squared.z
}

clamp_vec :: proc(v: Vec3, interval: Interval) -> Vec3 {
	return(
		Vec3 {
			clamp_interval(interval, v.x),
			clamp_interval(interval, v.y),
			clamp_interval(interval, v.z),
		}
	)
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
	return v / vec_length(v)
}
