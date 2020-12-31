extends Spatial

enum {SEMI, AUTO, BURST}


""" // START OF WEAPON DATA // """
""" following variables can (but don't have to) be modified per each weapon """

var damage = 0
var fire_rate = 1
var permited_modes = [AUTO, BURST, SEMI]
var max_clip_size = 1
var recoil_force = Vector3(0, 0, 0)
var spread = 0
var slug_size = 1
var akimbo = false
var akimbo_offset = Vector3(0.05, -0.015, -0.1)
var ads_akimbo_z_rot = 30
var slider_mov_dist = 0
var mag_reload_rot = 0
var slide_pos = Vector2.RIGHT
var mag_pos = Vector2.DOWN

""" // END OF WEAPON DATA // """


var fire_mode = null
var slider = null
var magazine = null
var holder = null
var can_shoot = true
var clip_size = 0
var reloading = false
var side = 1
var model = null
var slide_pull_rotation = 0
var mag_insert_rotation = 0


onready var tween  = $Tween
onready var bullet = $BulletRay
onready var muzzle = $Muzzle
onready var muzzle_flash = $Muzzle/MuzzleFlash
onready var audio_fire = $Muzzle/AudioFire
onready var audio_empty_mag = $AudioEmpty
onready var audio_slider = $AudioSlide
onready var audio_mag_out = $AudioMagOut
onready var audio_mag_in = $AudioMagIn

signal free_hand


func load_data():
	clip_size = max_clip_size
	fire_mode = permited_modes[0]
	slider = find_node("Slider")
	magazine = find_node("Magazine")
	model = slider.get_parent()
	akimbo_offset.x *= side
	akimbo_offset.y *= side
	get_anim_data()
	
	
