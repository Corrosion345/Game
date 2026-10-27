extends Node

const PATH := "user://icebeat_save.json"
const UPGRADE_NAMES := ["Acceleration", "Top speed", "Drift control", "FLOW capacity", "Dash efficiency", "Ice power", "Health", "Freeze time"]
var data: Dictionary = {"version": 1, "crystals": 0, "unlocked": 1, "upgrades": [0,0,0,0,0,0,0,0], "best": {}, "bindings": {}, "music": 0.55, "sfx": 0.7}

func _ready() -> void:
	if FileAccess.file_exists(PATH):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		if parsed is Dictionary and parsed.get("version") == 1:
			for key in data:
				if parsed.has(key) and (typeof(parsed[key]) == typeof(data[key]) or (parsed[key] is float and data[key] is int)): data[key] = parsed[key]
	# JSON numbers deserialize as floats.
	data["crystals"] = maxi(0, int(data["crystals"]))
	data["unlocked"] = clampi(int(data["unlocked"]), 1, 3)
	if data["upgrades"].size() != 8: data["upgrades"] = [0,0,0,0,0,0,0,0]
	for i in range(8): data["upgrades"][i] = clampi(int(data["upgrades"][i]), 0, 3)

func tier(index: int) -> int:
	return int(data["upgrades"][index])

func cost(index: int) -> int:
	return 60 + tier(index) * 70

func buy(index: int) -> bool:
	if tier(index) >= 3 or int(data["crystals"]) < cost(index): return false
	data["crystals"] -= cost(index)
	data["upgrades"][index] += 1
	persist()
	return true

func record(level: int, score: int, medal: String, reward: int) -> void:
	data["crystals"] += reward
	data["unlocked"] = mini(3, maxi(int(data["unlocked"]), level + 2))
	var key := str(level)
	if score > int(data["best"].get(key, {}).get("score", -1)):
		data["best"][key] = {"score": score, "medal": medal}
	persist()

func persist() -> void:
	var file := FileAccess.open(PATH + ".tmp", FileAccess.WRITE)
	if file == null:
		push_error("Cannot save progression: " + error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(data))
	file.close()
	DirAccess.rename_absolute(PATH + ".tmp", PATH)
