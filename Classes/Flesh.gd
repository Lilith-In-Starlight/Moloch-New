extends Flesh

class_name LegacyFlesh


signal hole_poked
signal holes_poked(amount)
signal bled
signal broken_leg(amount)
signal impacted_body_top(force)
signal impacted_body_side(force)
signal impacted_body_bottom(force)


enum DEATHS {
	BLED,
	HYPER,
	HYPO,
	SOUL,
	HOLES,
}

var moving_appendages := 2
var broken_moving_appendages := 0
var total_broken_appendages := 0

var needs_blood := true
var max_blood := 1.0
var poked_holes := 0
var max_holes := 200
var blood := 1.0
var blood_substance := "blood"

var weak_to_temp := true
var temperature := 30.0
var normal_temperature := 30.0
var hypertemperature := 45.0
var hypotemperature := 5.0
var death_hypertemperature := 140.0
var death_hypotemperature := -40.0
var temp_regulation := 0.002


var has_soul := true
var soul := 1.0
var needed_soul := 1.0

var is_players := false


var fire_timer := 0.0
var confusion_timer := 0.0

var damaged_from_side_effect := false
var bleeding_from_side_effect := false

var bleeding_by :Node2D


var leg_impact_resistance := 700.0
var side_resistance := 500


func shatter_soul(freq :float, from: Node2D = null, side := false) -> void:
	soul -= freq
	if freq > 0.0:
		emit_signal("was_damaged", "soul")
	damaged_from_side_effect = side
	if is_instance_valid(from):
		last_damaged_by = from
	else:
		last_damaged_by = null


func poke_hole(holes := 1, from: Node2D = null, side := false) -> void:
	poked_holes += holes
	emit_signal("hole_poked")
	emit_signal("holes_poked", holes)
	if holes > 0:
		emit_signal("was_damaged", "hole")
	damaged_from_side_effect = side
	if is_instance_valid(from):
		last_damaged_by = from
	else:
		last_damaged_by = null
	bleeding_from_side_effect = side
	bleeding_by = from


func temp_change(deg :float, from: Node2D = null, side := false) -> void:
	temperature += deg
	if deg > 0:
		emit_signal("was_damaged", "heat")
	elif deg < 0:
		emit_signal("was_damaged", "cold")
	damaged_from_side_effect = side
	if is_instance_valid(from):
		last_damaged_by = from
	else:
		last_damaged_by = null


func full_heal():
	broken_moving_appendages = 0
	poked_holes = 0
	blood = max_blood
	temperature = normal_temperature
	soul = 1.0
	emit_signal("full_healed")


func process_health(delta:float, speed:Vector2 = Vector2(0, 0)) -> void:
	temperature = move_toward(temperature, normal_temperature, temp_regulation * delta*60)
	blood -= poked_holes * (0.5+randf())*0.0005 * 60*delta
	if effects.has("onfire"):
		if fire_timer <= 0.0:
			emit_signal("effect_changed", "onfire", false)
			effects.erase("onfire")
		else:
			fire_timer -= delta
			temp_change(60*delta*0.05)
			emit_signal("was_damaged", "heat")
	if confusion_timer <= 0.0:
		emit_signal("effect_changed", "confused", false)
		effects.erase("confused")
	else:
		confusion_timer -= delta
	if ((temperature > death_hypertemperature or temperature < death_hypotemperature) and weak_to_temp) or (soul <= 0.0 and has_soul) or (blood <= 0.0 and needs_blood) or poked_holes > max_holes:
		if (guarantees == 0 and chances == 0) or (chances > 0 and randi()%3 > 0):
			if not dead:
				if temperature > death_hypertemperature and weak_to_temp:
					cause_of_death = DEATHS.HYPER
				elif temperature < death_hypotemperature and weak_to_temp:
					cause_of_death = DEATHS.HYPO
				elif soul <= 0.0 and has_soul:
					cause_of_death = DEATHS.SOUL
				elif poked_holes > max_holes:
					cause_of_death = DEATHS.HOLES
				elif blood <= 0.0 and needs_blood:
					cause_of_death = DEATHS.BLED
					
				dead = true
				emit_signal("died")
		else:
			if guarantees > 0:
				guarantees -= 1
			elif chances > 0:
				chances -= 1
			temperature = normal_temperature
			broken_moving_appendages = 0
			soul = 1.0
			blood = max_blood
			poked_holes = 0


func _instakill_pressed():
	dead = true
	emit_signal("died")


func add_effect(effect:String):
	effects[effect] = true
	emit_signal("effect_changed", effect, true)
	if effect == "onfire":
		fire_timer += 2 + randf()*10
	elif effect == "confused":
		confusion_timer += 2 + randf()*10


func break_legs():
	var brkn_legs := 1
	if randi()%3 == 0:
		brkn_legs = 2
	var d := min(broken_moving_appendages + brkn_legs, 2) - broken_moving_appendages
	if d > 0:
		emit_signal("broken_leg", d)
		total_broken_appendages += d
	broken_moving_appendages = min(broken_moving_appendages + brkn_legs, 2)


func handle_impact(force: Vector2):
	if force.y > leg_impact_resistance:
		break_legs()
		emit_signal("impacted_body_bottom", force.y)
	if force.y > leg_impact_resistance * 2:
		break_legs()
		poke_hole(1)
		emit_signal("impacted_body_bottom", force.y)
	if abs(force.x) > side_resistance:
		poke_hole(1)
		emit_signal("impacted_body_side", force.x)
	if abs(force.y) < -leg_impact_resistance:
		poke_hole(1)
		add_effect("confused")
		emit_signal("impacted_body_top", force.y)


func get_as_dict():
	var dict := {
		"moving_appendages" : moving_appendages,
		"broken_moving_appendages" : broken_moving_appendages,
		"total_broken_appendages" : total_broken_appendages,
		"needs_blood" : needs_blood,
		"max_blood" : max_blood,
		"poked_holes" : poked_holes,
		"max_holes" : max_holes,
		"blood" : blood,
		"blood_substance" : blood_substance,
		"weak_to_temp" : weak_to_temp,
		"temperature" : temperature,
		"normal_temperature" : normal_temperature,
		"hypertemperature" : hypertemperature,
		"hypotemperature" : hypotemperature,
		"death_hypertemperature" : death_hypertemperature,
		"death_hypotemperature" : death_hypotemperature,
		"temp_regulation" : temp_regulation,
		"has_soul" : has_soul,
		"needed_soul" : needed_soul,
		"soul" : soul,
		"effects" : effects,
		"fire_timer" : fire_timer,
		"confusion_timer" : confusion_timer,
		"chances" : chances,
		"guarantees" : guarantees,
		"leg_impact_resistance" : leg_impact_resistance,
		"side_resistance" : side_resistance,
	}
	return dict


func set_from_dict(dict: Dictionary):
	for i in dict:
		set(i, dict[i])

