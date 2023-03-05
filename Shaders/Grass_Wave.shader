shader_type canvas_item;

//Squishy vertex shader
uniform vec2 sprite_size = vec2(8.0, 8.0);
uniform float squash_amount = 7.0;
uniform float speed = 1.0;

void vertex() {
	VERTEX.x += (1.0 - UV.y) * sin(TIME * speed) * (sprite_size.y / squash_amount);
}