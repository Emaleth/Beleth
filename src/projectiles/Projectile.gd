extends RigidBody

var initial_force = 15
var max_collisions
var lifespan = 5
var damage = 10
var explosion_radius = 3

onready var timer = $Timer
onready var mesh = $MeshInstance
onready var collision_shape = $CollisionShape
onready var explosion_fx = $ExplosionArea


func conf(pos):
	reset()
	global_transform = pos
	apply_central_impulse(-global_transform.basis.z * initial_force)
	explosion_fx.conf(explosion_radius)
	timer.start(lifespan)
	

func _on_Timer_timeout():
	mesh.hide()
	explosion_fx.explode(damage)
	yield(get_tree().create_timer(0.5), "timeout")
	if get_parent():
		get_parent().remove_child(self)


func hit(_amount):
	mode = RigidBody.MODE_STATIC
	collision_shape.disabled = true
	yield(get_tree().create_timer(0.05), "timeout")
	mesh.hide()
	explosion_fx.explode(damage)
	yield(get_tree().create_timer(0.5), "timeout")
	print("test")
	if get_parent():
		get_parent().remove_child(self)


func reset():
	mode = RigidBody.MODE_RIGID
	collision_shape.disabled = false
	mesh.show()
