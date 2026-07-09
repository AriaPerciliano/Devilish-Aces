shader_type spatial;
render_mode blend_mix,
	cull_back,
	depth_prepass_alpha,
	shadows_disabled,
	specular_disabled,
	vertex_lighting;

uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D albedo_texture : filter_nearest_mipmap;
uniform vec2 texture_tile = vec2(1, 1);

uniform bool snap_enabled = true;
uniform float snap_resolution : hint_range(60.0, 480.0, 1.0) = 148.0;

void vertex() {
	vec4 view_space_pos = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec4 clip_space_pos = PROJECTION_MATRIX * view_space_pos;

	if (snap_enabled) {
		vec2 ndc = clip_space_pos.xy / clip_space_pos.w;
		ndc = round(ndc * snap_resolution) / snap_resolution;
		clip_space_pos.xy = ndc * clip_space_pos.w;
	}

	POSITION = clip_space_pos;
}

void fragment() {
	vec4 albedo_tex = texture(albedo_texture, UV * texture_tile);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
}