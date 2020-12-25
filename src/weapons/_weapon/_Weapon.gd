extends Spatial

enum fire_mode {SEMI, AUTO, BURST}
enum aim_mode {HIPFIRE, ADS}


""" // START OF WEAPON DATA // """
""" following variables can (but don't have to) be modified per each weapon """

var damage = 0
var fire_rate = 1
var permited_modes = [fire_mode.AUTO, fire_mode.BURST, fire_mode.SEMI]
var default_mode = fire_mode.AUTO
var clip_size = 666
var recoil_force = Vector3(0, 0, 0)
var spread = 0
var slug_size = 1
var sight_mat
var bullet_decal = preload("res://src/decals/Hole.tscn")
var sfx
var akimbo = false
var akimbo_offset = Vector3(0.05, 0, 0)
var ads_akimbo_z_rot = 30
var sway_x = 0.3
var sway_x_speed = 10
var sway_y = 0.3
var sway_y_speed = 10
var sway_z = 10
var sway_z_speed = 5
var animation_type = "fire"
var slider_mov_dist 
var slider = null

""" // END OF WEAPON DATA // """

var mm_v = Vector2()
var f_mode
var holder = null
var can_shoot = true

onready var sight_pivot = $SightPivot
onready var sight_holo = $SightPivot/Holo
onready var tween  = $Tween
onready var bullet = $BulletRay
onready var muzzle = $Muzzle
onready var muzzle_flash = $Muzzle/MuzzleFlash
onready var laser = $Laser
onready var audio = $Muzzle/AudioStreamPlayer3D

#var start_t
#var stop_t
	
func load_data():
	laser.set_as_toplevel(true)
	f_mode = default_mode
	sight_holo.set_surface_material(0, sight_mat)
	audio.stream = sfx
	slider = find_node("Slider")
	
	
func _process(_delta):
	point_laser(bullet.get_collision_point(), bullet.get_collision_normal())
		
		
func fire(shot_num):
	for i in shot_num:
		if clip_size > 0:
			if can_shoot == false:
				return
				
			else:
#				start_t = OS.get_ticks_msec()
				can_shoot = false
				$Timer.start((1.0 / fire_rate) - 0.015) # this function lasts aprox 15ms 
				clip_size -= 1
				audio.play()

				muzzle_flash.rotation.z = deg2rad(rand_range(0, 360))
				muzzle_flash.visible = true
				
				tween.remove_all()
				tween.interpolate_property(self, "transform:origin:z", transform.origin.z, recoil_force.z, 0.02 ,Tween.TRANS_LINEAR,Tween.EASE_OUT)
				tween.interpolate_property(slider, "transform:origin:z", transform.origin.z, slider_mov_dist, 0.02 ,Tween.TRANS_LINEAR,Tween.EASE_OUT)
				tween.start()
				yield(tween,"tween_all_completed")
				
				shoot_bullet()
				holder.view_recoil(recoil_force)
					
				muzzle_flash.visible = false
				tween.remove_all()
				tween.interpolate_property(self, "transform:origin:z", transform.origin.z, 0, ((1.0 / fire_rate) - 0.02) ,Tween.TRANS_LINEAR,Tween.EASE_IN)
				tween.interpolate_property(slider, "transform:origin:z", transform.origin.z, 0, ((1.0 / fire_rate) - 0.02) ,Tween.TRANS_LINEAR,Tween.EASE_IN)
				tween.start()
				yield(tween,"tween_all_completed")

		else:
			break
			

func sway(delta, a_mode):
	mm_v = mm_v.normalized()
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
		laser.rotation.x = deg2rad(-90)
	elif c_normal == Vector3.DOWN:
		laser.rotation.x = deg2rad(90)

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
			var target = bullet.get_collider().owner
			var b = bullet_decal.instance()
			target.add_child(b)
			b.set_rot(bullet.get_collision_point(), bullet.get_collision_normal(), muzzle.global_transform.origin)
			if target.has_method("hit"):
				target.hit(damage)
				Console.target = target


func _on_Timer_timeout():
	can_shoot = true
#	stop_t = OS.get_ticks_msec()	
#	print("bullet time = ",stop_t - start_t, " ms")
	
