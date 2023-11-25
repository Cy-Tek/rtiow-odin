package main

import "core:fmt"
import "core:math/rand"
import "core:time"

@(thread_local)
rng: rand.Rand

main :: proc() {

	// Init random number generator
	rand.init(&rng, u64(time.now()._nsec))

	// World Initialization
	world := init_hit_list()
	defer destroy_hit_list(world)

	add_sphere_to_list(&world, Sphere{Point{0, 0, -1}, 0.5})
	add_sphere_to_list(&world, Sphere{Point{0, -100.5, -1}, 100})

	// Camera initialization
	camera := Camera{}
	init_camera(&camera, 16.0 / 9.0, 400, 100)

	// Run the raytracer
	render_camera(camera, world)
}
