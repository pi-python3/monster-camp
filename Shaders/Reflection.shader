shader_type canvas_item;

void fragment() {
	float uv_height = SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y;
	vec2 reflected_screen_uv = vec2(SCREEN_UV.x, SCREEN_UV.y + uv_height * UV.y * 2.0);
	
	COLOR = texture(SCREEN_TEXTURE, reflected_screen_uv);
}