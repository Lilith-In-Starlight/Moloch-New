extends CanvasLayer


var messages := []
var message_timer := 0.0
var generated := false
var advice := [
	"Avoid breaking your knees by not falling long distances",
	"The best way for your runs to last longer is to reduce the amount of times you're hit",
	"Finish the levels to progress through the game",
	"If you're getting bad items, try having better luck",
	"Get power ups to become able to finish the game",
	"You need at least one leg to be able to jump, make sure not to break both",
	"Kill the last boss to finish the game",
	"Blood is useful! Try and keep as much of it as possible inside your body",
	"In order to stay alive, survive a long as possible",
]

func _ready():
	$HUD/Generating/UsefulAdvice.text = advice[randi()%advice.size()]

func _process(delta):
	if generated:
		$HUD/Generating.modulate.a = move_toward($HUD/Generating.modulate.a, 0.0, 0.2)
	if not messages.empty():
		$HUD/Messages.visible = true
		message_timer += delta
		$HUD/Messages.bbcode_text = "[center]" + messages[0] + "[/center]"
		if message_timer > messages[0].length()*0.4:
			message_timer = 0.0
			messages.pop_front()
	else:
		$HUD/Messages.visible = false
	
	for i in $HUD/Wands.get_child_count():
		if Items.player_wands[i] != null:
			$HUD/Wands.get_child(i).modulate = "#ffc741"
			if Items.selected_wand == i:
				$HUD/Wands.get_child(i).modulate = "#ffbdeb"
		else:
			$HUD/Wands.get_child(i).modulate = "2a2a2a"
			if Items.selected_wand == i:
				$HUD/Wands.get_child(i).modulate = "#795887"
	
	for i in $HUD/Spells.get_child_count():
		if Items.player_wands[Items.selected_wand] != null:
			$HUD/Spells.visible = true
			var wand :Wand = Items.player_wands[Items.selected_wand]
			if i < wand.spell_capacity:
				$HUD/Spells.get_child(i).visible = true
				if i < wand.spells.size():
					match wand.spells[i]:
						"fuck you":
							$HUD/Spells.get_child(i).modulate = "#ffe2ff"
						"evilsight":
							$HUD/Spells.get_child(i).modulate = "#45ff80"
						"shatter":
							$HUD/Spells.get_child(i).modulate = "#0faa68"
						"ray":
							$HUD/Spells.get_child(i).modulate = "#00f3ff"
				else:
					$HUD/Spells.get_child(i).modulate = "2a2a2a"
			else:
				$HUD/Spells.get_child(i).visible = false
		else:
			$HUD/Spells.visible = false

func add_message(message:String):
	messages.append(message)


func _on_generated_world():
	generated = true
