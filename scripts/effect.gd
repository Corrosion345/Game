extends Node2D

var color := Color("8ff9ff")
var radius := 70.0
var age := 0.0
var duration := 0.45

func _process(dt: float) -> void:
	age += dt
	queue_redraw()
	if age >= duration: queue_free()

func _draw() -> void:
	var t := clampf(age / duration, 0, 0.999)
	draw_arc(Vector2.ZERO, radius * t, 0, TAU, 48, Color(color, 1.0-t), 5 * (1.0-t), true)
	for i in range(10):
		var direction := Vector2.from_angle(i * TAU / 10)
		draw_line(direction * radius * t * 0.7, direction * radius * t, Color(color, 1.0-t), 3, true)

static func burst(parent: Node, pos: Vector2, size := 70.0, tint := Color("8ff9ff")) -> void:
	var effect = load("res://scripts/effect.gd").new()
	effect.position = pos
	effect.radius = size
	effect.color = tint
	parent.add_child(effect)
