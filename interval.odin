package main

import "core:math"

Interval :: struct {
	min, max: f64,
}

interval_contains :: proc(using interval: Interval, val: f64) -> bool {
	return min <= val && val <= max
}

interval_surrounds :: proc(using interval: Interval, val: f64) -> bool {
	return min < val && val < max
}

clamp_interval :: proc(using interval: Interval, val: f64) -> f64 {
	switch {
	case val < min:
		return min
	case val > max:
		return max
	case:
		return val
	}
}

Empty :: Interval{math.INF_F64, math.NEG_INF_F64}
Universe :: Interval{math.NEG_INF_F64, math.INF_F64}
