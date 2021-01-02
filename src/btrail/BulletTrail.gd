extends Spatial

var lifetime = 0.05
var lenght = 0

onready var tween = $Tween
onready var mesh = $trail

	
func set_lenght(start_pos = Vector3(), end_pos = Vector3()):
	global_transform.origin = start_pos
	look_at(end_pos, Vector3.UP)
	lenght = abs(start_pos.distance_to(end_pos))
	mesh.scale.z = lenght
	mesh.transform.origin.z = -(lenght / 2)
	setup()
	
	
func setup():
	set_disable_scale(true)
	tween.remove_all()
	tween.interpolate_property(mesh, "scale:z", lenght, 0, lifetime, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(mesh, "transform:origin:z", mesh.transform.origin.z, -lenght, lifetime, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_all_completed")
	get_parent().remove_child(self)
	