func reload():
	if clip_size == max_clip_size:
		return
	if reloading == false:
		reloading = true
		if tween.is_active():
			yield(tween,"tween_all_completed")
		
		# MOVE GUN UP
		tween.remove_all()
		tween.interpolate_property(model, "transform:origin:y", model.transform.origin.y, 0.1, 0.2 ,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
		tween.interpolate_property(model, "rotation_degrees:x", model.rotation_degrees.x, -2, 0.2 ,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
		tween.start()
		yield(tween,"tween_all_completed")
		
		# SHAKE GUN DOWN
		tween.remove_all()
		tween.interpolate_property(model, "transform:origin:y", model.transform.origin.y, 0.0, 0.2 ,Tween.TRANS_BACK,Tween.EASE_OUT)
		tween.interpolate_property(model, "rotation_degrees:x", model.rotation_degrees.x, 5, 0.2 ,Tween.TRANS_BACK,Tween.EASE_OUT)
		tween.start()
		yield(tween,"tween_all_completed")
		
		 # MAGAZINE OUT
		audio_mag_out.play()
		tween.remove_all()
		tween.interpolate_property(model, "transform:origin:y", model.transform.origin.y, 0.0, 0.1 ,Tween.TRANS_BOUNCE,Tween.EASE_OUT)
		tween.interpolate_property(magazine, "transform:origin:y", magazine.transform.origin.y, -0.7, 0.3 ,Tween.TRANS_CUBIC,Tween.EASE_IN)
		tween.interpolate_property(magazine, "rotation_degrees:x", magazine.rotation_degrees.x, mag_reload_rot, 0.3 ,Tween.TRANS_CUBIC,Tween.EASE_IN)
		tween.start()
		yield(tween,"tween_all_completed")
		
		magazine.visible = false
		if self == holder.l_weapon:
			yield(holder.r_weapon, "free_hand")
		
		 # ROTATE MODEL SIDE TO ACCESS MAGAZINE SLOT
		tween.remove_all()
		tween.interpolate_property(model, "rotation_degrees:z", model.rotation_degrees.z, mag_insert_rotation, 0.5 ,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
		tween.interpolate_property(model, "rotation_degrees:x", model.rotation_degrees.x, 30, 0.5 ,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
		tween.start()
		yield(tween,"tween_all_completed")
		
		magazine.visible = true
		
		 # MAGAZINE IN
		tween.remove_all()
		tween.interpolate_property(magazine, "transform:origin:y", magazine.transform.origin.y, 0.0, 0.2 ,Tween.TRANS_CUBIC,Tween.EASE_OUT)
		tween.interpolate_property(magazine, "rotation_degrees:x", magazine.rotation_degrees.x, 0.0, 0.2 ,Tween.TRANS_CUBIC,Tween.EASE_OUT)
		tween.start()
		yield(tween,"tween_all_completed")
		
		audio_mag_in.play()
		
		 # ROTATE MODEL FOR SLIDER PULL
		tween.remove_all()
		tween.interpolate_property(model, "rotation_degrees:z", model.rotation_degrees.z, slide_pull_rotation, 0.5 ,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
		tween.interpolate_property(model, "rotation_degrees:x", model.rotation_degrees.x, -15, 0.5 ,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
		tween.start()
		yield(tween,"tween_all_completed")
		
		 # PULL SLIDER
		tween.remove_all()
		tween.interpolate_property(slider, "transform:origin:z", slider.transform.origin.z, slider_mov_dist, 0.1 ,Tween.TRANS_CUBIC,Tween.EASE_OUT)
		tween.start()
		yield(tween,"tween_all_completed")
		
		emit_signal("free_hand")
		
		 # PUSH SLIDER # ROTATE MODEL NORMAL
		audio_slider.play()
		tween.remove_all()
		tween.interpolate_property(slider, "transform:origin:z", slider.transform.origin.z, 0, ((1.0 / fire_rate) - 0.02) ,Tween.TRANS_LINEAR,Tween.EASE_IN)
		tween.interpolate_property(model, "rotation_degrees:z", model.rotation_degrees.z, 0, 0.5 ,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
		tween.interpolate_property(model, "rotation_degrees:x", model.rotation_degrees.x, 0, 0.5 ,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
		tween.start()
		yield(tween,"tween_all_completed")

		clip_size = max_clip_size
		reloading = false
		
		
func fire():
	if reloading == false:
		if clip_size <= 0:
			if can_shoot:
				can_shoot = false
				$Timer.start((1.0 / fire_rate) - 0.015) # this function lasts aprox. 15ms 
				audio_empty_mag.play()
			
		else:
			if can_shoot:
				can_shoot = false
				$Timer.start((1.0 / fire_rate) - 0.015) # this function lasts aprox. 15ms 
				clip_size -= 1
				audio_fire.play()

				muzzle_flash.rotation.z = deg2rad(rand_range(0, 360))
				muzzle_flash.visible = true
			
				tween.remove_all()
				tween.interpolate_property(model, "transform:origin:z", model.transform.origin.z, recoil_force.z, 0.02 ,Tween.TRANS_LINEAR,Tween.EASE_OUT)
				tween.interpolate_property(slider, "transform:origin:z", slider.transform.origin.z, slider_mov_dist, 0.02 ,Tween.TRANS_LINEAR,Tween.EASE_OUT)
				tween.start()
				yield(tween,"tween_all_completed")
				
				shoot_bullet()
				holder.view_recoil(recoil_force)
				muzzle_flash.visible = false
					
				tween.remove_all()
				tween.interpolate_property(model, "transform:origin:z", model.transform.origin.z, 0, ((1.0 / fire_rate) - 0.02) ,Tween.TRANS_LINEAR,Tween.EASE_IN)
				if clip_size > 0:
					tween.interpolate_property(slider, "transform:origin:z", slider.transform.origin.z, 0, ((1.0 / fire_rate) - 0.02) ,Tween.TRANS_LINEAR,Tween.EASE_IN)
				else:
					tween.interpolate_property(slider, "transform:origin:z", slider.transform.origin.z, slider_mov_dist * 0.7, ((1.0 / fire_rate) - 0.02) * 0.7 ,Tween.TRANS_LINEAR,Tween.EASE_IN)
				tween.start()
	
			
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
			var decal = ObjectPool.get_item("hole")
			target.add_child(decal)
			decal.set_rot(bullet.get_collision_point(), bullet.get_collision_normal(), muzzle.global_transform.origin)
			if target.has_method("hit"):
				target.hit(damage)
				Console.target = target


func _on_Timer_timeout():
	can_shoot = true


func get_anim_data():
	if slide_pos.x == side * -1:
		pass
	else:
		match slide_pos:
			Vector2.UP:
				slide_pull_rotation = 40 * side
			Vector2.DOWN:
				slide_pull_rotation = -40 * side
			Vector2.RIGHT:
				slide_pull_rotation = 80 * side
			Vector2.LEFT:
				slide_pull_rotation = -80 * side

	match mag_pos:
		Vector2.UP:
			mag_insert_rotation = 30 * side
		Vector2.DOWN:
			mag_insert_rotation = -30 * side
		Vector2.RIGHT:
			mag_insert_rotation = 30 * side
		Vector2.LEFT:
			mag_insert_rotation = -30 * side
	
	
	 
