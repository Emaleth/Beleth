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
	for i in get_overlapping_bodies():
		visibility_check.look_at(i.global_transform.origin, Vector3.UP)
		visibility_check.force_raycast_update()
		if visibility_check.is_colliding():
			var target = visibility_check.get_collider()
			if target.has_method("hit"):
				target.hit(damage)
