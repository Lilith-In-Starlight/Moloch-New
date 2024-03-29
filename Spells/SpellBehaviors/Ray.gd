extends RayCast2D


class_name RayBehavior

signal hit_something
signal hit_nothing

var angle := 0.0

var length := 2000


func _ready() -> void:
	set_collision_mask_bit(0, true)
	set_collision_mask_bit(1, true)
	set_collision_mask_bit(3, true)
	set_collision_mask_bit(4, true)
	set_collision_mask_bit(6, true)


func ray_setup(entity: Node2D, ray_length: float):
	entity.CastInfo.set_position(entity)
	entity.CastInfo.set_goal()
	length = ray_length
	get_angle(entity.CastInfo.goal, entity.position, entity.CastInfo)
#	if entity.CastInfo.modifiers.has("down_gravity") or entity.CastInfo.modifiers.has("up_gravity"):
#		var original_length = length 
#		length = 20
#		connect("hit_nothing", get_tree().get_nodes_in_group("GameNode")[0], "_on_casting_spell", [entity.CastInfo.spell, entity.CastInfo.wand, self])


func get_angle(start: Vector2, end: Vector2, cast_info: SpellCastInfo):
	var output := start.angle_to_point(end)
	if cast_info.modifiers.has("orthogonal"):
		var deg = rad2deg(output)
		deg = int(deg / 45) * 45
		output = deg2rad(deg)
	angle = output
	return output


func get_cast_to_from_cast_info(cast_info: SpellCastInfo) -> Vector2:
	if cast_info.modifiers.has("limited"):
		cast_info.vector_from_angle(angle, 2)
	return cast_info.vector_from_angle(angle, length)


func cast(cast_info: SpellCastInfo):
	cast_to = get_cast_to_from_cast_info(cast_info)
	force_raycast_update()
	if is_colliding():
		emit_signal("hit_something")
	else:
		emit_signal("hit_nothing")


func dry_cast(cast_info: SpellCastInfo):
	cast_to = get_cast_to_from_cast_info(cast_info)
	force_raycast_update()
	return is_colliding()


func looking_at():
	var output: Vector2 = global_position + cast_to * 2
	if is_colliding():
		var pos :Vector2 = get_collision_point()
		var normal :Vector2 = get_collision_normal()
		output = (pos - global_position).bounce(normal)*20 + pos
	
	if "down_gravity" in get_parent().CastInfo.modifiers:
		output.y += 5
	if "up_gravity" in get_parent().CastInfo.modifiers:
		output.y -= 5
	return output


func cast_from():
	if is_colliding():
		return get_collision_point() - cast_to.normalized()
	
	return cast_to + global_position
