extends Spatial

enum {SEMI, AUTO, BURST}

var mode
# vars set per weapon
var damage
var fire_rate
var permited_modes
var default_mode
var clip_size
var recoil_force
var v_spread
var h_spread
var slug_size = 1

var sway_x = 0.3
var sway_x_speed = 10
var sway_y = 0.3
var sway_y_speed = 10
var sway_z = 10
var sway_z_speed = 5

var mm_v = Vector2()
var holder = null

onready var sights_offset = $Sights.transform.origin
onready var anim = $AnimationPlayer
onready var bullet = $BulletRay
onready var muzzle = $Muzzle
onready var bullet_decal = preload("res://src/decals/BulletDecal.tscn")

	
func load_data():
	anim.playback_speed = fire_rate
	mode = default_mode

	
	
func _process(delta):
	sway(delta)
	match mode:
		SEMI:
			if Input.is_action_just_pressed("fire"):
				fire(1)
		AUTO:
			if Input.is_action_pressed("fire"):
				fire(1)
		
		BURST:
			if Input.is_action_just_pressed("fire"):
				fire(3)
		
		
func fire(shot_num):
	var i = 1
	while i <= shot_num:
		if clip_size > 0:
			if anim.is_playing():
				return
			else:
				anim.play("shot")
				clip_size -= 1
				$Muzzle/AudioStreamPlayer3D.play()
				if holder:
					holder.view_recoil(recoil_force)
				for shot in slug_size:
					bullet.rotate_x(deg2rad(rand_range(v_spread, -v_spread)))
					bullet.rotate_y(deg2rad(rand_range(h_spread, -h_spread)))
					bullet.force_raycast_update()
					bullet.rotation = Vector3(0, 0, 0)
					if bullet.is_colliding():
						var target = bullet.get_collider()
						var b = bullet_decal.instance()
						target.add_child(b)
						b.global_transform.origin = bullet.get_collision_point()
						b.look_at(bullet.get_collision_point() + bullet.get_collision_normal(), Vector3.UP)
						if target.has_method("hit"):
							target.hit(damage)
				yield(anim,"animation_finished")
				i += 1
		else:
			break
			
			
func _input(event):
	if Input.is_action_just_pressed("semi"):
		if SEMI in permited_modes:
			mode = SEMI
	if Input.is_action_just_pressed("burst"):
		if BURST in permited_modes:
			mode = BURST
	if Input.is_action_just_pressed("auto"):
		if AUTO in permited_modes:
			mode = AUTO
	
	if event is InputEventMouseMotion:
		mm_v = event.relative.normalized()

func sway(delta):
	rotation_degrees.x = lerp(rotation_degrees.x, mm_v.y * sway_y, sway_y_speed * delta) 
	rotation_degrees.y = lerp(rotation_degrees.y, mm_v.x * sway_x, sway_x_speed * delta) 
	rotation_degrees.z = lerp(rotation_degrees.z, (mm_v.x * sway_z) * -1, sway_z_speed * delta) 
	mm_v = Vector2.ZERO
