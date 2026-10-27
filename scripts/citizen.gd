extends CharacterBody2D

var freed := false
var rescued := false
var health := 3.0
var target: Node2D
var safe_point := Vector2(420,700)

func _physics_process(_dt: float) -> void:
	if freed and not rescued and is_instance_valid(target):
		var delta := target.position - position
		velocity = delta.normalized() * minf(340, delta.length()*2) if delta.length() > 65 and delta.length() < 800 else Vector2.ZERO
		move_and_slide()
		if position.distance_to(safe_point) < 115: rescued = true
	queue_redraw()

func take_hit(amount: float, _direction := Vector2.ZERO, _charged := false) -> void:
	if freed: return
	health -= amount
	if health <= 0:
		freed = true
		Audio.sfx("collect")
		load("res://scripts/effect.gd").burst(get_parent(), position, 100.0)

func _draw() -> void:
	if not freed:
		draw_colored_polygon(PackedVector2Array([Vector2(-30,32),Vector2(-35,-20),Vector2(0,-52),Vector2(35,-20),Vector2(30,32)]), Color(0.4,0.9,1,0.55))
		draw_polyline(PackedVector2Array([Vector2(-30,32),Vector2(-35,-20),Vector2(0,-52),Vector2(35,-20),Vector2(30,32),Vector2(-30,32)]), Color("b5ffff"),3,true)
	var text := "SAFE" if rescued else ("FOLLOWING • stay close" if freed else "FROZEN • shoot to free")
	draw_string(ThemeDB.fallback_font,Vector2(-110,-65),text,HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("ffdfba"))
