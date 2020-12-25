extends Spatial

var health = 100


func hit(amount):
	$AudioStreamPlayer3D.play()
	health -= amount
	health = max(health, 0)
	if health == 0:
		queue_free()
