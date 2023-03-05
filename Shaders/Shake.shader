shader_type canvas_item;

uniform float amplitude = 1.0;
uniform float frequency = 20.0;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void vertex() {
	VERTEX += vec2(sin(TIME*frequency), cos(TIME*frequency)) * amplitude;
}