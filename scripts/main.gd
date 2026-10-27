extends Node

var mission: IceMission
var hud: Control
var ui: CanvasLayer
var menu: Control
var selected_level := 0

func _ready() -> void:
	ui = CanvasLayer.new()
	ui.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ui)
	menu = Control.new()
	menu.set_script(load("res://scripts/menu.gd"))
	menu.manager = self
	ui.add_child(menu)
	menu.home()

func start_level(level: int) -> void:
	get_tree().paused = false
	selected_level = level
	if is_instance_valid(mission):
		remove_child(mission)
		mission.queue_free()
	if is_instance_valid(hud): hud.queue_free()
	var paths := ["neon_frost","crystal_canal","midnight_arena"]
	mission = load("res://scenes/levels/"+paths[level]+".tscn").instantiate()
	mission.process_mode = Node.PROCESS_MODE_PAUSABLE
	mission.level = level
	add_child(mission)
	mission.finished.connect(show_results)
	hud = Control.new()
	hud.set_script(load("res://scripts/hud.gd"))
	hud.mission = mission
	ui.add_child(hud)
	ui.move_child(menu,ui.get_child_count()-1)
	menu.hide()

func show_results(success: bool, stats: Dictionary) -> void:
	get_tree().paused = true
	hud.hide()
	menu.show()
	menu.results(success,stats)
	Audio.sfx("complete" if success else "hurt")

func resume() -> void:
	get_tree().paused = false
	menu.hide()

func restart() -> void:
	start_level(selected_level)

func return_home() -> void:
	get_tree().paused = false
	if is_instance_valid(mission):
		remove_child(mission)
		mission.queue_free()
	if is_instance_valid(hud): hud.queue_free()
	Audio.skate.volume_db = -80
	menu.show()
	menu.home()

func quit_game() -> void:
	Save.persist()
	Audio.shutdown()
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and is_instance_valid(mission) and not mission.ended:
		if get_tree().paused: resume()
		else:
			get_tree().paused = true
			Audio.skate.volume_db = -80
			menu.show()
			menu.pause_menu()
		get_viewport().set_input_as_handled()
