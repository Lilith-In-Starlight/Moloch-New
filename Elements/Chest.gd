extends RigidBody2D

enum TYPES {
	ITEM,
	WAND,
	SPELL,
}

var type :int = TYPES.ITEM

var contents :Item
var open := false
var Player :KinematicBody2D

func _ready():
	Player = get_tree().get_nodes_in_group("Player")[0]
	type = randi()%TYPES.size()
	match type:
		TYPES.ITEM:
			contents = Items.items.values()[randi()%Items.items.values().size()]
			$Polygon.color = "#96ff9a"
		TYPES.WAND:
			$Polygon.color = "#ff4da9"
		TYPES.SPELL:
			$Polygon.color = "#188add"

func _process(delta):
	if not open:
		if Player.position.distance_to(position) < 16:
			if Input.is_action_just_pressed("down"):
				open = true
				$Polygon.color = "#2a2a2a"
				match type:
					TYPES.ITEM:
						var new := preload("res://Items/ItemEntity.tscn").instance()
						print(contents.name)
						new.item = contents
						get_parent().add_child(new)
						new.position = position
						new.linear_velocity.x = -120 + randf()*240
					TYPES.WAND:
						for i in Items.player_wands.size():
							if Items.player_wands[i] == null:
								Items.player_wands[i] = Wand.new()
								break
					TYPES.SPELL:
						var giv :Spell = Items.spells.values()[randi()%Items.spells.values().size()]
						if giv.id == "fuck you" and randf() < 0.95:
							giv = Items.spells.values()[randi()%Items.spells.values().size()]
						elif giv.id == "push" and randf() < 0.7:
							giv = Items.spells.values()[randi()%Items.spells.values().size()]
						elif giv.id == "pull" and randf() < 0.7:
							giv = Items.spells.values()[randi()%Items.spells.values().size()]
						for i in Items.player_spells.size():
							if Items.player_spells[i] == null:
								Items.player_spells[i] = Items.spells.values()[randi()%Items.spells.values().size()]
								break
