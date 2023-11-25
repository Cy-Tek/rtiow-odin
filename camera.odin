package main

import "core:fmt"
import "core:math"

Camera :: struct {
	aspect_ratio:                 f64,
	image_width, image_height:    int,
	center, pixel00_loc:          Point,
	pixel_delta_u, pixel_delta_v: Vec3,
}

init_camera :: proc(using camera: ^Camera, new_aspect_ratio: f64, new_image_width: int) {
	aspect_ratio = aspect_ratio
	image_width = image_width

	if height := int(f64(image_width) / aspect_ratio); height >= 1 {
		image_height = height
	} else {
		image_height = 1
	}

	// Determine viewport dimensions
	focal_length := 1.0
	viewport_height := 2.0
	viewport_width := viewport_height * f64(image_width) / f64(image_height)

	// Calculate the vectors across the horizontal and down the vertical viewport edges.
	viewport_u := Vec3{viewport_width, 0, 0}
	viewport_v := Vec3{0, -viewport_height, 0}

	// Calculate the horizontal and vertical delta vectors from pixel to pixel
	pixel_delta_u = viewport_u / f64(image_width)
	pixel_delta_v = viewport_v / f64(image_height)


	// Calculate the location of the upper left pixel
	viewport_upper_left := center - Vec3{0, 0, focal_length} - viewport_u / 2 - viewport_v / 2
	pixel00_loc = viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v)
}

render_camera :: proc(using camera: Camera, world: Hittable_List) {
	fmt.printf("P3\n%d %d\n255\n", image_width, image_height, flush = false)

	for j in 0 ..< image_height {
		fmt.eprintf("\rScanlines remaining: %d ", image_height - j)
		for i in 0 ..< image_width {
			pixel_center := pixel00_loc + (f64(i) * pixel_delta_u) + (f64(j) * pixel_delta_v)
			ray_direction := pixel_center - center
			r := Ray {
				origin    = center,
				direction = ray_direction,
			}

			pixel_color := ray_color(r, world)
			fmt.print(pixel_color, "\n", flush = false)
		}
	}

	fmt.eprintf("\rDone                         \n")
}

ray_color :: proc(r: Ray, world: Hittable_List) -> Color {
	if rec, ok := hit_list(world, r, Interval{0, math.INF_F64}); ok {
		return 0.5 * (rec.normal + Color{1, 1, 1})
	}

	unit_direction := unit(r.direction)
	a := 0.5 * (unit_direction.y + 1.0)
	white := Color{1, 1, 1}
	blue := Color{0.5, 0.7, 1.0}

	return white * (1 - a) + blue * a
}
