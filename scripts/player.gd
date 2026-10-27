class_name IceSkater
extends CharacterBody2D

var surface := "ice"
var facing := Vector2.RIGHT
var trail: Line2D
var controlled := true
@onready var art: Sprite2D = $Art
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	trail = Line2D.new()
	trail.top_level = true
	trail.width = 4.0
	trail.default_color = Color(0.4, 0.95, 1, 0.5)
	add_child(trail)

func _physics_process(dt: float) -> void:
	if not controlled: return
	var axis := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = SkateMotion.step(velocity, axis, dt, surface, Input.is_action_pressed("drift"))
	move_and_slide()
	if velocity.length() > 20:
		facing = velocity.normalized()
		trail.add_point(global_position + Vector2(0, 23))
		if trail.get_point_count() > 30: trail.remove_point(0)
	elif trail.get_point_count() > 0: trail.remove_point(0)
	art.rotation = lerp_angle(art.rotation, velocity.x / 640.0 * 0.18, dt * 8)
	art.flip_h = facing.x < -0.1
	art.position.y = sin(Time.get_ticks_msec() * 0.015) * minf(velocity.length() / 140, 2)
	camera.position = camera.position.lerp(velocity * 0.22, 1.0 - exp(-dt * 3))

func reset_skater() -> void:
	position = Vector2(500, 540)
	velocity = Vector2.ZERO
	trail.clear_points()
