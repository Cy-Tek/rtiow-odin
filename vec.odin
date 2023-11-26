package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strings"

Vec3 :: distinct [3]f64
Point :: Vec3
Color :: Vec3

random_vec :: proc() -> Vec3 {
	return ( 
		Vec3{
			rand.float64(), 
			rand.float64(), 
			rand.float64()
		}
	)
}

random_vec_in_range :: proc(min, max: f64) -> Vec3 {
	return (
		Vec3{
			rand.float64_range(min, max),
			rand.float64_range(min, max),
			rand.float64_range(min, max)
		}
	)
}

random_vec_in_unit_sphere :: proc() -> Vec3 {
	for {
		p := random_vec_in_range(-1, 1)
		if vec_length_squared(p) < 1 {
			return p
		}
	}
}

random_unit_vec :: proc() -> Vec3 {
	return unit(random_vec_in_unit_sphere())
}

random_vec_on_hemisphere :: proc(normal: Vec3) -> Vec3 {
	on_unit_sphere := random_unit_vec()
	if dot(on_unit_sphere, normal) > 0 {
		return on_unit_sphere
	}
	
	negate_vec(&on_unit_sphere)
	return on_unit_sphere
}

vec_length :: proc(v: Vec3) -> f64 {
	return math.sqrt(vec_length_squared(v))
}

vec_length_squared :: proc(v: Vec3) -> f64 {
	squared := v * v
	return squared.x + squared.y + squared.z
}

vec_near_zero :: proc(v: Vec3) -> bool {
	s := 1e-8
	return abs(v.x) < s && abs(v.y) < s && abs(v.z) < s
}

reflect_vec :: proc(v: Vec3, normal: Vec3) -> Vec3 {
	return v - 2 * dot(v, normal) * normal
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

negate_vec :: proc(v: ^Vec3) {
	v^ *= -1
}

unit :: proc(v: Vec3) -> Vec3 {
	return v / vec_length(v)
}

linear_to_gamma :: #force_inline proc(linear_component: f64) -> f64 {
	return math.sqrt(linear_component)
}