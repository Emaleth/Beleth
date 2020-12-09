extends Spatial

onready var sight = $Sight


func align(target, gun_z):
	look_at(target, Vector3.UP)
	sight.rotation.z = gun_z
	
