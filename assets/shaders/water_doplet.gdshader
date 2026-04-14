shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.4, 0.7, 1.0, 0.3);
uniform float roughness : hint_range(0.0, 1.0) = 0.05;
uniform float metallic : hint_range(0.0, 1.0) = 0.1;
uniform float refraction_strength : hint_range(0.0, 1.0) = 0.05;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	// 1. Fresnel Effect (Outer glow/reflection)
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	
	// 2. Refraction Logic
	// We offset the screen UVs by the Normal to "bend" the background light
	vec2 refracted_uv = SCREEN_UV + (NORMAL.xy * refraction_strength);
	vec3 background_color = texture(screen_texture, refracted_uv).rgb;
	
	// 3. Combine Colors
	// We blend the refracted background with our base water tint
	vec3 final_color = mix(background_color, base_color.rgb, base_color.a);
	
	ALBEDO = final_color * COLOR.rgb; // Incorporate particle gradient
	
	// 4. Physical Properties
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = 0.8;
	
	// 5. High-Intensity Highlights (Rim)
	// This makes the edges of the drop "glisten"
	EMISSION = base_color.rgb * fresnel * 1.5;
	
	// Keep the drop semi-transparent, but thicker at the edges
	ALPHA = clamp(base_color.a + fresnel, 0.0, 1.0) * COLOR.a;
}