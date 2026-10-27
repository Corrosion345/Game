extends SceneTree
var failures := 0
var result: Dictionary = {}
func check(condition: bool, title: String) -> void:
	if not condition: push_error(title); failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var save_manager = root.get_node("Save")
	var saved: Dictionary = save_manager.data.duplicate(true)
	var mission = load("res://scenes/levels/neon_frost.tscn").instantiate()
	root.add_child(mission)
	mission.player.controlled = false
	mission.finished.connect(func(success: bool, stats: Dictionary): result = stats; result["success"] = success)
	await physics_frame
	check(get_nodes_in_group("enemies").size()==6,"Six drones spawned")
	mission.player.position = MissionObjectives.GATES[0]
	mission.player.velocity = Vector2.ZERO
	await physics_frame
	await physics_frame
	check(mission.objectives.gate==0,"Gate requires speed")
	for gate in MissionObjectives.GATES:
		mission.player.position = gate
		mission.player.velocity = Vector2(300,0)
		await physics_frame
		await physics_frame
	check(mission.objectives.gate==6,"Sequential speed gates complete")
	for enemy in get_nodes_in_group("enemies"): enemy.take_hit(100,Vector2.RIGHT,true)
	await physics_frame
	check(mission.objectives.kills==6,"Combat objective receives deaths")
	mission.citizen.take_hit(3)
	mission.player.position = mission.citizen.position+Vector2(-200,0)
	var start: Vector2 = mission.citizen.position
	for i in range(30): await physics_frame
	check(mission.citizen.position.x<start.x-30,"Freed citizen follows player")
	mission.citizen.position = MissionObjectives.RESCUE
	mission.player.position = MissionObjectives.RESCUE
	for i in range(3): await physics_frame
	check(mission.objectives.primaries_complete(),"Rescue and primary objectives complete")
	mission.player.position = MissionObjectives.BEACON+Vector2(100,0)
	mission.player.velocity = Vector2.ZERO
	for i in range(5): await physics_frame
	check(mission.objectives.charge==0,"Stationary beacon cannot charge")
	mission.player.velocity = Vector2(200,0)
	for i in range(250): await physics_frame
	check(mission.objectives.beacon_active,"Momentum charges beacon")
	mission.player.position = MissionObjectives.EXTRACTION
	for i in range(3): await physics_frame
	check(result.get("success",false),"Extraction reaches results")
	check(int(save_manager.data["unlocked"])==2 and int(save_manager.data["crystals"])>0,"Reward and next district unlock")
	mission.queue_free()
	save_manager.data = saved
	save_manager.persist()
	await create_timer(1).timeout
	print("STAGE 3 mission lifecycle failures: ", failures)
	quit(failures)
