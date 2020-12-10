extends Spatial

onready var front = $Front
onready var rear = $Rear


func align(target, gun_rot):
	look_at(target, Vector3.UP)
	
	rotation_degrees.x = clamp(rotation_degrees.x, -10, 0)
	rotation_degrees.y = clamp(rotation_degrees.y, -10, 0)
	
	front.rotation = gun_rot
	rear.rotation = gun_rot
	
	
func def_pos(gun_rot):
	rotation = gun_rot
	
	front.rotation = gun_rot
	rear.rotation = gun_rot
