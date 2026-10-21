shader_type canvas_item;
render_mode unshaded;

uniform sampler2D chroma_texture : filter_linear;
uniform int feed_type = 1;
uniform vec2 uv_x = vec2(1.0, 0.0);
uniform vec2 uv_y = vec2(0.0, 1.0);
uniform vec2 uv_origin = vec2(0.0, 0.0);

void fragment() {
	vec2 camera_uv = uv_origin + uv_x * UV.x + uv_y * UV.y;
	vec3 sample_color = texture(TEXTURE, camera_uv).rgb;
	if (feed_type == 2 || feed_type == 3) {
		vec2 chroma = feed_type == 3 ? texture(chroma_texture, camera_uv).rg : sample_color.gb;
		float cb = chroma.x - 0.5;
		float cr = chroma.y - 0.5;
		sample_color = vec3(sample_color.r + 1.402 * cr,
			sample_color.r - 0.344136 * cb - 0.714136 * cr,
			sample_color.r + 1.772 * cb);
	}
	COLOR = vec4(clamp(sample_color, vec3(0.0), vec3(1.0)), 1.0);
}
