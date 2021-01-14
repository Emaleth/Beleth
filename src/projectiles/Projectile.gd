extends RigidBody

var initial_force = 15
var max_collisions
var lifespan = 5
onready var timer = $Timer
var damage = 10
var explosion_radius = 3

onready var explosion_fx = $ExplosionArea

func conf(pos):
	$MeshInstance.show()
	global_transform = pos
	apply_central_impulse(-global_transform.basis.z * initial_force)
	explosion_fx.conf(explosion_radius)
	timer.start(lifespan)
	


func _on_Timer_timeout():
	$MeshInstance.hide()
	explosion_fx.explode(damage)
	yield(get_tree().create_timer(0.5), "timeout")
	if get_parent():
		get_parent().remove_child(self)



func hit(_amount):
	$MeshInstance.hide()
	explosion_fx.explode(damage)
	yield(get_tree().create_timer(0.5), "timeout")
	if get_parent():
		get_parent().remove_child(self)
