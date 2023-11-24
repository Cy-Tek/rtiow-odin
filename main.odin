package main

import "core:fmt"
import "types/vec"
import "types/ray"

Ray :: ray.Ray
Point :: vec.Point
Vec :: vec.Vec3
Color :: vec.Color

main :: proc() {
	fmt.set_user_formatters(new(map[typeid]fmt.User_Formatter))
	fmt.register_user_formatter(typeid_of(Color), vec.Color_Formatter)

	aspect_ratio := 16.0 / 9.0
	image_width := 400

	image_height := int(f64(image_width) / aspect_ratio)
	image_height = 1 if image_height < 1 else image_height

	focal_length := 1.0
	viewport_height := 2.0
	viewport_width := viewport_height * f64(image_width) / f64(image_height)
	camera_center := Point{0, 0, 0}
	
	// Calculate the vectors across the horizontal and down the vertical viewport edges
	viewport_u := Vec{viewport_width, 0, 0}
	viewport_v := Vec{0, -viewport_height, 0}

	// Calculate the horizontal and vertical delta vectors from pixel to pixel
	pixel_delta_u := viewport_u / f64(image_width)
	pixel_delta_v := viewport_v / f64(image_height)
	
	// Calculate the location of the upper left pixel
	viewport_upper_left := camera_center - Vec{0, 0, focal_length} - viewport_u / 2 - viewport_v / 2
	pixel00_loc := viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v)
	
	fmt.printf("P3\n%d %d\n255\n", image_width, image_height, flush = false)

	for j in 0 ..< image_height {
		fmt.eprintf("\rScanlines remaining: %d ", image_height - j)
		for i in 0 ..< image_width {
			pixel_center := pixel00_loc + (f64(i) * pixel_delta_u) + (f64(j) * pixel_delta_v)
			ray_direction := pixel_center - camera_center
			r := Ray{origin = camera_center, direction = ray_direction}

			pixel_color := ray_color(r)
			fmt.print(pixel_color, "\n", flush = false)
		}
	}

	fmt.eprintf("\rDone                         \n")
}

hit_sphere :: proc(center: Point, radius: f64, r: Ray) -> bool {
	oc := r.origin - center
	a := vec.length_squared(r.direction)
	b := 2 * vec.dot(oc, r.direction)
	c := vec.length_squared(oc) - radius * radius
	discriminant := b * b - 4 * a * c
	
	return discriminant >= 0
}

ray_color :: proc(r: Ray) -> Color {
	if hit_sphere(Point{0, 0, -1}, 0.5, r) {
		return Color{1, 0, 0}
	}

	unit_direction := vec.unit(r.direction)
	a := 0.5 * (unit_direction.y + 1.0)
	white := vec.Color{1, 1, 1}
	blue := vec.Color{0.5, 0.7, 1.0}

	return white * (1-a) + blue * a
}