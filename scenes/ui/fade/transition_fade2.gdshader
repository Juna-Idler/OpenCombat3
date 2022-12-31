shader_type canvas_item;

uniform float rate : hint_range(0.0, 1.0, 0.01);
uniform sampler2D rule;
uniform float threshold : hint_range(0.0, 0.5, 0.001) = 0.001;
uniform bool invert = false;


void fragment(){
//	COLOR = vec4(texture(TEXTURE, UV).rgb, texture(rule, UV).r + (rate * 2.0 - 1.0));
	if (0.0 < rate && rate < 1.0)
	{
		float visible = 1.0 - rate;
		float min_visible = max(visible - threshold,0.0);
		float max_visble = min(visible + threshold,1.0);
		float r = texture(rule, UV).r;
		r = invert ? 1.0 - r : r;
		COLOR = vec4(texture(TEXTURE, UV).rgb, smoothstep(min_visible,max_visble,r));
	}
	else
		COLOR = vec4(texture(TEXTURE, UV).rgb, rate);
}
