shader_type canvas_item;

//Squishy vertex shader
uniform vec2 sprite_size = vec2(8.0, 8.0);
uniform float squash_amount = 7.0;
uniform float speed = 1.0;

void vertex() {
	VERTEX.y += (UV.y - 0.5) * (cos(TIME * speed)) * (sprite_size.y / squash_amount);
	VERTEX.x += (UV.x - 0.5) * (sin(TIME * speed)) * (sprite_size.x / squash_amount);
}