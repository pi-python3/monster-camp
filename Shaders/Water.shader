shader_type canvas_item;

uniform vec2 offset_scale = vec2(2.0, 2.0);
uniform vec2 tile_factor = vec2(5.0, 5.0);
uniform float aspect_ratio = 0.5;

uniform float time_scale = 1.0;
uniform vec2 amplitude = vec2(0.05, 0.1);

void fragment() {
	vec2 tiled_uvs = UV * tile_factor;
	
	vec2 wave_uv_offset;
	wave_uv_offset.x = cos(TIME * time_scale + (tiled_uvs.x + tiled_uvs.y) * offset_scale.x);
	wave_uv_offset.y = sin(TIME + (tiled_uvs.x + tiled_uvs.y) * offset_scale.y);
	
	tiled_uvs.y *= aspect_ratio;
	
	COLOR = texture(TEXTURE, tiled_uvs + (wave_uv_offset * amplitude));
}