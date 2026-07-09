shader_type canvas_item;

uniform float radius : hint_range(0.0, 100.0) = 16.0;
uniform vec2 mask_screen_center  = vec2(500.0, 300.0);
uniform vec2 node_size = vec2(100.0, 100.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float dist = distance(FRAGCOORD.xy, mask_screen_center);
	
	if (dist > radius) {
		tex_color.a = 0.0;
	}
	
	COLOR = tex_color;
}