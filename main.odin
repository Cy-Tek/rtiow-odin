package main

import "core:fmt"
import "types"

IMAGE_WIDTH :: 256
IMAGE_HEIGHT :: 256

main :: proc() {
	using types
	fmt.set_user_formatters(new(map[typeid]fmt.User_Formatter))
	fmt.register_user_formatter(type_info_of(Color).id, Color_Formatter)
	
	aspect_ratio := 16.0 / 9.0
	image_width := 400

	image_height := int(f64(image_width) / aspect_ratio)
	image_height = 1 if image_height < 1 else image_height

	viewport_height := 2.0
	viewport_width := viewport_height * f64(image_width) / f64(image_height)

	fmt.printf("P3\n%d %d\n255\n", IMAGE_WIDTH, IMAGE_HEIGHT, flush = false)

	for j in 0 ..< IMAGE_HEIGHT {
		fmt.eprintf("\rScanlines remaining: %d ", IMAGE_HEIGHT - j)

		for i in 0 ..< IMAGE_WIDTH {
			color := Color{
				f64(i) / (IMAGE_WIDTH - 1),
				f64(j) / (IMAGE_HEIGHT - 1),
				0.0,
			}

			fmt.print(color, flush = false)
		}
	}

	fmt.eprintf("\rDone                         \n")
}
