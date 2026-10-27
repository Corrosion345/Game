extends Node

var mission: IceMission
var hud: Control
var ui: CanvasLayer

func _ready() -> void:
	start_level(0)

func start_level(level: int) -> void:
	mission = load("res://scenes/levels/neon_frost.tscn").instantiate()
	mission.level = level
	add_child(mission)
	mission.finished.connect(show_results)
	ui = CanvasLayer.new()
	add_child(ui)
	hud = Control.new()
	hud.set_script(load("res://scripts/hud.gd"))
	hud.mission = mission
	ui.add_child(hud)

func show_results(success: bool, stats: Dictionary) -> void:
	print("MISSION RESULT: ",success," ",stats)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"): get_tree().paused = not get_tree().paused
