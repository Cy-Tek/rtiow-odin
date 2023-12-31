package main

import "core:math"

Sphere :: struct {
	center: Point,
	radius: f64,
	mat:    Material,
}

hit_sphere :: proc(using sphere: Sphere, r: Ray, ray_t: Interval) -> (Hit_Record, bool) {
	oc := r.origin - center
	a := vec_length_squared(r.direction)
	half_b := dot(oc, r.direction)
	c := vec_length_squared(oc) - radius * radius
	discriminant := half_b * half_b - a * c

	if discriminant < 0 {
		return Hit_Record{}, false
	}
	sqrtd: f64 = math.sqrt(discriminant)

	// Find the nearest root that lies in the acceptable range
	root := (-half_b - sqrtd) / a
	if !interval_surrounds(ray_t, root) {
		root = (-half_b + sqrtd) / a
		if !interval_surrounds(ray_t, root) {
			return Hit_Record{}, false
		}
	}

	rec := Hit_Record {
		t = root,
		mat = mat
	}
	rec.point = ray_at(r, rec.t)

	outward_normal := (rec.point - center) / radius
	hit_rec_set_face_normal(&rec, r, outward_normal)

	return rec, true
}
