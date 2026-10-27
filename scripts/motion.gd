class_name SkateMotion
extends RefCounted

static func step(v: Vector2, axis: Vector2, dt: float, surface: String, drift: bool, acceleration := 520.0, top_speed := 640.0, grip_bonus := 0.0) -> Vector2:
	var drag := 0.24
	if surface == "snow": drag = 2.4
	if surface == "pavement": drag = 4.2
	if axis.length() > 0.08:
		var direction := axis.normalized()
		var speed := v.length()
		var grip := (1.5 + grip_bonus) if drift else (3.7 + grip_bonus)
		if speed > 25.0:
			var angle := v.angle_to(direction)
			v = v.rotated(clampf(angle, -grip * dt, grip * dt))
		v += direction * acceleration * axis.length() * dt
		v *= exp(-drag * dt * 0.2)
		v = v.limit_length(top_speed)
	else:
		v *= exp(-drag * dt)
		if v.length() < 2.0: v = Vector2.ZERO
	return v
