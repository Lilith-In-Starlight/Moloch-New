extends Node

class_name HurtCasterModule


var caster :Node = null


func change_temp(deg: float) -> void:
	get_parent().CastInfo.heat_caster(deg)


func push(force: Vector2) -> void:
	get_parent().CastInfo.push_caster(force)


func shatter_soul(amt: float) -> void:
	get_parent().CastInfo.drain_caster_soul(amt)
