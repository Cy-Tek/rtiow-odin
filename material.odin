package main

Material :: union {
	Metal,
	Lambertian,
}

scatter :: proc(
	mat: Material,
	r_in: Ray,
	rec: Hit_Record,
) -> (
	attenuation: Color,
	scattered: Ray,
	bounced: bool,
) {
	switch m in mat {
	case Metal:
		return scatter_metal(m, r_in, rec)
	case Lambertian:
		return scatter_lambertian(m, r_in, rec)
	}

	return
}

// Metal material

Metal :: struct {
	albedo: Color,
}

scatter_metal :: proc(
	m: Metal,
	r_in: Ray,
	rec: Hit_Record,
) -> (
	attenuation: Color,
	scattered: Ray,
	bounced: bool,
) {
	reflected := reflect_vec(unit(r_in.direction), rec.normal)
	scattered = Ray{rec.point, reflected}
	attenuation = m.albedo
	bounced = true
	return
}

// Lambertan material

Lambertian :: struct {
	albedo: Color,
}

scatter_lambertian :: proc(
	l: Lambertian,
	r_in: Ray,
	rec: Hit_Record,
) -> (
	attenuation: Color,
	scattered: Ray,
	bounced: bool,
) {
	scatter_direction := rec.normal + random_unit_vec()
	if vec_near_zero(scatter_direction) {
		scatter_direction = rec.normal
	}

	scattered = Ray{rec.point, scatter_direction}
	attenuation = l.albedo
	bounced = true
	return
}
