shader_type canvas_item;

// The mask is generated in map-local coordinates, so camera pan/zoom never
// changes the meaning of a pixel in the reveal texture.
uniform sampler2D reveal_mask : filter_linear, repeat_disable;
uniform vec2 map_origin = vec2(-2048.0, -2048.0);
uniform vec2 map_size = vec2(4096.0, 4096.0);
uniform vec2 map_offset = vec2(0.0);
uniform vec2 viewport_size = vec2(432.0, 470.0);
uniform float map_zoom = 1.0;
uniform float enabled = 1.0;

void fragment() {
	vec2 screen_position = UV * viewport_size;
	vec2 map_position = (screen_position - map_offset) / max(map_zoom, 0.0001);
	vec2 map_uv = (map_position - map_origin) / map_size;
	float reveal = 0.0;
	if (map_uv.x >= 0.0 && map_uv.x <= 1.0 && map_uv.y >= 0.0 && map_uv.y <= 1.0) {
		reveal = texture(reveal_mask, map_uv).r;
	}
	float alpha = enabled * (1.0 - reveal);
	COLOR = vec4(0.008, 0.012, 0.018, alpha);
}
