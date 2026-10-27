class_name IceSkater
extends CharacterBody2D

signal shot(origin: Vector2, direction: Vector2, power: float)
signal nova_used(origin: Vector2, power: float)
signal died
var surface := "ice"
var facing := Vector2.RIGHT
var aim := Vector2.RIGHT
var trail: Line2D
var particles: GPUParticles2D
var controlled := true
var flow := 30.0
var flow_max := 100.0
var health := 5.0
var max_health := 5.0
var dash_time := 0.0
var dash_cooldown := 0.0
var shot_cooldown := 0.0
var nova_cooldown := 0.0
var invulnerable := 0.0
var combo := 1
var hurt_count := 0
var last_position := Vector2.ZERO
@onready var art: Sprite2D = $Art
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	flow_max += Save.tier(3) * 25
	max_health += Save.tier(6)
	health = max_health
	trail = Line2D.new()
	trail.top_level = true
	trail.width = 4.0
	trail.default_color = Color(0.4, 0.95, 1, 0.5)
	add_child(trail)
	particles = GPUParticles2D.new()
	particles.amount = 44
	particles.lifetime = 0.45
	particles.local_coords = false
	particles.visibility_rect = Rect2(-1200,-1200,2400,2400)
	var texture := GradientTexture2D.new()
	texture.width = 12
	texture.height = 12
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5,0.5)
	texture.fill_to = Vector2(0.5,0)
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color.WHITE,Color(1,1,1,0)])
	texture.gradient = gradient
	particles.texture = texture
	var material := ParticleProcessMaterial.new()
	material.gravity = Vector3.ZERO
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 10
	material.initial_velocity_min = 20
	material.initial_velocity_max = 90
	material.scale_min = 0.25
	material.scale_max = 0.75
	material.color = Color("93f9ff")
	particles.process_material = material
	particles.emitting = false
	particles.position = Vector2(0,25)
	add_child(particles)

func _physics_process(dt: float) -> void:
	if not controlled: return
	var axis := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var drift := Input.is_action_pressed("drift")
	dash_time = maxf(0, dash_time-dt)
	dash_cooldown = maxf(0, dash_cooldown-dt)
	shot_cooldown -= dt
	nova_cooldown -= dt
	invulnerable -= dt
	if dash_time <= 0:
		velocity = SkateMotion.step(velocity, axis, dt, surface, drift, 520 + Save.tier(0)*80, (640 + Save.tier(1)*40) * (1 + flow/flow_max*0.12), Save.tier(2)*0.4)
	if velocity.length() > 360:
		gain_flow(dt * (3.0 + (5.0 if drift and absf(velocity.angle_to(axis)) > 0.25 and axis.length() > 0.1 else 0)))
	elif velocity.length() < 80: gain_flow(-dt * 3.0)
	combo = 1 + int(flow / 25)
	if Input.is_action_just_pressed("dash"): try_dash(axis)
	if Input.is_action_just_pressed("nova"): try_nova()
	var stick := Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
	if stick.length() > 0.25: aim = stick.normalized()
	elif Input.get_connected_joypads().is_empty() or Input.get_last_mouse_velocity().length() > 2: aim = (get_global_mouse_position()-global_position).normalized()
	if Input.is_action_pressed("fire") and shot_cooldown <= 0:
		shot.emit(global_position + aim*30, aim, 1.0 + Save.tier(5)*0.4 + flow/flow_max*0.5)
		shot_cooldown = 0.19
		Audio.sfx("shot", randf_range(0.95,1.1))
	last_position = global_position
	move_and_slide()
	if dash_time > 0:
		for enemy in get_tree().get_nodes_in_group("enemies"):
			var segment := Geometry2D.get_closest_point_to_segment(enemy.global_position, last_position, global_position)
			if segment.distance_to(enemy.global_position) < 65 and enemy.frozen < 0.1: enemy.take_hit(5.0+Save.tier(5), facing, true)
	if velocity.length() > 20:
		facing = velocity.normalized()
		trail.add_point(global_position + Vector2(0, 23))
		if trail.get_point_count() > 35: trail.remove_point(0)
	elif trail.get_point_count() > 0: trail.remove_point(0)
	particles.emitting = velocity.length()>180
	particles.amount_ratio = clampf(velocity.length()/700,0.1,1)
	particles.process_material.direction = Vector3(-facing.x,-facing.y,0)
	trail.width = 3 + flow / flow_max * 7 + (8 if dash_time > 0 else 0)
	art.rotation = lerp_angle(art.rotation, velocity.x / 640.0 * (0.3 if drift else 0.18), dt * 8)
	art.flip_h = facing.x < -0.1
	art.position.y = sin(Time.get_ticks_msec() * 0.015) * minf(velocity.length() / 140, 2)
	art.modulate.a = 0.5 if invulnerable > 0 and fmod(invulnerable,0.16)<0.08 else 1.0
	camera.position = camera.position.lerp(velocity * 0.22, 1.0 - exp(-dt * 3))
	Audio.skate.volume_db = linear_to_db(maxf(0.0001, velocity.length()/1400.0))
	Audio.skate.pitch_scale = 1.5 if drift else 1.0
	queue_redraw()

func gain_flow(value: float) -> void:
	flow = clampf(flow+value, 0, flow_max)

func try_dash(axis := Vector2.ZERO) -> bool:
	var cost := 18.0 - Save.tier(4)*3
	if flow < cost or dash_cooldown > 0: return false
	gain_flow(-cost)
	dash_time = 0.22
	dash_cooldown = 0.6
	invulnerable = maxf(invulnerable,0.3)
	var direction := axis.normalized() if axis.length()>0.1 else facing
	velocity = direction * 1350
	facing = direction
	load("res://scripts/effect.gd").burst(get_parent(), global_position, 140.0)
	Audio.sfx("dash")
	return true

func try_nova() -> bool:
	if flow < 40 or nova_cooldown > 0: return false
	gain_flow(-40)
	nova_cooldown = 1.5
	nova_used.emit(global_position, 4.0+Save.tier(5))
	load("res://scripts/effect.gd").burst(get_parent(), global_position, 270.0)
	Audio.sfx("nova")
	return true

func take_hit(amount: float) -> void:
	if invulnerable > 0 or health <= 0: return
	health = maxf(0, health-amount)
	hurt_count += 1
	gain_flow(-25)
	invulnerable = 1.0
	Audio.sfx("hurt")
	if health <= 0: died.emit()

func reset_skater() -> void:
	position = Vector2(500, 540)
	velocity = Vector2.ZERO
	trail.clear_points()

func _draw() -> void:
	draw_line(aim * 38, aim * 52, Color("e0ffff"), 3, true)
