extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var v := Vector2.ZERO
	for i in range(120): v = SkateMotion.step(v, Vector2.RIGHT, 1.0 / 60, "ice", false)
	assert(v.x > 600 and v.length() <= 641, "Acceleration and speed cap")
	var coast := SkateMotion.step(v, Vector2.ZERO, 1.0, "ice", false)
	assert(coast.length() > 400, "Ice retains momentum")
	assert(SkateMotion.step(v, Vector2.ZERO, 1.0, "snow", false).length() < 100, "Snow friction")
	assert(SkateMotion.step(v, Vector2.ZERO, 1.0, "pavement", false).length() < 20, "Pavement friction")
	var normal := SkateMotion.step(v, Vector2.DOWN, 0.1, "ice", false)
	var drift := SkateMotion.step(v, Vector2.DOWN, 0.1, "ice", true)
	assert(normal.angle() > drift.angle(), "Skid preserves lateral momentum")
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await physics_frame
	var player: CharacterBody2D = scene.get_node("Player")
	Input.action_press("move_right")
	for i in range(60): await physics_frame
	Input.action_release("move_right")
	assert(player.position.x > 650, "Input moves instantiated CharacterBody2D")
	player.position = Vector2(2700, 700)
	player.velocity = Vector2(640, 160)
	for i in range(30): await physics_frame
	print("Wall final position: ", player.position)
	assert(player.position.x < 2740 and player.position.y > 705, "Wall collision and sliding")
	print("STAGE 1 PASS: acceleration, cap, coasting, surfaces, drift, scene/input, collision/sliding")
	quit()
