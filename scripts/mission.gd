class_name IceMission
extends Node2D

signal finished(success: bool, stats: Dictionary)
@export_range(0,2) var level := 0
var objectives := MissionObjectives.new()
var pickups: Array[Dictionary] = []
var elapsed := 0.0
var score := 0
var ended := false
var was_beacon_active := false
var near_misses := 0
var boss_dead := true
var citizen: CharacterBody2D
@onready var player: IceSkater = $Player
@onready var world = $World

func _ready() -> void:
	world.level = level
	world.mission = self
	player.shot.connect(fire)
	player.nova_used.connect(nova)
	player.died.connect(func(): finish(false))
	citizen = load("res://scenes/actors/citizen.tscn").instantiate()
	citizen.position = Vector2(2470,840)
	citizen.target = player
	add_child(citizen)
	var kinds := ["chaser","chaser","turret","shield","chaser","turret"]
	var places := [Vector2(950,470),Vector2(1450,850),Vector2(2250,520),Vector2(2300,1000),Vector2(1370,1390),Vector2(850,1160)]
	for i in range(kinds.size()): spawn_enemy(kinds[i],places[i])
	for i in range(24):
		var pos := Vector2(200+(i*317)%2400,260+(i*211)%1300)
		# Avoid inaccessible building footprints.
		for rect in world.walls:
			if rect.grow(35).has_point(pos): pos.y += 260
		pickups.append({"pos":pos,"taken":false,"secret":false})
	for pos in [Vector2(160,1150),Vector2(2630,1600),Vector2(1600,120)]:
		pickups.append({"pos":pos,"taken":false,"secret":true})

func spawn_enemy(kind: String, pos: Vector2) -> Node:
	var enemy = load("res://scenes/actors/enemy.tscn").instantiate()
	enemy.kind = kind
	enemy.position = pos
	enemy.target = player
	enemy.defeated.connect(func(points: int):
		objectives.kills += 1
		score += points*player.combo
		player.gain_flow(14 if player.velocity.length()>180 else 5)
		if kind == "boss": boss_dead = true
	)
	add_child(enemy)
	return enemy

func fire(origin: Vector2, direction: Vector2, power: float) -> void:
	var bullet = load("res://scripts/projectile.gd").new()
	bullet.position = origin
	bullet.velocity = direction * 1100
	bullet.damage = power
	add_child(bullet)

func nova(origin: Vector2, power: float) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.position.distance_to(origin)<270: enemy.take_hit(power,(enemy.position-origin).normalized(),true)
	if citizen.position.distance_to(origin)<270: citizen.take_hit(power,Vector2.ZERO,true)
	for body in get_tree().get_nodes_in_group("breakables"):
		if body.position.distance_to(origin)<270: body.take_hit(power,Vector2.ZERO,true)
	for bullet in get_tree().get_nodes_in_group("hostile_bullets"):
		if bullet.position.distance_to(origin)<270: bullet.queue_free()

func _physics_process(dt: float) -> void:
	if ended: return
	elapsed += dt
	player.surface = world.surface_at(player.position)
	var previous_gate := objectives.gate
	objectives.rescued = citizen.rescued
	objectives.tick(player.position,player.velocity.length(),dt)
	if objectives.gate > previous_gate:
		score += 300*player.combo
		player.gain_flow(12)
		Audio.sfx("collect",1.25)
	for pickup in pickups:
		if not pickup["taken"] and player.position.distance_to(pickup["pos"])<40:
			pickup["taken"] = true
			objectives.collected += 1
			if pickup["secret"]: objectives.secrets += 1
			score += (500 if pickup["secret"] else 100)*player.combo
			player.gain_flow(18 if pickup["secret"] else 10)
			if objectives.collected % 5 == 0: player.health = minf(player.max_health, player.health+1)
			Audio.sfx("collect",1+player.combo*0.06)
	for bullet in get_tree().get_nodes_in_group("hostile_bullets"):
		var distance: float = bullet.position.distance_to(player.position)
		if distance>25 and distance<70 and not bullet.near_missed and player.velocity.length()>250:
			bullet.near_missed = true
			near_misses += 1
			player.gain_flow(5)
			score += 50
	if player.dash_time > 0:
		for body in get_tree().get_nodes_in_group("breakables"):
			if body.position.distance_to(player.position)<100: body.take_hit(10,player.facing,true)
	if objectives.beacon_active and not was_beacon_active:
		was_beacon_active = true
		Audio.sfx("complete")
	if objectives.beacon_active and player.position.distance_to(objectives.EXTRACTION)<100 and boss_dead: finish(true)
	elif elapsed>360 or (objectives.beacon_active and objectives.extraction_left<=0): finish(false)

func finish(success: bool) -> void:
	if ended: return
	ended = true
	player.controlled = false
	Audio.skate.volume_db = -80
	var total := score + (int(maxf(0,360-elapsed))*15 if success else 0)
	var medal := "BRONZE"
	if total>=7000: medal = "SILVER"
	if total>=12000 and player.hurt_count<=4: medal = "GOLD"
	if total>=16000 and objectives.secrets==3 and player.hurt_count==0: medal = "PLATINUM"
	var reward := 70 + total/180 + objectives.secrets*15 if success else 0
	if success: Save.record(level,total,medal,reward)
	finished.emit(success,{"score":total,"medal":medal,"reward":reward,"time":elapsed,"secrets":objectives.secrets,"hits":player.hurt_count})
