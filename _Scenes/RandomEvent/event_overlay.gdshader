shader_type canvas_item;

uniform vec3 _VignetteColor : source_color = vec3(0.5, 0.15, 0.156);
uniform float _VignetteAlpha : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float _VignetteDarken : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float _VignetteFalloff : hint_range(1.0, 5.0, 0.01) = 1.0;
uniform float _VignetteFalloffIncrease : hint_range(0.0, 5.0, 0.01) = 0.0;
uniform float _VignetteStrength : hint_range(1.0, 5.0, 0.01) = 1.0;

void fragment() {
	float distance_from_center = distance(vec2(0.5, 0.5), UV);
	float falloff = _VignetteFalloff - (_VignetteFalloffIncrease * _VignetteAlpha);
	float alpha = pow(distance_from_center, falloff);
	alpha *= _VignetteStrength;
	
	COLOR = vec4(_VignetteColor * (1.0 - _VignetteDarken * alpha), min(alpha, _VignetteAlpha));
}