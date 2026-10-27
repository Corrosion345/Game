extends Node2D

var velocity := Vector2.ZERO
var damage := 1.0
var hostile := false
var lifetime := 2.2
var near_missed := false
var previous := Vector2.ZERO

func _ready() -> void:
	add_to_group("hostile_bullets" if hostile else "ice_bullets")

func _physics_process(dt: float) -> void:
	lifetime -= dt
	if lifetime <= 0: queue_free(); return
	previous = global_position
	var next := global_position + velocity * dt
	var query := PhysicsRayQueryParameters2D.create(global_position, next, 1 | (2 if hostile else 4))
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var target = hit["collider"]
		if target.has_method("take_hit"):
			if hostile: target.take_hit(damage)
			else: target.take_hit(damage, velocity.normalized(), false)
		load("res://scripts/effect.gd").burst(get_parent(), hit["position"], 35.0, Color("ff75be") if hostile else Color("7df8ff"))
		queue_free()
		return
	global_position = next
	queue_redraw()

func _draw() -> void:
	var c := Color("ff65b3") if hostile else Color("86ffff")
	var tail := -velocity.normalized() * 26
	draw_line(tail, Vector2.ZERO, Color(c, 0.25), 15, true)
	draw_line(tail, Vector2.ZERO, c, 5, true)
	draw_colored_polygon(PackedVector2Array([Vector2(10,0),Vector2(0,-5),Vector2(-8,0),Vector2(0,5)]), Color.WHITE)
