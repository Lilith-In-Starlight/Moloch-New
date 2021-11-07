extends RayCast2D


var CastInfo := SpellCastInfo.new()

func _ready() -> void:
	CastInfo.set_position(self)
	CastInfo.set_goal()
	var angle := CastInfo.get_angle(self)
	cast_to = CastInfo.vector_from_angle(angle, 500)
	force_raycast_update()
	var goal := cast_to
	if is_colliding():
		goal = (get_collision_point() - position) + get_collision_normal()*Vector2(3,10.5)
	else:
		print("f")
	CastInfo.teleport_caster(goal)
	queue_free()
	
