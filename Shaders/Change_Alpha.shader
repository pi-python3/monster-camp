shader_type canvas_item;

uniform float set_alpha = 0.5;

void fragment() {
	vec4 text = textureLod(TEXTURE, UV, 0.0);
	float alpha = set_alpha;
	
	if (text.r + text.g + text.b <= 0.2) {
		alpha = 0.0;
	}

	COLOR = vec4(text.r,text.g,text.b, alpha);
}