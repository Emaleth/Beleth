extends Spatial

onready var audio_impact = $AudioImpact


var sounds = {
	"metal" : preload("res://assets/sounds/sfx/footstep.ogg"),
	"wood" : preload("res://assets/sounds/sfx/switch.ogg")
}

	
func set_rot(c_point, c_normal, _gun_pos):
	set_disable_scale(true)
	global_transform.origin = c_point


	if c_normal == Vector3.UP:
		rotation.x = deg2rad(90)
	elif c_normal == Vector3.DOWN:
		rotation.x = deg2rad(-90)
	
	else:
		look_at(c_point + c_normal, Vector3.UP)
			
#	else:
#		if gun_pos == Vector3.UP:
#			rotation.x = deg2rad(90)
#		elif gun_pos == Vector3.DOWN:
#			rotation.x = deg2rad(-90)
#
#		else:
#			look_at(gun_pos, Vector3.UP)
#
#		translate(Vector3(0, 0, rand_range(0, 0.2)))

	rotation.z = deg2rad(rand_range(0, 360))
#	get_parent().find_node()
	audio_impact.play()

