extends Spatial

var lifetime = .5

onready var tween = $Tween
onready var mesh = $smoke_vfx


func conf(pos):
	set_disable_scale(true)
	set_as_toplevel(true)
	mesh.rotation.x = deg2rad(rand_range(0, 360))
	mesh.rotation.y = deg2rad(rand_range(0, 360))
	mesh.rotation.z = deg2rad(rand_range(0, 360))
	global_transform = pos
	
	tween.remove_all()
	for i in mesh.get_children():
		var material = i.get_surface_material(0)
		tween.interpolate_property(material, "albedo_color:a", .1, 0, lifetime, Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.interpolate_property(mesh, "scale", Vector3(1, 1, 1), Vector3(2, 2, 2), lifetime, Tween.TRANS_CUBIC,Tween.EASE_OUT)
	tween.interpolate_property(mesh, "transform:origin:y", 0, .2, lifetime, Tween.TRANS_CUBIC,Tween.EASE_IN)
	tween.interpolate_property(mesh, "transform:origin:z", 0, -1, lifetime, Tween.TRANS_CUBIC,Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	
	get_parent().remove_child(self)
