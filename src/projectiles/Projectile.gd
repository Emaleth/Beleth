extends RigidBody

var initial_force = 30
var max_collisions
var lifespan = 1
var armed = false
onready var timer = $Timer


func conf(pos):
	global_transform = pos
	apply_central_impulse(-global_transform.basis.z * initial_force)
	
