extends Spatial

var lifespan = 0.05
onready var mesh = $muzzle_flash_vfx

func conf(pos):
	set_disable_scale(true)
#	set_as_toplevel(true)
	mesh.rotation.z = deg2rad(rand_range(0, 360))
	global_transform = pos
	yield(get_tree().create_timer(lifespan),"timeout")
	
	get_parent().remove_child(self)
	
