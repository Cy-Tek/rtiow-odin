package main

import "core:fmt"
import "core:math/rand"
import "core:time"

@(thread_local)
rng: rand.Rand

@(init)
init_rand :: proc() {
	rand.init(&rng, u64(time.now()._nsec))
}

main :: proc() {
	// World Initialization
	world := init_hit_list()
	defer destroy_hit_list(world)

	material_ground: Material = Lambertian{Color{0.8, 0.8, 0.0}}
	material_center: Material = Lambertian{Color{0.7, 0.3, 03}}
	material_left: Material = Metal{Color{0.8, 0.8, 0.8}}
	material_right: Material = Metal{Color{0.8, 0.6, 0.2}}

	add_sphere_to_list(&world, Sphere{Point{0, -100.5, -1}, 100, material_ground})
	add_sphere_to_list(&world, Sphere{Point{0, 0, -1}, 0.5, material_center})
	add_sphere_to_list(&world, Sphere{Point{-1, 0, -1}, 0.5, material_left})
	add_sphere_to_list(&world, Sphere{Point{1, 0, -1}, 0.5, material_right})

	// Camera initialization
	camera := Camera{}
	init_camera(
		&camera,
		aspect_ratio = 16.0 / 9.0,
		image_width = 400,
		samples_per_pixel = 100,
		max_depth = 50,
	)

	// Run the raytracer
	render_camera(camera, world)
}
