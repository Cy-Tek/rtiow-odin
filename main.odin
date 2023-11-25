package main

import "core:fmt"

main :: proc() {
	fmt.set_user_formatters(new(map[typeid]fmt.User_Formatter))
	fmt.register_user_formatter(typeid_of(Color), Color_Formatter)

	// World Initialization
	world := init_hit_list()
	defer destroy_hit_list(world)

	add_sphere_to_list(&world, Sphere{Point{0, 0, -1}, 0.5})
	add_sphere_to_list(&world, Sphere{Point{0, -100.5, -1}, 100})

	// Camera initialization
	camera := Camera{}
	init_camera(&camera, 16.0 / 9.0, 400)

	// Run the raytracer
	render_camera(camera, world)
}
