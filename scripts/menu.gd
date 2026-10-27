extends Control

var manager: Node
var clock := 0.0
var content: Control
var current := "home"
var hero := preload("res://assets/art/portrait.svg")
var busy := false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var ui_theme := Theme.new()
	ui_theme.default_font_size = 26
	for state in ["normal","hover","pressed","focus","disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("19374c") if state in ["hover","focus"] else Color("101d36")
		if state == "pressed": style.bg_color = Color("31576e")
		if state == "disabled": style.bg_color = Color("15192b")
		style.border_color = Color("78efff") if state != "disabled" else Color("41445f")
		style.set_border_width_all(2 if state in ["hover","focus"] else 1)
		style.set_corner_radius_all(9)
		style.content_margin_left = 24
		style.content_margin_right = 24
		ui_theme.set_stylebox(state,"Button",style)
	ui_theme.set_color("font_color","Button",Color("e4faff"))
	ui_theme.set_color("font_disabled_color","Button",Color("676d89"))
	theme = ui_theme
	content = Control.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(content)

func _process(dt: float) -> void:
	clock += dt
	queue_redraw()

func clear(title: String, subtitle: String) -> void:
	for node in content.get_children():
		content.remove_child(node)
		node.queue_free()
	label_at(Vector2(90,65),title,52,Color("dcfaff"))
	label_at(Vector2(94,138),subtitle,24,Color("91b3ce"))
	content.modulate.a = 0
	create_tween().tween_property(content,"modulate:a",1.0,0.22)

func label_at(pos: Vector2, text: String, font_size := 26, color := Color("d1eaf7")) -> Label:
	var label := Label.new()
	label.position = pos
	label.text = text
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	content.add_child(label)
	return label

func button(pos: Vector2, text: String, action: Callable, width := 620.0, disabled := false) -> Button:
	var b := Button.new()
	b.position = pos
	b.size = Vector2(width,64)
	b.text = text
	b.disabled = disabled
	b.pressed.connect(func(): Audio.sfx("menu"); action.call())
	b.mouse_entered.connect(func(): b.grab_focus())
	content.add_child(b)
	if get_viewport().gui_get_focus_owner() == null and not disabled: b.grab_focus()
	return b

func back(action: Callable) -> void:
	button(Vector2(90,930),"←  BACK",action,300)

func home() -> void:
	current = "home"
	clear("ICEBEAT RUSH","A frozen city. A live pulse. Keep moving.")
	label_at(Vector2(96,225),"THE FESTIVAL HAS FALLEN SILENT.",22,Color("ff9edc"))
	label_at(Vector2(96,275),"Skate through the storm as Nova Vale,
a pop star with the power to reshape the ice.
Find the rhythm. Bring your city back.",27)
	button(Vector2(95,445),"START / DISTRICT SELECT",levels).grab_focus()
	button(Vector2(95,525),"UPGRADE STUDIO",shop)
	button(Vector2(95,605),"SETTINGS & CONTROLS",settings)
	button(Vector2(95,685),"HOW TO PLAY",help_screen)
	button(Vector2(95,765),"QUIT",manager.quit_game)
	label_at(Vector2(98,970),"NATIVE WINDOWS EDITION    /    ORIGINAL ART + MUSIC",19,Color("627f9c"))
	label_at(Vector2(1130,770),"NOVA VALE",43,Color("8ff8ff"))
	label_at(Vector2(1133,830),"ICE • RHYTHM • MOMENTUM",21,Color("f8ade2"))

func levels() -> void:
	current = "levels"
	clear("CHOOSE YOUR DISTRICT","Finish a mission to unlock the next district. Upgrades carry between runs.")
	var names := ["NEON FROST PLAZA","CRYSTAL CANAL","MIDNIGHT ICE ARENA"]
	var details := ["01 / THE FIRST PULSE\nWide ice. Rescue a festivalgoer.\nLearn the route and restore the beacon.","02 / UNDER THE GLASS\nNarrow routes. Moving barriers.\nElite drones patrol the frozen canal.","03 / THE STORM'S HEART\nArena combat and a three-phase boss.\nSilence the storm, then escape."]
	for i in range(3):
		var x := 90+i*590
		label_at(Vector2(x,270),names[i],30,Color("92efff"))
		label_at(Vector2(x,350),details[i].replace("\n","
"),24)
		var record: Dictionary = Save.data["best"].get(str(i),{})
		label_at(Vector2(x,540),"BEST   %06d  /  %s" % [int(record.get("score",0)),record.get("medal","UNRANKED")],22,Color("ffdca8"))
		button(Vector2(x,630),"ENTER DISTRICT" if i<int(Save.data["unlocked"]) else "LOCKED",manager.start_level.bind(i),530,i>=int(Save.data["unlocked"]))
	back(home)

func shop() -> void:
	current = "shop"
	clear("UPGRADE STUDIO","Snow Crystals: %d     •     Three tiers per upgrade. Purchases save immediately." % int(Save.data["crystals"]))
	var bonuses := ["+80 acceleration / tier","+40 maximum speed / tier","More steering grip / tier","+25 FLOW capacity / tier","−3 dash cost / tier","Stronger shots + abilities","+1 maximum health / tier","+0.7s freeze duration / tier"]
	for i in range(8):
		var x := 90+(i%2)*890
		var y := 235+(i/2)*160
		label_at(Vector2(x,y),Save.UPGRADE_NAMES[i].to_upper()+"   "+"◆".repeat(Save.tier(i))+"◇".repeat(3-Save.tier(i)),27,Color("8ff8ff"))
		label_at(Vector2(x,y+42),bonuses[i],22)
		var cost := Save.cost(i)
		button(Vector2(x+470,y+25),"MAXED" if Save.tier(i)>=3 else "%d CRYSTALS" % cost,func(): Save.buy(i); shop(),330,Save.tier(i)>=3 or int(Save.data["crystals"])<cost)
	back(home)

func slider(pos: Vector2, bus: String, key: String) -> void:
	var control := HSlider.new()
	control.position = pos
	control.size = Vector2(570,45)
	control.min_value = 0
	control.max_value = 1
	control.step = 0.01
	control.value = float(Save.data[key])
	control.value_changed.connect(func(value: float): Audio.volume(bus,value); Save.data[key]=value)
	control.drag_ended.connect(func(_changed: bool): Save.persist())
	content.add_child(control)

func settings() -> void:
	current = "settings"
	clear("SETTINGS & CONTROLS","Use mouse or controller to select. Set either volume to zero to mute.")
	label_at(Vector2(95,235),"MUSIC",25)
	slider(Vector2(95,285),"Music","music")
	label_at(Vector2(95,375),"EFFECTS",25)
	slider(Vector2(95,425),"Effects","sfx")
	button(Vector2(95,540),"TOGGLE FULLSCREEN",func():
		get_window().mode = Window.MODE_WINDOWED if get_window().mode == Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN
	)
	var resolution := OptionButton.new()
	resolution.position = Vector2(95,635)
	resolution.size = Vector2(620,64)
	for size in ["1280 × 720","1920 × 1080","2560 × 1440"]: resolution.add_item(size)
	resolution.item_selected.connect(func(index: int):
		get_window().mode = Window.MODE_WINDOWED
		get_window().size = [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440)][index]
	)
	content.add_child(resolution)
	label_at(Vector2(95,740),"Xbox: LS skate • RS aim • RT fire
LT / LB drift • A dash • X nova • Start pause",24)
	label_at(Vector2(950,235),"REMAP KEYBOARD",30,Color("8ff8ff"))
	var actions := ["move_left","move_right","move_up","move_down","drift","dash","nova","pause","reset","fire"]
	for i in range(actions.size()):
		var action: String = actions[i]
		var key := "LMB" if action == "fire" else ""
		for event in InputMap.action_get_events(action):
			if event is InputEventKey: key = OS.get_keycode_string(event.physical_keycode)
		button(Vector2(950,300+i*65),action.to_upper().replace("_"," ")+"     [ "+key+" ]",func():
			Bindings.waiting_action = action
			label_at(Vector2(950,975),"Press a key. Escape cancels. Reopen settings to refresh.",20,Color("ffacd9"))
		,790)
	back(func(): Save.persist(); home())

func help_screen() -> void:
	current = "help"
	clear("FIND YOUR FLOW","Skating is the heart of the game. Build speed before turning into a corner.")
	label_at(Vector2(95,245),"01   SKATE",32,Color("8ff8ff"))
	label_at(Vector2(95,305),"WASD / left stick accelerates gradually. Releasing input keeps you coasting.
Hold Shift / left trigger to widen turns and powerslide. Snow slows you down.
Space / A dashes through drones and marked brittle ice. R resets in practice only.",26)
	label_at(Vector2(95,465),"02   KEEP THE PULSE",32,Color("ff9cdb"))
	label_at(Vector2(95,525),"Fast skating, cornering, notes, near misses and moving kills generate FLOW.
FLOW raises your speed, shot power and score multiplier. Dash costs 18; Nova costs 40.
Aim with the mouse / right stick. Fire with left mouse / right trigger. E / X freezes an area.
Green shield drones block frontal shots: flank them, dash through, or use Nova.",26)
	label_at(Vector2(95,720),"03   BRING THE CITY BACK",32,Color("b0ffd8"))
	label_at(Vector2(95,780),"Clear six gates in order at speed, defeat every marked drone, and shoot the frozen citizen.
Escort them to the green zone; keep within 800px so they follow. Collect five notes to heal.
Then skate inside the pink beacon for four seconds. Extract at the gold zone within 45s.
Find all three pink secrets and avoid damage for a chance at Platinum.",25)
	back(home)

func pause_menu() -> void:
	current = "pause"
	clear("PAUSED","Take a breath. The storm can wait.")
	button(Vector2(95,300),"RESUME",manager.resume).grab_focus()
	button(Vector2(95,390),"RESTART DISTRICT",manager.restart)
	button(Vector2(95,480),"RETURN TO HUB",manager.return_home)

func results(success: bool, stats: Dictionary) -> void:
	current = "results"
	clear("DISTRICT RESTORED" if success else "LOST IN THE STORM","Your progress and upgrades are saved. Try a new route or tune your skates.")
	label_at(Vector2(100,260),stats["medal"] if success else "MISSION FAILED",58,Color("ffe1aa") if success else Color("ff8ec7"))
	label_at(Vector2(100,370),"SCORE      %06d\nTIME          %02d:%02d\nSECRETS    %d / 3\nHITS          %d\nREWARD     %d Snow Crystals" % [stats["score"],int(stats["time"])/60,int(stats["time"])%60,stats["secrets"],stats["hits"],stats["reward"]],32).text = ("SCORE      %06d
TIME          %02d:%02d
SECRETS    %d / 3
HITS          %d
REWARD     %d Snow Crystals" % [stats["score"],int(stats["time"])/60,int(stats["time"])%60,stats["secrets"],stats["hits"],stats["reward"]])
	button(Vector2(95,740),"REPLAY DISTRICT",manager.restart)
	button(Vector2(95,830),"RETURN TO HUB",manager.return_home)

func _draw() -> void:
	if current == "pause":
		draw_rect(Rect2(0,0,1920,1080),Color(0.02,0.03,0.09,0.88))
		return
	draw_rect(Rect2(0,0,1920,1080),Color("080f24"))
	for i in range(20):
		var x := i*140.0 + fmod(clock*12,140)
		draw_line(Vector2(x-450,1080),Vector2(x+350,0),Color(0.25,0.5,0.75,0.045),2)
	for i in range(45):
		var pos := Vector2(fmod(i*373.0+clock*8,1920),fmod(i*157.0+clock*22,1080))
		draw_circle(pos,1+i%2,Color(0.6,0.9,1,0.20))
	draw_line(Vector2(95,190),Vector2(1820,190),Color("2d5269"),2,true)
	if current == "home":
		var center := Vector2(1380,460)
		for i in range(3): draw_arc(center,220+i*44,clock*0.1+i,clock*0.1+i+4.8,80,Color(0.4,0.85,1,0.10+i*0.06),2,true)
		draw_texture_rect(hero,Rect2(1170,220+sin(clock*2)*10,420,490),false)
