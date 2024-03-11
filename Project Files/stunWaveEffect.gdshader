shader_type canvas_item;

uniform sampler2D backBufferCopy : hint_screen_texture, filter_nearest;
uniform float dist;
uniform float width;
uniform float offset;

uniform vec2 screenSize;
uniform vec2 playerPos;

void fragment() {
	
	vec2 pos = (UV * screenSize) - playerPos;
	
	if ((length(pos) < dist) && (length(pos) > dist - width)) {
		pos -= (normalize(pos) * offset);
		vec2 newUv = (pos + playerPos) / screenSize;
		float flashStrength = 1.2 + (.8 / (dist / 800.));
		COLOR = texture(backBufferCopy, newUv) * vec4(flashStrength,flashStrength,flashStrength,1.);
	} else {
		COLOR = texture(backBufferCopy, UV);
	}
}