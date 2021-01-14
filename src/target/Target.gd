extends StaticBody

var health = 10


func hit(amount):
	$AudioStreamPlayer3D.play()
	health -= amount
	health = max(health, 0)
	if health == 0:
		visible = false
		$CollisionShape.disabled = true
		yield($AudioStreamPlayer3D,"finished")
		queue_free()
