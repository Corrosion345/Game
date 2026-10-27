extends SceneTree
var failures := 0
func check(condition: bool, title: String) -> void:
	if not condition: push_error(title); failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var mission = load("res://scenes/levels/neon_frost.tscn").instantiate()
	root.add_child(mission)
	mission.player.controlled = false
	for enemy in get_nodes_in_group("enemies"): enemy.queue_free()
	await physics_frame
	var turret = mission.spawn_enemy("turret",Vector2(950,830))
	turret.frozen = 999
	mission.player.position = Vector2(500,830)
	mission.fire(Vector2(530,830),Vector2.RIGHT,4)
	for i in range(45): await physics_frame
	check(not is_instance_valid(turret),"Ray-swept projectile hits enemy collider and destroys it")
	var bullet = load("res://scripts/projectile.gd").new()
	bullet.position = Vector2(800,830)
	bullet.velocity = Vector2(-600,0)
	bullet.hostile = true
	mission.add_child(bullet)
	for i in range(40): await physics_frame
	check(mission.player.health==4,"Enemy projectile hits player collider")
	var shield = mission.spawn_enemy("shield",Vector2(650,830))
	var far = mission.spawn_enemy("turret",Vector2(1200,830))
	mission.nova(mission.player.position,4)
	check(shield.frozen>=2 and shield.health==1 and far.health==4,"Nova radius, freeze and shield bypass")
	shield.queue_free()
	far.queue_free()
	mission.player.position = Vector2(780,730)
	mission.player.velocity = Vector2.ZERO
	mission.player.flow = 80
	mission.player.controlled = true
	Input.action_press("move_right")
	Input.action_press("dash")
	for i in range(5): await physics_frame
	Input.action_release("dash")
	Input.action_release("move_right")
	check(get_nodes_in_group("breakables").size()==2,"Input dash destroys brittle ice")
	mission.player.controlled = false
	mission.elapsed = 361
	await physics_frame
	await physics_frame
	check(mission.ended,"Mission timeout fails safely")
	mission.queue_free()
	await physics_frame
	root.get_node("Audio").shutdown()
	await create_timer(0.2).timeout
	print("COMBAT PHYSICS projectile, nova, dash and timeout failures: ",failures)
	quit(failures)
