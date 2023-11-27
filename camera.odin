package main

import "core:fmt"
import "core:math"
import "core:math/rand"

Camera :: struct {
	aspect_ratio:                   f64,
	image_width, image_height:      int,
	center, pixel00_loc:            Point,
	pixel_delta_u, pixel_delta_v:   Vec3,
	samples_per_pixel, max_depth:   uint,
	vfov:                           f64,
	look_from, look_at:             Point,
	vup:                            Vec3,
	u, v, w:                        Vec3,
	defocus_angle, focus_dist:      f64,
	defocus_disk_u, defocus_disk_v: Vec3,
}

init_camera :: proc(
	cam: ^Camera,
	aspect_ratio: f64,
	image_width: int,
	samples_per_pixel: uint = 100,
	max_depth: uint = 10,
	fov: f64 = 90,
	look_from: Point = Point{0, 0, -1},
	look_at: Point = Point{0, 0, 0},
	vup: Vec3 = Vec3{0, 1, 0},
	defocus_angle: f64 = 0,
	focus_dist: f64 = 10,
) {
	cam.aspect_ratio = aspect_ratio
	cam.image_width = image_width
	cam.samples_per_pixel = samples_per_pixel
	cam.max_depth = max_depth
	cam.vfov = fov
	cam.look_from = look_from
	cam.look_at = look_at
	cam.vup = vup
	cam.defocus_angle = defocus_angle
	cam.focus_dist = focus_dist

	if height := int(f64(image_width) / aspect_ratio); height >= 1 {
		cam.image_height = height
	} else {
		cam.image_height = 1
	}

	cam.center = look_from

	// Determine viewport dimensions
	focal_length := vec_length(look_from - look_at)
	theta: f64 = math.to_radians(cam.vfov)
	h: f64 = math.tan(theta / 2)
	viewport_height: f64 = 2.0 * h * focus_dist
	viewport_width := viewport_height * f64(cam.image_width) / f64(cam.image_height)

	// Calculate the u,v,w unit basis vectors for the camera coordinate frame
	cam.w = unit(look_from - look_at)
	cam.u = unit(cross(vup, cam.w))
	cam.v = cross(cam.w, cam.u)

	// Calculate the vectors across the horizontal and down the vertical viewport edges.
	viewport_u := viewport_width * cam.u
	viewport_v := viewport_height * cam.v

	// Calculate the horizontal and vertical delta vectors from pixel to pixel
	cam.pixel_delta_u = viewport_u / f64(cam.image_width)
	cam.pixel_delta_v = viewport_v / f64(cam.image_height)

	// Calculate the location of the upper left pixel
	viewport_upper_left := cam.center - focus_dist * cam.w - viewport_u / 2 - viewport_v / 2
	cam.pixel00_loc = viewport_upper_left + 0.5 * (cam.pixel_delta_u + cam.pixel_delta_v)

	// Calculate the camera defocus disk basis vectors
	defocus_radius := focus_dist * math.tan(math.to_radians(defocus_angle / 2))
	cam.defocus_disk_u = cam.u * defocus_radius
	cam.defocus_disk_v = cam.v * defocus_radius
}

render_camera :: proc(using camera: Camera, world: Hittable_List) {
	fmt.printf("P3\n%d %d\n255\n", image_width, image_height, flush = false)

	pixel_color: Color
	r: Ray

	for j in 0 ..< image_height {
		fmt.eprintf("\rScanlines remaining: %d ", image_height - j)
		for i in 0 ..< image_width {
			pixel_color = Color{0, 0, 0}
			for sample in 0 ..< samples_per_pixel {
				r := get_ray(camera, i, j)
				pixel_color += ray_color(r, max_depth, world)
			}

			pixel_color *= 1 / f64(samples_per_pixel)
			pixel_color.r = linear_to_gamma(pixel_color.r)
			pixel_color.g = linear_to_gamma(pixel_color.g)
			pixel_color.b = linear_to_gamma(pixel_color.b)

			intensity := Interval{0, 0.999}
			clamped := clamp_vec(pixel_color, intensity)
			clamped *= 255

			fmt.printf("%.0f %.0f %.0f\n", clamped.r, clamped.g, clamped.b)
		}
	}

	fmt.eprintf("\rDone                         \n")
}

get_ray :: #force_inline proc(using camera: Camera, i, j: int) -> Ray {
	// Get a randomly sampled camera ray for the pixel at location i, j.
	pixel_center := pixel00_loc + (f64(i) * pixel_delta_u) + (f64(j) * pixel_delta_v)
	pixel_sample := pixel_center + pixel_sample_square(pixel_delta_u, pixel_delta_v)

	ray_origin := defocus_angle <= 0 ? center : defocus_disk_sample(camera)
	ray_direction := pixel_sample - ray_origin

	return Ray{ray_origin, ray_direction}
}

defocus_disk_sample :: #force_inline proc(using camera: Camera) -> Vec3 {
	p := random_vec_in_unit_disk()
	return center + (p[0] * defocus_disk_u) + (p[1] * defocus_disk_v)
}

pixel_sample_square :: #force_inline proc(delta_u, delta_y: Vec3) -> Vec3 {
	px := -0.5 + rand.float64(&rng)
	py := -0.5 + rand.float64(&rng)
	return px * delta_u + py * delta_y
}

ray_color :: proc(r: Ray, depth: uint, world: Hittable_List) -> Color {
	if depth <= 0 {
		return Color{}
	}

	if rec, ok := hit_list(world, r, Interval{0.001, math.INF_F64}); ok {
		if attenuation, scattered, bounced := scatter(rec.mat, r, rec); bounced {
			return attenuation * ray_color(scattered, depth - 1, world)
		}
		return Color{}
	}

	unit_direction := unit(r.direction)
	a := 0.5 * (unit_direction.y + 1.0)
	white := Color{1, 1, 1}
	blue := Color{0.5, 0.7, 1.0}

	return white * (1 - a) + blue * a
}
