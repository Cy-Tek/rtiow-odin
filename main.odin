package main

import "core:fmt"
import "core:math"
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
	add_sphere_to_list(&world, Sphere{Point{0, -1000, 0}, 1000, material_ground})

	for a in -11 ..< 11 {
		for b in -11 ..< 11 {
			choose_mat := rand.float64()
			center := Point{f64(a) + 0.9 * rand.float64(), 0.2, f64(b) + 0.9 * rand.float64()}

			if vec_length(center - Point{4, 0.2, 0}) > 0.9 {
				sphere_material: Material

				switch {
				case choose_mat < 0.8:
					albedo := random_vec() * random_vec()
					sphere_material = Lambertian{albedo}
				case choose_mat < 0.95:
					// metal
					albedo := random_vec_in_range(0.5, 1)
					fuzz := rand.float64_range(0, 0.5)
					sphere_material = Metal{albedo, fuzz}
				case:
					// dielectric
					sphere_material = Dielectric{1.5}
				}

				add_sphere_to_list(&world, Sphere{center, 0.2, sphere_material})
			}
		}
	}

	material_1 := Dielectric{1.5}
	add_sphere_to_list(&world, Sphere{Point{0, 1, 0}, 1.0, material_1})

	material_2 := Lambertian{Color{0.4, 0.2, 0.1}}
	add_sphere_to_list(&world, Sphere{Point{-4, 1, 0}, 1.0, material_2})

	material_3 := Metal{Color{0.7, 0.6, 0.5}, 0.0}
	add_sphere_to_list(&world, Sphere{Point{4, 1, 0}, 1.0, material_3})

	// Camera initialization
	camera := Camera{}
	init_camera(
		&camera,
		aspect_ratio = 16.0 / 9.0,
		image_width = 800,
		samples_per_pixel = 300,
		max_depth = 50,
		fov = 20,
		look_from = Point{13, 2, 3},
		look_at = Point{0, 0, 0},
		vup = Vec3{0, -1, 0},
		defocus_angle = 0.6,
		focus_dist = 10,
	)

	// Run the raytracer
	render_camera(camera, world)
}
