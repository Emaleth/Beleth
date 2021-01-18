extends Spatial

onready var audio_impact = $AudioImpact


var sounds = {
	"metal" : preload("res://assets/sounds/sfx/footstep.ogg"),
	"wood" : preload("res://assets/sounds/sfx/switch.ogg")
}

	
func conf(c_point, c_normal):
	set_disable_scale(true)
	global_transform.origin = c_point
	
	var up_vector = c_point.cross(c_point + c_normal)
	look_at(c_point + c_normal, up_vector)

			

	rotation.z = deg2rad(rand_range(0, 360))
	audio_impact.play()

