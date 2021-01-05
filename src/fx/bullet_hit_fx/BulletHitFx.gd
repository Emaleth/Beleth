extends Spatial

onready var audio_impact = $AudioImpact


var sounds = {
	"metal" : preload("res://assets/sounds/sfx/footstep.ogg"),
	"wood" : preload("res://assets/sounds/sfx/switch.ogg")
}

	
func conf(c_point, c_normal):
	set_disable_scale(true)
	global_transform.origin = c_point


	if c_normal == Vector3.UP:
		rotation.x = deg2rad(90)
	elif c_normal == Vector3.DOWN:
		rotation.x = deg2rad(-90)
	
	else:
		look_at(c_point + c_normal, Vector3.UP)
			

	rotation.z = deg2rad(rand_range(0, 360))
	audio_impact.play()

