extends Control

var mission: IceMission
var status: Label
var objectives_label: Label
var flow_bar: ProgressBar
var health_label: Label
var flow_label: Label
var tip: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	status = make_label(Vector2(45,30),32)
	health_label = make_label(Vector2(45,85),25)
	flow_label = make_label(Vector2(45,125),22)
	flow_bar = ProgressBar.new()
	flow_bar.position = Vector2(45,165)
	flow_bar.size = Vector2(370,14)
	flow_bar.show_percentage = false
	add_child(flow_bar)
	objectives_label = make_label(Vector2(45,210),22)
	tip = make_label(Vector2(45,1000),22)

func make_label(pos: Vector2, size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size",size)
	label.add_theme_color_override("font_color",Color("dcf8ff"))
	label.add_theme_color_override("font_shadow_color",Color("070e26"))
	label.add_theme_constant_override("shadow_offset_x",2)
	label.add_theme_constant_override("shadow_offset_y",2)
	add_child(label)
	return label

func _process(_dt: float) -> void:
	if not is_instance_valid(mission): return
	var p := mission.player
	var obj := mission.objectives
	status.text = ["NEON FROST PLAZA","CRYSTAL CANAL","MIDNIGHT ICE ARENA"][mission.level] + "   /   %02d:%02d   /   %06d" % [int(mission.elapsed)/60,int(mission.elapsed)%60,mission.score]
	health_label.text = "VITALS   " + "♥ ".repeat(int(p.health)) + "   %03d km/h" % int(p.velocity.length()/7)
	flow_label.text = "FLOW  %03d / %d      ×%d COMBO" % [int(p.flow),int(p.flow_max),p.combo]
	flow_bar.max_value = p.flow_max
	flow_bar.value = p.flow
	objectives_label.text = obj.lines().replace("\n","
")
	if obj.beacon_active:
		objectives_label.text += "
EXTRACT NOW   %.1f seconds" % obj.extraction_left
	tip.text = "WASD / LS  skate     SHIFT / LT  drift     SPACE / A  dash [18 FLOW]     LMB / RT  fire     E / X  nova [40 FLOW]     ESC  pause"
	if mission.elapsed<12: tip.text = "Keep your momentum. Follow numbered gates at speed. Shoot the frozen citizen, then lead them to the green rescue zone."
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(mission): return
	draw_style_box(panel_style(),Rect2(25,15,890,365))
	draw_style_box(panel_style(),Rect2(25,980,1870,75))
	var origin := Vector2(1570,35)
	var scale_map := Vector2(0.1,0.1)
	draw_style_box(panel_style(),Rect2(origin-Vector2(12,12),Vector2(304,204)))
	for rect in mission.world.walls: draw_rect(Rect2(origin+rect.position*scale_map,rect.size*scale_map),Color("36506a"))
	for i in range(mission.objectives.GATES.size()):
		var c := Color("71f6ff") if i==mission.objectives.gate else Color("3b6378")
		draw_circle(origin+mission.objectives.GATES[i]*scale_map,5,c)
	draw_circle(origin+mission.objectives.BEACON*scale_map,6,Color("ff7ad0"))
	draw_circle(origin+mission.objectives.EXTRACTION*scale_map,6,Color("ffdc8e"))
	draw_circle(origin+mission.citizen.position*scale_map,4,Color("9cffc7"))
	draw_circle(origin+mission.player.position*scale_map,5,Color.WHITE)

func panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025,0.04,0.10,0.88)
	style.border_color = Color(0.3,0.7,0.8,0.35)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	return style
