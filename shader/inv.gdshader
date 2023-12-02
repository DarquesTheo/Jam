shader_type spatial;

uniform vec4 _color : source_color;
uniform float sphere_size = 3.0;
global uniform vec3 player_pos;

varying vec3 world_vertex;

void vertex() {
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float min_dist = min(length(player_pos - world_vertex), sphere_size);
	
	ALBEDO = _color.rgb;
	ALPHA = clamp(sphere_size - min_dist, 0.0, 1.0);
}

void light() {
	// Called for every pixel for every light affecting the material.
}
