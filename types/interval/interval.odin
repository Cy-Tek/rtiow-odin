package interval

import "core:math"

Interval :: struct {
    min, max: f64
}

contains :: proc(using interval: Interval, val: f64) -> bool {
    return min <= val && val <= max
}
