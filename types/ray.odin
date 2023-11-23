package types

Ray :: struct {
    origin: Point,
    direction: Vec3,
}

at :: proc(using r: Ray, t: f64) -> Point {
    return origin + t * direction
}