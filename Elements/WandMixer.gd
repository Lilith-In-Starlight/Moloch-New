extends Node2D

const SWAPPING_PARTICLES := preload("res://Particles/SwappingParticles.tscn")
const SWAPPING_DENIAL := preload("res://Particles/SwappingDenial.tscn")

const PROPERTIES := {
	0 : "Cast Cooldown",
	1 : "Recharge Time",
	2 : "Heat Resistance",
	3 : "Soul Resistance",
	4 : "Push Resistance",
}

var side :int = 0
var control :bool = false

var left_wand :Wand = null
var right_wand :Wand = null

var swap := 0
var uses := 0

var cost := 0.1

var Player :Character


func _ready() -> void:
	Player = get_tree().get_nodes_in_group("Player")[0]
	swap = Items.LootRNG.randi() % PROPERTIES.size()
	$Control/ButtonsToPress/Control/Label.text = "Swap " + PROPERTIES[swap]
	$PillarL/WandRenderSprite.visible = false
	$PillarR/WandRenderSprite.visible = false


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("down"):
		if not control:
			var player_wand :Wand = Items.player_wands[Items.selected_wand]
			var k :Wand
			match side:
				-1:
					k = left_wand
					left_wand = player_wand
					Items.player_wands[Items.selected_wand] = k
				1:
					k = right_wand
					right_wand = player_wand
					Items.player_wands[Items.selected_wand] = k
		else:
			if uses <= 3:
				if right_wand != null and left_wand != null:
					var n := SWAPPING_PARTICLES.instance()
					n.position = position + $Control.position + Vector2(0, -10)
					get_parent().add_child(n)
					match swap:
						0:
							var k := left_wand.spell_recharge
							left_wand.spell_recharge = right_wand.spell_recharge
							right_wand.spell_recharge = k
						1:
							var k := left_wand.full_recharge
							left_wand.full_recharge = right_wand.full_recharge
							right_wand.full_recharge = k
						2:
							var k := left_wand.heat_resistance
							left_wand.heat_resistance = right_wand.heat_resistance
							right_wand.heat_resistance = k
						3:
							var k := left_wand.soul_resistance
							left_wand.soul_resistance = right_wand.soul_resistance
							right_wand.soul_resistance = k
						4:
							var k := left_wand.push_resistance
							left_wand.push_resistance = right_wand.push_resistance
							right_wand.push_resistance = k
					swap = randi() % PROPERTIES.size()
					$Control/ButtonsToPress/Control/Label.text = "Swap " + PROPERTIES[swap]
					if randf() < 0.4:
						Player.health.poke_hole(1)
			elif uses == 4:
				var n := SWAPPING_DENIAL.instance()
				n.position = position + $Control.position + Vector2(0, -10)
				get_parent().add_child(n)
			uses += 1
	
	$PillarL/WandRenderSprite.render_wand(left_wand)
	$PillarR/WandRenderSprite.render_wand(right_wand)
	$PillarL/WandRenderSprite.visible = left_wand != null
	$PillarR/WandRenderSprite.visible = right_wand != null


func _on_PillarL_body_entered(body: Node) -> void:
	side = -1


func _on_PillarR_body_entered(body: Node) -> void:
	side = 1


func _on_Pillar_body_exited(body: Node) -> void:
	side = 0
	control = false


func _on_Control_body_entered(body: Node) -> void:
	control = true
