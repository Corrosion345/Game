extends SceneTree
var failures := 0
func check(condition: bool, title: String) -> void:
	if not condition: push_error(title); failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var save = root.get_node("Save")
	var saved: Dictionary = save.data.duplicate(true)
	save.data["crystals"] = 200
	save.data["upgrades"] = [0,0,0,0,0,0,0,0]
	check(save.buy(0) and save.tier(0)==1 and save.data["crystals"]==140,"Purchase and increasing tier cost")
	check(save.cost(0)==130,"Next tier cost increases")
	save.persist()
	var reloaded = load("res://scripts/save.gd").new()
	root.add_child(reloaded)
	check(reloaded.tier(0)==1 and reloaded.data["crystals"]==140,"Save reload preserves numeric JSON values")
	reloaded.queue_free()
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	check(game.menu.current=="home","Main menu starts")
	game.menu.levels()
	game.menu.shop()
	game.menu.settings()
	game.menu.help_screen()
	game.start_level(0)
	check(is_instance_valid(game.mission) and not game.menu.visible,"Menu starts real mission")
	var event := InputEventAction.new()
	event.action = "pause"
	event.pressed = true
	game._unhandled_input(event)
	check(paused and game.menu.current=="pause","Pause transition")
	game.resume()
	check(not paused,"Resume transition")
	game.mission.finish(false)
	check(paused and game.menu.current=="results","Failure results transition")
	game.return_home()
	check(not paused and game.menu.current=="home","Return to hub")
	game.queue_free()
	save.data = saved
	save.persist()
	root.get_node("Audio").shutdown()
	await create_timer(0.2).timeout
	print("STAGE 4 save, shop and UI transition failures: ",failures)
	quit(failures)
