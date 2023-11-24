package main

Ray :: struct {
	origin:    Point,
	direction: Vec3,
}

ray_at :: proc(using r: Ray, t: f64) -> Point {
	return origin + t * direction
}
