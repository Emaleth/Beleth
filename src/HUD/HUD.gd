extends Control

enum {HIPFIRE, ADS}

var actor = null

onready var crosshair = $Crosshair


func _ready():
	actor = get_parent()
	
	
func _process(delta):
	if actor:
		match actor.aim_mode:
			HIPFIRE:
				crosshair.modulate.a = lerp(crosshair.modulate.a, 1, 15 * delta)
			ADS:
				crosshair.modulate.a = lerp(crosshair.modulate.a, 0, 15 * delta)
