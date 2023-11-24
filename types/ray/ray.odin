package ray

import "../vec"

Ray :: struct {
    origin: vec.Point,
    direction: vec.Vec3,
}

at :: proc(using r: Ray, t: f64) -> vec.Point {
    return origin + t * direction
}