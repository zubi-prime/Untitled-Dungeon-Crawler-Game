shader_type canvas_item;

uniform float whiteFlash;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR += vec4(whiteFlash, whiteFlash, whiteFlash, 0.);
}
