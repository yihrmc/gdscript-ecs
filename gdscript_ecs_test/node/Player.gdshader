// Hey this is Hei! This shader "fakes" a 3D-camera perspective on CanvasItems.
// Known limitations:
// - Yaw doesn't work as intended with non-square images.
// License: MIT


shader_type canvas_item;

// Camera FOV (half) in radians
// You can also consider pre-calculating "0.5 / tan(fov)"
uniform float fov = 0.785398;
// How far the image plane is from camera
uniform float plane_distance = 1.0;

uniform float yaw : hint_range(-1.57, 1.57) = 0.0;
uniform float pitch : hint_range(-1.57, 1.57) = 0.0;
uniform float roll : hint_range(-1.57, 1.57) = 0.0;

// Consider changing this to a uniform and change it from code
varying mat3 rotmat;

// Creates rotation matrix
void vertex(){
	float cos_a = cos(yaw);
	float sin_a = sin(yaw);
	float sin_b = sin(pitch);
	float cos_b = cos(pitch);
	float sin_c = sin(roll);
	float cos_c = cos(roll);

	rotmat[0][0] = cos_a * cos_b;
	rotmat[0][1] = cos_a * sin_b * sin_c - sin_a * cos_c;
	rotmat[0][2] = cos_a * sin_b * cos_c + sin_a * sin_c;

	rotmat[1][0] = sin_a * cos_b;
	rotmat[1][1] = sin_a * sin_b * sin_c + cos_a * cos_c;
	rotmat[1][2] = sin_a * sin_b * cos_c - cos_a * sin_c;

	rotmat[2][0] = -sin_b;
	rotmat[2][1] = cos_b * sin_c;
	rotmat[2][2] = cos_b * cos_c;
}

// Projects UV to an imaginary plane; I barely have clue myself how it works.
void fragment(){
	vec3 from = vec3(0, 0, -plane_distance);
	vec3 normal = rotmat * vec3(0.0, 0.0, 1.0);
	vec3 segment = normalize(vec3(UV - 0.5, 0.5 / tan(fov)));
	float dist = -dot(normal, from) / dot(normal, segment);
	vec3 intersection = from + segment * dist;
	vec2 uv = (inverse(rotmat) * intersection).xy + 0.5;
	if (any(greaterThan(abs(uv - 0.5), vec2(0.5)))) discard;
	COLOR = texture(TEXTURE, uv);
}
