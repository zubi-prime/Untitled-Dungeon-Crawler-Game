shader_type canvas_item;

uniform float whiteFlash = 0.;
uniform vec4 modulate = vec4(1,1,1,1);

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color *= modulate;
	color += vec4(whiteFlash, whiteFlash, whiteFlash, 0);
	COLOR = color;
}
