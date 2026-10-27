extends Node2D

var level := 0
var clock := 0.0
var mission: Node
var walls: Array[Rect2] = [Rect2(0,0,2800,45),Rect2(0,1755,2800,45),Rect2(0,0,45,1800),Rect2(2755,0,45,1800),Rect2(1070,600,220,180),Rect2(1750,1000,230,180),Rect2(480,900,180,180),Rect2(1680,250,190,180)]
var obstacles: Array[StaticBody2D] = []

func _ready() -> void:
	if level == 1:
		walls.append_array([Rect2(1000,480,700,110),Rect2(1250,1110,400,100),Rect2(2050,750,100,280)])
	if level == 2:
		walls = [Rect2(0,0,2800,45),Rect2(0,1755,2800,45),Rect2(0,0,45,1800),Rect2(2755,0,45,1800),Rect2(900,620,140,160),Rect2(1860,620,140,160),Rect2(900,1120,140,160),Rect2(1860,1120,140,160)]
	var floor := ColorRect.new()
	floor.size = Vector2(2800,1800)
	floor.z_index = -5
	floor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = load("res://assets/ice.gdshader")
	floor.material = material
	add_child(floor)
	for i in range(walls.size()):
		var rect := walls[i]
		var body := StaticBody2D.new()
		var col := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		col.shape = shape
		body.position = rect.get_center()
		body.add_child(col)
		add_child(body)
		if i > 3:
			var sprite := Sprite2D.new()
			sprite.texture = load("res://assets/art/tower.svg")
			sprite.position = rect.get_center() - Vector2(0,55)
			sprite.z_index = 1
			add_child(sprite)
	if level == 1:
		for i in range(2):
			var barrier := AnimatableBody2D.new()
			var col := CollisionShape2D.new()
			var shape := RectangleShape2D.new()
			shape.size = Vector2(160,45)
			col.shape = shape
			barrier.position = Vector2(1420,820+i*160)
			barrier.add_child(col)
			var visual := Polygon2D.new()
			visual.polygon = PackedVector2Array([Vector2(-80,-22),Vector2(80,-22),Vector2(90,0),Vector2(80,22),Vector2(-80,22),Vector2(-90,0)])
			visual.color = Color("e6a879")
			barrier.add_child(visual)
			add_child(barrier)
			obstacles.append(barrier)
	for pos in [Vector2(900,730),Vector2(2020,1200),Vector2(1350,1200)]:
		var body := StaticBody2D.new()
		body.set_script(load("res://scripts/breakable.gd"))
		body.position = pos
		body.add_to_group("breakables")
		var col := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 32
		col.shape = shape
		body.add_child(col)
		add_child(body)

func _physics_process(_dt: float) -> void:
	if level == 1:
		for i in range(obstacles.size()):
			obstacles[i].position.x = 1420 + sin(clock*0.8+i*PI)*330

func surface_at(pos: Vector2) -> String:
	if Rect2(80,1300,700,400).has_point(pos): return "snow"
	if Rect2(2050,100,650,350).has_point(pos): return "pavement"
	return "ice"

func _process(dt: float) -> void:
	clock += dt
	queue_redraw()

