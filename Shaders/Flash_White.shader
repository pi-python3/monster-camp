shader_type canvas_item;

void fragment() {
	vec4 text = textureLod(TEXTURE, UV, 0.0);
	COLOR = vec4(1,1,1,text.a);
}