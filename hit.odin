package main

Hit_Record :: struct {
	point:      Point,
	normal:     Vec3,
	t:          f64,
	mat:        Material,
	front_face: bool,
}

hit_rec_set_face_normal :: proc(record: ^Hit_Record, r: Ray, outward_normal: Vec3) {
	record.front_face = dot(r.direction, outward_normal) < 0
	record.normal = record.front_face ? outward_normal : -outward_normal
}

Hittable_List :: struct {
	spheres: [dynamic]Sphere,
}

init_hit_list :: proc() -> Hittable_List {
	spheres := make([dynamic]Sphere, 0, 10)
	return Hittable_List{spheres}
}

destroy_hit_list :: proc(list: Hittable_List) {
	delete(list.spheres)
}

clear_hit_list :: proc(list: ^Hittable_List) {
	clear(&list.spheres)
}

add_sphere_to_list :: proc(list: ^Hittable_List, sphere: Sphere) {
	append(&list.spheres, sphere)
}

hit_list :: proc(
	list: Hittable_List,
	r: Ray,
	ray_t: Interval,
) -> (
	out_rec: Hit_Record,
	found_hit: bool,
) {
	found_hit = false
	closest_so_far := ray_t.max

	for sphere in list.spheres {
		if rec, hit := hit_sphere(sphere, r, Interval{ray_t.min, closest_so_far}); hit {
			found_hit = true
			closest_so_far = rec.t
			out_rec = rec
		}
	}

	return
}
