shader_type canvas_item;

uniform float fill = 0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = texture(TEXTURE, UV);
	float angle = atan(0.532 - UV.x, 0.473 - UV.y) + 3.14;
	if (angle < (6.28 * (1. - fill))) {
		COLOR.r = 0.2;
		COLOR.g = 0.2;
		COLOR.b = 0.2;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
