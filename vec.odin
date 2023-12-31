package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strings"

Vec3 :: distinct [3]f64
Point :: Vec3
Color :: Vec3

random_vec :: #force_inline proc() -> Vec3 {
	return ( 
		Vec3{
			rand.float64(), 
			rand.float64(), 
			rand.float64()
		}
	)
}

random_vec_in_range :: #force_inline proc(min, max: f64) -> Vec3 {
	return (
		Vec3{
			rand.float64_range(min, max),
			rand.float64_range(min, max),
			rand.float64_range(min, max)
		}
	)
}

random_vec_in_unit_sphere :: #force_inline proc() -> Vec3 {
	for {
		p := random_vec_in_range(-1, 1)
		if vec_length_squared(p) < 1 {
			return p
		}
	}
}

random_vec_in_unit_disk :: #force_inline proc() -> Vec3 {
	for {
		p := Vec3{rand.float64_range(-1, 1), rand.float64_range(-1, 1), 0}
		if vec_length_squared(p) < 1 {
			return p
		}
	}
}

random_unit_vec :: #force_inline proc() -> Vec3 {
	return unit(random_vec_in_unit_sphere())
}

random_vec_on_hemisphere :: #force_inline proc(normal: Vec3) -> Vec3 {
	on_unit_sphere := random_unit_vec()
	if dot(on_unit_sphere, normal) > 0 {
		return on_unit_sphere
	}
	
	return negate_vec(on_unit_sphere)
}

vec_length :: #force_inline proc(v: Vec3) -> f64 {
	return math.sqrt(vec_length_squared(v))
}

vec_length_squared :: #force_inline proc(v: Vec3) -> f64 {
	squared := v * v
	return squared.x + squared.y + squared.z
}

vec_near_zero :: #force_inline proc(v: Vec3) -> bool {
	s := 1e-8
	return abs(v.x) < s && abs(v.y) < s && abs(v.z) < s
}

reflect_vec :: #force_inline proc(v: Vec3, normal: Vec3) -> Vec3 {
	return v - 2 * dot(v, normal) * normal
}

refract_vec :: #force_inline proc(uv: Vec3, normal: Vec3, etai_over_etat: f64) -> Vec3 {
	cos_theta: f64 = min(dot(negate_vec(uv), normal), 1.0)
	r_out_perp := etai_over_etat * (uv + cos_theta * normal)
	r_out_parallel: Vec3 = -math.sqrt(abs(1.0 - vec_length_squared(r_out_perp))) * normal
	return r_out_perp + r_out_parallel
}

clamp_vec :: #force_inline proc(v: Vec3, interval: Interval) -> Vec3 {
	return(
		Vec3 {
			clamp_interval(interval, v.x),
			clamp_interval(interval, v.y),
			clamp_interval(interval, v.z),
		}
	)
}

dot :: #force_inline proc(v, u: Vec3) -> f64 {
	result := v * u
	return result.x + result.y + result.z
}

cross :: #force_inline proc(v, u: Vec3) -> (res: Vec3) {
	res.x = u.y * v.z - u.z * v.y
	res.y = u.z * v.x - u.x * v.z
	res.z = u.x * v.y - u.y * v.x
	return
}

negate_vec :: #force_inline proc(v: Vec3) -> Vec3 {
	return v * -1
}

unit :: #force_inline proc(v: Vec3) -> Vec3 {
	return v / vec_length(v)
}

linear_to_gamma :: #force_inline proc(linear_component: f64) -> f64 {
	return math.sqrt(linear_component)
}