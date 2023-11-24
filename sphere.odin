package main

import "core:math"
import "types/ray"
import "types/vec"

Sphere :: struct {
	center: Point,
	radius: f64,
}

hit_sphere :: proc(using sphere: Sphere, r: Ray, ray_tmin, ray_tmax: f64) -> (Hit_Record, bool) {
	oc := r.origin - center
	a := vec.length_squared(r.direction)
	half_b := vec.dot(oc, r.direction)
	c := vec.length_squared(oc) - radius * radius
	discriminant := half_b * half_b - a * c

	if discriminant < 0 {
		return Hit_Record{}, false
	}
	sqrtd: f64 = math.sqrt(discriminant)

	// Find the nearest root that lies in the acceptable range
	root := (-half_b - sqrtd) / a
	if root <= ray_tmin || ray_tmax <= root {
		root = (-half_b + sqrtd) / a
		if (root <= ray_tmin || ray_tmax <= root) {
			return Hit_Record{}, false
		}
	}

	rec := Hit_Record {
		t = root,
	}
	rec.point = ray.at(r, rec.t)

	outward_normal := (rec.point - center) / radius
	set_face_normal(&rec, r, outward_normal)

	return rec, true
}