func sign_at(pos: Vector2, title: String, color: Color, size := 22) -> void:
	draw_string(ThemeDB.fallback_font,pos,title,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func marker(pos: Vector2, color: Color, title: String, radius := 85.0) -> void:
	draw_circle(pos,radius,Color(color,0.06))
	draw_arc(pos,radius+sin(clock*3)*3,0,TAU,64,Color(color,0.65),3,true)
	for i in range(4):
		var angle := clock*0.4+i*PI*0.5
		var p := Vector2.from_angle(angle)*radius
		draw_line(pos+p*0.8,pos+p,color,5,true)
	sign_at(pos+Vector2(-radius,-radius-22),title,color)

func _draw() -> void:
	draw_rect(Rect2(80,1300,700,400),Color("84b2c8"))
	for i in range(35):
		var p := Vector2(100+(i*191)%650,1320+(i*83)%350)
		draw_line(p,p+Vector2(20,-4),Color(0.8,0.95,1,0.4),3,true)
	draw_rect(Rect2(2050,100,650,350),Color("303448"))
	for rect in walls:
		draw_rect(rect.grow(7),Color("080e25"))
		draw_rect(rect,Color("293754"))
		draw_rect(rect,Color("62cddb"),false,3)
	for i in range(14):
		var pos := Vector2(160+i*180,160+(i*397)%1500)
		draw_polyline(PackedVector2Array([pos,pos+Vector2(28,-10),pos+Vector2(56,8),pos+Vector2(90,0)]),Color(0.4,0.8,0.9,0.12),2,true)
	for i in range(90):
		var pos := Vector2(fmod(i*397.0+clock*18,2800),fmod(i*271.0+clock*38,1800))
		draw_circle(pos,1.0+i%3,Color(0.8,0.95,1,0.32))
	sign_at(Vector2(240,200),["ICEBEAT / FROZEN FESTIVAL","CRYSTAL CANAL / TRANSIT LOCKS","MIDNIGHT / STORM CORE"][level],Color("7ca0c7"),32)
	if level == 1:
		for y in [600,1050]:
			draw_line(Vector2(80,y),Vector2(2700,y),Color(0.2,0.8,1,0.13),8,true)
			draw_line(Vector2(80,y+20),Vector2(2700,y+20),Color(0.5,0.9,1,0.15),2,true)
	if level == 2:
		for r in [250,400,600]: draw_arc(Vector2(1470,870),r,0,TAU,96,Color(0.9,0.3,0.7,0.15),4,true)
		for i in range(16):
			var a := i*TAU/16+sin(clock*0.3)*0.1
			draw_line(Vector2(1470,870)+Vector2.from_angle(a)*200,Vector2(1470,870)+Vector2.from_angle(a)*600,Color(0.9,0.3,0.7,0.08),3,true)
	sign_at(Vector2(100,1280),"SNOWBANK • SLOWS MOMENTUM",Color("a8d5ec"),19)
	sign_at(Vector2(2100,200),"FESTIVAL DECK",Color("d3b8e8"),23)
	marker(MissionObjectives.RESCUE,Color("94ffcc"),"RESCUE ZONE",110)
	if not is_instance_valid(mission): return
	var obj = mission.objectives
	for i in range(obj.route.size()):
		var pos: Vector2 = obj.route[i]
		var c := Color("57f0ff") if i == obj.gate else Color("31566c")
		if i < obj.gate: c = Color("67bca1")
		marker(pos,c,"%02d  /  RHYTHM GATE" % (i+1),72)
		if i == obj.gate:
			draw_colored_polygon(PackedVector2Array([pos+Vector2(-15,-10),pos+Vector2(15,0),pos+Vector2(-15,10)]),c)
	marker(obj.BEACON,Color("ff80d3") if obj.primaries_complete() else Color("55607e"),"PULSE • KEEP SKATING",180)
	if obj.charge > 0: draw_arc(obj.BEACON,160,-PI/2,-PI/2+TAU*minf(obj.charge/4,1),64,Color("fff1b9"),8,true)
	marker(obj.EXTRACTION,Color("ffe5aa") if obj.beacon_active else Color("68728a"),"EXTRACTION",100)
	for pickup in mission.pickups:
		if pickup["taken"]: continue
		var pos: Vector2 = pickup["pos"]
		var c := Color("ffb5e6") if pickup["secret"] else Color("8ef5ff")
		var bob := sin(clock*3+pos.x)*5
		pos.y += bob
		draw_circle(pos,18,Color(c,0.08))
		draw_colored_polygon(PackedVector2Array([pos+Vector2(0,-13),pos+Vector2(8,0),pos+Vector2(0,14),pos+Vector2(-8,0)]),c)
		draw_line(pos+Vector2(0,-8),pos+Vector2(0,6),Color.WHITE,2,true)
