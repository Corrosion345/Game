class_name MissionObjectives
extends RefCounted

const GATES := [Vector2(750,400), Vector2(1450,330), Vector2(2310,650), Vector2(2200,1150), Vector2(1500,1460), Vector2(850,1050)]
var route: Array[Vector2] = [Vector2(750,400), Vector2(1450,330), Vector2(2310,650), Vector2(2200,1150), Vector2(1500,1460), Vector2(850,1050)]
var gate := 0
var kills := 0
var rescued := false
var charge := 0.0
var beacon_active := false
var extraction_left := 45.0
var collected := 0
var secrets := 0
var kill_goal := 6
const BEACON := Vector2(2400,1450)
const EXTRACTION := Vector2(430,1450)
const RESCUE := Vector2(420,700)

func primaries_complete() -> bool:
	return gate >= route.size() and kills >= kill_goal and rescued

func tick(pos: Vector2, speed: float, dt: float) -> void:
	if gate < route.size() and pos.distance_to(route[gate]) < 85 and speed > 180: gate += 1
	if primaries_complete() and not beacon_active and pos.distance_to(BEACON) < 190 and speed > 140:
		charge += dt
		if charge >= 4.0: beacon_active = true
	if beacon_active: extraction_left = maxf(0, extraction_left-dt)

func lines() -> String:
	var text := "01   RHYTHM ROUTE     %d / 6 gates\n02   DRONE CLEANUP    %d / %d\n03   RESCUE            %s" % [gate, mini(kills,kill_goal), kill_goal, "SAFE" if rescued else "free + escort"]
	if primaries_complete(): text += "\n04   PULSE BEACON      " + ("CHARGED" if beacon_active else "%d%% • skate inside zone" % int(charge/4*100))
	return text
