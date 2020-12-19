extends Spatial

export(int, "DECAL", "ROD") var mode = 0


func set_rot(c_point, c_normal, gun_pos):
	global_transform.origin = c_point
	
	if mode == 0:
		if c_normal == Vector3.UP:
			rotation.x = deg2rad(90)
		elif c_normal == Vector3.DOWN:
			rotation.x = deg2rad(-90)
		else:
			look_at(c_point + c_normal, Vector3.UP)
			
	else:
		if gun_pos == Vector3.UP:
			rotation.x = deg2rad(90)
		elif gun_pos == Vector3.DOWN:
			rotation.x = deg2rad(-90)
		else:
			look_at(gun_pos, Vector3.UP)
		
		translate(Vector3(0, 0, rand_range(0, 0.2)))

	rotation.z = deg2rad(rand_range(0, 360))
	

func _on_Timer_timeout():
	queue_free()
