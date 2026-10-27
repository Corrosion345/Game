extends StaticBody2D

func take_hit(_amount: float, _direction := Vector2.ZERO, charged := false) -> void:
	if charged:
		load("res://scripts/effect.gd").burst(get_parent(), position, 100.0)
		queue_free()

func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(-35,25),Vector2(-22,-32),Vector2(5,-48),Vector2(40,10),Vector2(25,35)]),Color("4c8db3"))
	draw_polyline(PackedVector2Array([Vector2(-35,25),Vector2(-22,-32),Vector2(5,-48),Vector2(40,10),Vector2(25,35),Vector2(-35,25)]),Color("b1ffff"),3,true)
	draw_string(ThemeDB.fallback_font,Vector2(-28,60),"DASH",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("afffff"))
