extends Node

var waiting_action := ""
const KEYS := {"move_left": KEY_A, "move_right": KEY_D, "move_up": KEY_W, "move_down": KEY_S, "drift": KEY_SHIFT, "dash": KEY_SPACE, "nova": KEY_E, "pause": KEY_ESCAPE, "reset": KEY_R}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for action in KEYS:
		InputMap.add_action(action, 0.2)
		var event := InputEventKey.new()
		event.physical_keycode = KEYS[action]
		InputMap.action_add_event(action, event)
	InputMap.add_action("fire")
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	InputMap.action_add_event("fire", mouse)
	for data in [["move_left", JOY_AXIS_LEFT_X, -1.0], ["move_right", JOY_AXIS_LEFT_X, 1.0], ["move_up", JOY_AXIS_LEFT_Y, -1.0], ["move_down", JOY_AXIS_LEFT_Y, 1.0], ["fire", JOY_AXIS_TRIGGER_RIGHT, 1.0], ["drift", JOY_AXIS_TRIGGER_LEFT, 1.0]]:
		var event := InputEventJoypadMotion.new()
		event.axis = data[1]
		event.axis_value = data[2]
		InputMap.action_add_event(data[0], event)
	for data in [["dash", JOY_BUTTON_A], ["nova", JOY_BUTTON_X], ["pause", JOY_BUTTON_START], ["drift", JOY_BUTTON_LEFT_SHOULDER]]:
		var event := InputEventJoypadButton.new()
		event.button_index = data[1]
		InputMap.action_add_event(data[0], event)
	var saved: Dictionary = Save.data.get("bindings", {})
	for action in saved:
		_rebind(action, int(saved[action]))

func _input(event: InputEvent) -> void:
	if waiting_action != "" and event is InputEventKey and event.pressed:
		if event.physical_keycode != KEY_ESCAPE:
			_rebind(waiting_action, event.physical_keycode)
			Save.data["bindings"][waiting_action] = event.physical_keycode
			Save.persist()
		waiting_action = ""
		get_viewport().set_input_as_handled()

func _rebind(action: String, key: int) -> void:
	for old in InputMap.action_get_events(action):
		if old is InputEventKey: InputMap.action_erase_event(action, old)
	var event := InputEventKey.new()
	event.physical_keycode = key
	InputMap.action_add_event(action, event)
