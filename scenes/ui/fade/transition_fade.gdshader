shader_type canvas_item;

uniform float rate : hint_range(0.0, 1.0, 0.01);
uniform sampler2D rule;
uniform bool invert = false;

void fragment(){
	//ruleのrateをredから持ってくるのでr
	float r = texture(rule, UV).r;
	r = invert ? 1.0 - r : r;
	COLOR = vec4(texture(TEXTURE, UV).rgb, r + (rate * 2.0 - 1.0));
}
