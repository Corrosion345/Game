class_name RushEnemy
extends CharacterBody2D

signal defeated(points: int)
@export_enum("chaser", "turret", "shield", "elite", "boss") var kind := "chaser"
var health := 3.0
var max_health := 3.0
var frozen := 0.0
var cooldown := 1.0
var hit_flash := 0.0
var target: Node2D
var phase := 1
var facing := Vector2.LEFT
var telegraph := 0.0
var boss_cycle := 0.0
var dead := false
@onready var art: Sprite2D = $Art

func _ready() -> void:
	add_to_group("enemies")
	max_health = {"chaser": 3.0, "turret": 4.0, "shield": 5.0, "elite": 7.0, "boss": 90.0}[kind]
	health = max_health
	if kind == "boss": scale = Vector2(2.4,2.4)
	art.modulate = {"chaser": Color("84caff"), "turret": Color("ff82db"), "shield": Color("9cffc1"), "elite": Color("c3a0ff"), "boss": Color("ffa3d8")}[kind]

func _physics_process(dt: float) -> void:
	if not is_instance_valid(target) or dead: return
	frozen = maxf(0, frozen - dt)
	hit_flash = maxf(0, hit_flash - dt)
	queue_redraw()
	art.self_modulate = Color(3,3,3) if hit_flash > 0 else (Color("65deff") if frozen > 0 else Color.WHITE)
	if frozen > 0: return
	var delta := target.global_position - global_position
	if kind == "shield": facing = facing.rotated(clampf(facing.angle_to(delta.normalized()),-dt*1.7,dt*1.7))
	else: facing = delta.normalized()
	cooldown -= dt
	if kind == "boss":
		phase = 1 + int(health < max_health * 0.66) + int(health < max_health * 0.33)
		boss_cycle += dt
		velocity = facing * (65 + phase * 20) if delta.length() > 300 else Vector2.ZERO
		if phase == 3 and cooldown < 0.85: velocity = facing * 360
		if cooldown < 0.85:
			telegraph = 0.85 - cooldown
		if cooldown <= 0:
			for i in range(8 + phase * 4):
				shoot(Vector2.from_angle(i * TAU / (8 + phase * 4) + boss_cycle * 0.3), 220 + phase * 45)
			if phase >= 2:
				shoot(facing,420)
				shoot(facing.rotated(0.15),390)
				shoot(facing.rotated(-0.15),390)
			cooldown = 3.6 - phase * 0.5
			telegraph = 0
	else:
		velocity = facing * (165 if kind == "chaser" else 105) if kind != "turret" and delta.length() > 55 else Vector2.ZERO
		if kind in ["turret", "elite"] and delta.length() < 1000 and cooldown <= 0:
			shoot(facing, 320)
			cooldown = 1.7 if kind == "turret" else 1.2
	move_and_slide()
	if delta.length() < (85 if kind == "boss" else 47): target.take_hit(1.0)

func shoot(direction: Vector2, speed: float) -> void:
	var bullet = load("res://scripts/projectile.gd").new()
	bullet.position = global_position + direction * 40
	bullet.velocity = direction * speed
	bullet.hostile = true
	get_parent().add_child(bullet)

func take_hit(amount: float, direction := Vector2.ZERO, charged := false) -> void:
	if dead: return
	if kind == "shield" and not charged and direction.dot(facing) < 0.15:
		load("res://scripts/effect.gd").burst(get_parent(), global_position, 45.0, Color("adffbb"))
		return
	health -= amount
	hit_flash = 0.12
	if charged: frozen = 2.0 + Save.tier(7) * 0.7
	velocity += direction * 80
	Audio.sfx("hit", randf_range(0.9,1.15))
	if health <= 0:
		dead = true
		load("res://scripts/effect.gd").burst(get_parent(), global_position, 130.0 if kind == "boss" else 80.0, Color("ff8bdd"))
		Audio.sfx("destroy")
		defeated.emit(2000 if kind == "boss" else 200)
		queue_free()

func _draw() -> void:
	draw_rect(Rect2(-27,-40,54,5), Color("17223b"))
	draw_rect(Rect2(-27,-40,54 * maxf(health,0) / max_health,5), Color("ff73c9"))
	if kind == "shield": draw_arc(Vector2.ZERO, 36, facing.angle()-1.2, facing.angle()+1.2, 20, Color("93ffc7"), 5, true)
	if frozen > 0: draw_arc(Vector2.ZERO, 35, 0, TAU, 6, Color("abffff"), 3, true)
	if telegraph > 0: draw_arc(Vector2.ZERO, 55 + telegraph * 20, 0, TAU, 32, Color("ff4c9c"), 3, true)
