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
	material_center: Material = Lambertian{Color{0.7, 0.3, 0.3}}
	material_left: Material = Metal{Color{0.8, 0.8, 0.8}, 0.3}
	material_right: Material = Metal{Color{0.8, 0.6, 0.2}, 1.0}

	spheres := [?]Sphere {
		Sphere{Point{0, -100.5, -1}, 100, material_ground},
		Sphere{Point{0, 0, -1}, 0.5, material_center},
		Sphere{Point{-1, 0, -1}, 0.5, material_left},
		Sphere{Point{1, 0, -1}, 0.5, material_right},
	}

	for sphere in spheres {
		add_sphere_to_list(&world, sphere)
	}

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
