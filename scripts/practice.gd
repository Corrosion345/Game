extends Node2D

@onready var player: IceSkater = $Player
@onready var rink = $Rink
@onready var label: Label = $HUD/Label

func _ready() -> void:
	pass

func _setup_input() -> void:
	var keys := {"move_left": KEY_A, "move_right": KEY_D, "move_up": KEY_W, "move_down": KEY_S, "drift": KEY_SHIFT, "reset": KEY_R, "pause": KEY_ESCAPE}
	for action in keys:
		if not InputMap.has_action(action): InputMap.add_action(action)
		var key := InputEventKey.new()
		key.physical_keycode = keys[action]
		InputMap.action_add_event(action, key)
	for data in [["move_left", JOY_AXIS_LEFT_X, -1.0], ["move_right", JOY_AXIS_LEFT_X, 1.0], ["move_up", JOY_AXIS_LEFT_Y, -1.0], ["move_down", JOY_AXIS_LEFT_Y, 1.0]]:
		var event := InputEventJoypadMotion.new()
		event.axis = data[1]
		event.axis_value = data[2]
		InputMap.action_add_event(data[0], event)

func _process(_dt: float) -> void:
	player.surface = rink.surface_at(player.position)
	label.text = "ICEBEAT RUSH   /   PRACTICE
WASD / left stick: skate     SHIFT: skid     R: reset     ESC: pause
SPEED %03d   •   %s" % [player.velocity.length(), player.surface.to_upper()]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"): player.reset_skater()
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
