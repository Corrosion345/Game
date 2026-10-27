extends Node2D

const WALLS := [Rect2(0, 0, 2800, 45), Rect2(0, 1755, 2800, 45), Rect2(0, 0, 45, 1800), Rect2(2755, 0, 45, 1800), Rect2(1070, 600, 220, 180), Rect2(1750, 1000, 230, 180)]
var clock := 0.0

func _ready() -> void:
	for rect in WALLS:
		var body := StaticBody2D.new()
		var col := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		col.shape = shape
		body.position = rect.get_center()
		body.add_child(col)
		add_child(body)

func _process(dt: float) -> void:
	clock += dt
	queue_redraw()

func surface_at(pos: Vector2) -> String:
	if Rect2(80, 1300, 700, 400).has_point(pos): return "snow"
	if Rect2(2050, 100, 650, 400).has_point(pos): return "pavement"
	return "ice"

func _draw() -> void:
	draw_rect(Rect2(0, 0, 2800, 1800), Color("142c49"))
	for x in range(80, 2800, 120):
		draw_line(Vector2(x, 50), Vector2(x, 1750), Color(0.3, 0.8, 1, 0.06), 2)
	for y in range(80, 1800, 120):
		draw_line(Vector2(50, y), Vector2(2750, y), Color(0.3, 0.8, 1, 0.06), 2)
	draw_rect(Rect2(80, 1300, 700, 400), Color("a3c8df"))
	draw_rect(Rect2(2050, 100, 650, 400), Color("383950"))
	for i in range(18):
		var pos := Vector2(150 + i * 147, 240 + (i * 211) % 1400)
		draw_line(pos, pos + Vector2(90, -25), Color(0.6, 0.9, 1, 0.13), 3)
	for rect in WALLS:
		draw_rect(rect.grow(9), Color("13152d"))
		draw_rect(rect, Color("324469"))
		draw_rect(rect, Color("65e7ff"), false, 3)
	for i in range(70):
		var pos := Vector2(fmod(i * 397.0 + clock * 18, 2800), fmod(i * 271.0 + clock * 38, 1800))
		draw_circle(pos, 1.5 + i % 3, Color(0.8, 0.95, 1, 0.35))
	draw_string(ThemeDB.fallback_font, Vector2(280, 340), "NEON FROST / PRACTICE RINK", HORIZONTAL_ALIGNMENT_LEFT, -1, 38, Color("72f5ff"))
	draw_string(ThemeDB.fallback_font, Vector2(140, 1380), "SNOW / HIGH FRICTION", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("24384e"))
	draw_string(ThemeDB.fallback_font, Vector2(2110, 200), "PAVEMENT", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("ffb9eb"))
