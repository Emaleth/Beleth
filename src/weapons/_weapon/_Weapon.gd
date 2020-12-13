extends Spatial

enum fire_mode {SEMI, AUTO, BURST}
enum aim_mode {HIPFIRE, ADS}

var f_mode
# vars set per weapon
var damage
var fire_rate
var permited_modes
var default_mode
var clip_size
var recoil_force
var spread
var slug_size = 1
var sight_mat = null
var bullet_decal = preload("res://src/decals/Hole.tscn")

var sway_x = 0.3
var sway_x_speed = 10
var sway_y = 0.3
var sway_y_speed = 10
var sway_z = 10
var sway_z_speed = 5

var mm_v = Vector2()
var holder = null
var can_shoot = true
var anim : AnimationPlayer

onready var sight_pivot = $SightPivot
onready var sight_holo = $SightPivot/Holo
onready var tween = $Tween
onready var bullet = $BulletRay
onready var muzzle = $Muzzle
onready var muzzle_flash = $Muzzle/MuzzleFlash
onready var laser = $Laser

	
func load_data():
	laser.set_as_toplevel(true)
	f_mode = default_mode
	sight_holo.set_surface_material(0, sight_mat)
	anim = find_node("AnimationPlayer")
	if anim:
		anim.playback_speed = fire_rate
	
	
func _process(_delta):
	point_laser(bullet.get_collision_point(), bullet.get_collision_normal())
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		match f_mode:
			fire_mode.SEMI:
				if Input.is_action_just_pressed("fire"):
					fire(1)
					
			fire_mode.AUTO:
				if Input.is_action_pressed("fire"):
					fire(1)
		
			fire_mode.BURST:
				if Input.is_action_just_pressed("fire"):
					fire(3)
		
		
func fire(shot_num):
	var i = 1
	while i <= shot_num:
		if clip_size > 0:
			if can_shoot == false:
				return
			else:
				can_shoot = false
				clip_size -= 1
				if anim:
					anim.play("fire")
				$Muzzle/AudioStreamPlayer3D.play()
				
				shoot_bullet()
				
				holder.view_recoil(recoil_force)
				muzzle_flash.rotation.z = deg2rad(rand_range(0, 360))
				muzzle_flash.visible = true
				
				tween.playback_speed = 1
				tween.remove_all()
				tween.interpolate_property(self, "transform:origin:z", transform.origin.z, transform.origin.z + recoil_force.z, 0.01 ,Tween.TRANS_LINEAR,Tween.EASE_OUT)
				tween.start()
				yield(tween,"tween_all_completed")
				
				tween.playback_speed = fire_rate
				muzzle_flash.visible = false
				tween.remove_all()
				tween.interpolate_property(self, "transform:origin:z", transform.origin.z, 0, ((1.0 / fire_rate) - 0.01) ,Tween.TRANS_LINEAR,Tween.EASE_IN)
				tween.start()
				yield(tween,"tween_all_completed")
					
				i += 1
				can_shoot = true
		else:
			break
			
			
func _input(event):
	if Input.is_action_just_pressed("semi"):
		if fire_mode.SEMI in permited_modes:
			f_mode = fire_mode.SEMI
	if Input.is_action_just_pressed("burst"):
		if fire_mode.BURST in permited_modes:
			f_mode = fire_mode.BURST
	if Input.is_action_just_pressed("auto"):
		if fire_mode.AUTO in permited_modes:
			f_mode = fire_mode.AUTO
	
	if event is InputEventMouseMotion:
		mm_v = event.relative.normalized()


func sway(delta, a_mode):
	match a_mode:
		aim_mode.HIPFIRE:
			rotation_degrees.x = lerp(rotation_degrees.x, mm_v.y * sway_y, sway_y_speed * delta) 
			rotation_degrees.y = lerp(rotation_degrees.y, mm_v.x * sway_x, sway_x_speed * delta) 
			rotation_degrees.z = lerp(rotation_degrees.z, (mm_v.x * sway_z) * -1, sway_z_speed * delta) 
			
		aim_mode.ADS:
			rotation_degrees.x = lerp(rotation_degrees.x, mm_v.y * sway_y / 10, sway_y_speed * delta) 
			rotation_degrees.y = lerp(rotation_degrees.y, mm_v.x * sway_x / 10, sway_x_speed * delta) 
			rotation_degrees.z = lerp(rotation_degrees.z, (mm_v.x * sway_z / 10) * -1, sway_z_speed * delta) 
			
	mm_v = Vector2.ZERO


func align_sights(a_mode):
	match a_mode:
		aim_mode.HIPFIRE:
			sight_pivot.rotation = rotation
			sight_holo.rotation = rotation

		aim_mode.ADS:
			if sight_pivot.global_transform.origin.distance_to(bullet.get_collision_point()) > 1:
				sight_pivot.look_at(bullet.get_collision_point(), Vector3.UP)
				sight_holo.rotation = rotation


func point_laser(c_point, c_normal):
	laser.global_transform.origin = c_point
	
	if c_normal == Vector3.UP:
		laser.rotation = Vector3(deg2rad(-90), 0,0 )
	
	elif c_normal == Vector3.DOWN:
		laser.rotation = Vector3(deg2rad(90), 0,0 )
		
	else:
		laser.look_at(c_point - c_normal, Vector3.UP)


func shoot_bullet():
	for shot in slug_size:
		var bs = Vector2(rand_range(-1, 1), rand_range(-1, 1))
		if bs.length() > 1:
			bs = bs.normalized()
		bullet.rotate_x(deg2rad(bs.y * spread))
		bullet.rotate_y(deg2rad(bs.x * spread))
		bullet.force_raycast_update()
		bullet.rotation = Vector3(0, 0, 0)
		if bullet.is_colliding():
			var target = bullet.get_collider()
			var b = bullet_decal.instance()
			target.add_child(b)
			b.set_rot(bullet.get_collision_point(), bullet.get_collision_normal(), muzzle.global_transform.origin)
			if target.has_method("hit"):
				target.hit(damage)
