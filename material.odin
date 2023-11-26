package main

import "core:math"
import "core:math/rand"

Material :: union {
	Metal,
	Lambertian,
	Dielectric,
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
	case Dielectric:
		return scatter_dielectric(m, r_in, rec)
	case:
		return
	}
}

// Metal material

Metal :: struct {
	albedo: Color,
	fuzz:   f64,
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
	scattered = Ray{rec.point, reflected + m.fuzz * random_unit_vec()}
	attenuation = m.albedo
	bounced = dot(scattered.direction, rec.normal) > 0
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

// Dielectric material

Dielectric :: struct {
	ior: f64, // Index of Refraction
}

reflectance :: proc(cosine, ref_idx: f64) -> f64 {
	// Use Schlick's approximation for reflectance
	r0 := (1 - ref_idx) / (1 + ref_idx)
	r0 *= r0
	return r0 + (1 - r0) * math.pow(1 - cosine, 0.5)
}

scatter_dielectric :: proc(
	d: Dielectric,
	r_in: Ray,
	rec: Hit_Record,
) -> (
	attenuation: Color,
	scattered: Ray,
	bounced: bool,
) {
	attenuation = Vec3{1, 1, 1}
	refraction_ratio: f64 = rec.front_face ? 1 / d.ior : d.ior

	unit_direction := unit(r_in.direction)
	cos_theta: f64 = min(dot(negate_vec(unit_direction), rec.normal), 1.0)
	sin_theta: f64 = math.sqrt(1.0 - cos_theta * cos_theta)

	cannot_refract := refraction_ratio * sin_theta > 1.0
	direction: Vec3

	if cannot_refract || reflectance(cos_theta, refraction_ratio) > rand.float64() {
		direction = reflect_vec(unit_direction, rec.normal)
	} else {
		direction = refract_vec(unit_direction, rec.normal, refraction_ratio)
	}

	scattered = Ray{rec.point, direction}
	bounced = true

	return
}
