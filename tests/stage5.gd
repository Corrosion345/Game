extends SceneTree
var failures := 0
func check(condition: bool, title: String) -> void:
	if not condition: push_error(title); failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	for path in ["crystal_canal","midnight_arena"]:
		var mission = load("res://scenes/levels/"+path+".tscn").instantiate()
		root.add_child(mission)
		mission.player.controlled = false
		await physics_frame
		if mission.level==1:
			check(mission.world.obstacles.size()==2,"Canal moving barriers")
			var x: float = mission.world.obstacles[0].position.x
			for i in range(30): await physics_frame
			check(absf(mission.world.obstacles[0].position.x-x)>5,"Barrier motion")
		else:
			check(get_nodes_in_group("enemies").size()==8,"Arena wave")
			for enemy in get_nodes_in_group("enemies"): enemy.take_hit(100,Vector2.RIGHT,true)
			for i in range(3): await physics_frame
			var bosses: Array = get_nodes_in_group("enemies")
			check(bosses.size()==1 and bosses[0].kind=="boss","Boss unlocks after minions")
			var boss = bosses[0]
			boss.frozen = 0
			boss.health = 50
			await physics_frame
			await physics_frame
			check(boss.phase==2,"Boss phase two")
			boss.health = 20
			boss.cooldown = 0.01
			for i in range(3): await physics_frame
			check(boss.phase==3 and get_nodes_in_group("hostile_bullets").size()>=20,"Phase three radial + aimed attacks")
			boss.take_hit(100,Vector2.RIGHT,true)
			check(mission.boss_dead and mission.objectives.kills==9,"Boss death completes combat requirement")
		mission.queue_free()
		await physics_frame
	root.get_node("Audio").shutdown()
	await create_timer(0.2).timeout
	print("STAGE 5 district, obstacle and boss failures: ",failures)
	quit(failures)
