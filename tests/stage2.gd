extends SceneTree
var failures := 0
func check(condition: bool, title: String) -> void:
	if not condition:
		push_error(title)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var player = load("res://scenes/actors/player.tscn").instantiate()
	root.add_child(player)
	player.controlled = false
	player.flow = 0
	check(not player.try_dash(), "Empty FLOW refuses dash")
	player.flow = 80
	check(player.try_dash(Vector2.RIGHT), "Dash accepted")
	check(player.velocity.x == 1350 and player.flow == 62, "Dash speed and FLOW cost")
	check(not player.try_dash(), "Dash cooldown enforced")
	player.invulnerable = 0
	player.take_hit(1)
	check(player.health == player.max_health-1 and player.flow == 37, "Health and FLOW damage")
	player.take_hit(1)
	check(player.health == player.max_health-1, "Damage invulnerability")
	player.flow = 80
	check(player.try_nova() and player.flow == 40, "Nova cost")
	var enemy = load("res://scenes/actors/enemy.tscn").instantiate()
	enemy.kind = "shield"
	root.add_child(enemy)
	enemy.facing = Vector2.RIGHT
	enemy.take_hit(1, Vector2.LEFT, false)
	check(enemy.health == 5, "Shield blocks frontal projectile")
	enemy.take_hit(1, Vector2.RIGHT, false)
	check(enemy.health == 4, "Shield rear vulnerability")
	enemy.take_hit(1, Vector2.LEFT, true)
	check(enemy.health == 3 and enemy.frozen >= 2, "Charged bypass and freeze")
	player.queue_free()
	enemy.queue_free()
	await process_frame
	print("STAGE 2: FLOW, costs, cooldowns, damage, invulnerability, directional shields, freeze. Failures: ",failures)
	quit(failures)
