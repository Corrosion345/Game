shader_type canvas_item;
void fragment() {
 vec2 p = UV;
 float bands = pow(max(0.0, sin((p.x + p.y * 0.6) * 65.0 + TIME * 0.5)), 35.0);
 float grid = step(0.985, fract(p.x * 24.0)) + step(0.985, fract(p.y * 16.0));
 vec3 col = mix(vec3(0.045,0.095,0.19), vec3(0.10,0.23,0.33), p.y);
 col += bands * vec3(0.035,0.07,0.09) + grid * vec3(0.012,0.023,0.028);
 COLOR = vec4(col,1.0);
}
