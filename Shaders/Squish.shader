shader_type canvas_item;

//Squishy vertex shader
uniform vec2 sprite_size = vec2(8.0, 8.0);
uniform float squash_amount = 7.0;
uniform float speed = 1.0;

void vertex() {
	VERTEX.y += (UV.y - 0.5) * abs(cos(TIME * speed)) * (sprite_size.y / squash_amount);
	VERTEX.x += (UV.x - 0.5) * 2.0 * abs(sin(TIME * speed)) * (sprite_size.x / squash_amount);
}

/*
uniform float width: hint_range(0.0, 30.0);
uniform vec4 outline_color: hint_color;

void fragment() {
	float size = width * 1.0 / float(textureSize(TEXTURE, 0).x);
	vec4 sprite_color = texture(TEXTURE, UV);
	float alpha = -4.0 * sprite_color.a;
	
	alpha += texture(TEXTURE, UV + vec2(size, 0)).a;
	alpha += texture(TEXTURE, UV + vec2(-size, 0)).a;
	alpha += texture(TEXTURE, UV + vec2(0.0, size)).a;
	alpha += texture(TEXTURE, UV + vec2(0.0, -size)).a;
	
	vec4 final_color = mix(sprite_color, outline_color, clamp(alpha, 0.0, 1.0));
	COLOR = vec4(final_color.rgb, clamp( abs(alpha) + sprite_color.a, 0.0, 1.0 ));
}
*/