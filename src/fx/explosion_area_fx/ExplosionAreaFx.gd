extends Area

onready var explosion_area = $CollisionShape
onready var visibility_check = $VisibilityCheck
onready var particles = $CPUParticles
onready var explosion_fx = $AudioStreamPlayer3D


func conf(radius):
	explosion_area.shape.radius = radius
	visibility_check.cast_to = Vector3(0, 0, -radius)
	

func explode(damage):
	particles.emitting = true
	explosion_fx.play()
	for body in get_overlapping_bodies():
		print(body.name)

		var up_vector = self.global_transform.origin.cross(body.global_transform.origin)
		visibility_check.look_at(body.global_transform.origin, up_vector)
			
		visibility_check.force_raycast_update()
		if visibility_check.is_colliding():
			var target = visibility_check.get_collider()
			print(target.name)
			if target.has_method("hit"):
				target.hit(damage)
