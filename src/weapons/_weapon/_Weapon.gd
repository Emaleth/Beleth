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
var slider_mov_dist = 0
var slide_pos = Vector2.RIGHT
var mag_pos = Vector2.DOWN
var projectile = false

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

var h_grip_pos = null
var h_secondary_grip_pos = null
var h_slider_pos = null
var h_mag_pos = null
var main_hand = null
var off_hand = null

onready var tween  = $Tween
onready var bullet = $BulletRay
onready var muzzle = $Muzzle
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
#	akimbo_offset.x *= side
#	akimbo_offset.y *= side
	
	h_grip_pos = find_node("GripPos")
	h_secondary_grip_pos = find_node("SecondaryGripPos")
	h_slider_pos = find_node("SliderPos")
	h_mag_pos = find_node("MagPos")
	
	get_hands()

	get_anim_data()

	
	
func reload():
#	if clip_size == max_clip_size:
#		return
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
		tween.interpolate_property(magazine, "transform:origin:y", magazine.transform.origin.y, -0.7, 0.2 ,Tween.TRANS_CUBIC,Tween.EASE_IN)
		tween.start()
		yield(tween,"tween_all_completed")
		
		magazine.visible = false
		if self == holder.left_hand.weapon:
			yield(holder.right_hand.weapon, "free_hand")
		
		# MOVE HAND TO MAGAZINE
		holder.hand_motion(off_hand, h_mag_pos)
		
		 # ROTATE MODEL SIDE TO ACCESS MAGAZINE SLOT
		tween.remove_all()
		tween.interpolate_property(model, "rotation_degrees:z", model.rotation_degrees.z, mag_insert_rotation, 0.5 ,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
		tween.interpolate_property(model, "rotation_degrees:x", model.rotation_degrees.x, 15, 0.5 ,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
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
		
		# MOVE HAND TO REST POSITION
		holder.hand_motion(off_hand, holder)
		
		 # ROTATE MODEL FOR SLIDER PULL
		tween.remove_all()
		tween.interpolate_property(model, "rotation_degrees:z", model.rotation_degrees.z, slide_pull_rotation, 0.5 ,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
		tween.interpolate_property(model, "rotation_degrees:x", model.rotation_degrees.x, -15, 0.5 ,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
		tween.start()
		yield(tween,"tween_all_completed")
		
		# MOVE HAND TO SLIDER AND WAIT FOR IT
		holder.hand_motion(off_hand, h_slider_pos)
		yield(off_hand.tween, "tween_all_completed")
		
		 # PULL SLIDER
		tween.remove_all()
		tween.interpolate_property(slider, "transform:origin:z", slider.transform.origin.z, slider_mov_dist, 0.1 ,Tween.TRANS_CUBIC,Tween.EASE_OUT)
		tween.start()
		yield(tween,"tween_all_completed")
		
		# MOVE HAND TO REST POSITION
		holder.hand_motion(off_hand, holder)
		
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

		# MOVE HAND TO DEFAULT POSITION
		if off_hand.weapon == false: 
			holder.hand_motion(off_hand, h_secondary_grip_pos, 0.5)

		else:
			if side == 1:
				holder.hand_motion(off_hand, holder.l_weapon.h_grip_pos, 0.5)

			else:
				holder.hand_motion(off_hand, holder.r_weapon.h_grip_pos, 0.5)

		yield(off_hand.tween, "tween_all_completed")
		
		emit_signal("free_hand")
		
		
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
				
				var muzzle_flash = ObjectPool.get_item("muzzle_flash")
				muzzle.add_child(muzzle_flash)
				muzzle_flash.conf(muzzle.global_transform)

				holder.view_recoil(recoil_force)
			
				tween.remove_all()
				tween.interpolate_property(model, "transform:origin:z", model.transform.origin.z, recoil_force.z, 0.02 ,Tween.TRANS_LINEAR,Tween.EASE_OUT)
				tween.interpolate_property(slider, "transform:origin:z", slider.transform.origin.z, slider_mov_dist, 0.02 ,Tween.TRANS_LINEAR,Tween.EASE_OUT)
				tween.start()
				yield(tween,"tween_all_completed")
				
				shoot_bullet()
					
				tween.remove_all()
				tween.interpolate_property(model, "transform:origin:z", model.transform.origin.z, 0, ((1.0 / fire_rate) - 0.02) ,Tween.TRANS_LINEAR,Tween.EASE_IN)
				if clip_size > 0:
					tween.interpolate_property(slider, "transform:origin:z", slider.transform.origin.z, 0, ((1.0 / fire_rate) - 0.02) ,Tween.TRANS_LINEAR,Tween.EASE_IN)
				else:
					tween.interpolate_property(slider, "transform:origin:z", slider.transform.origin.z, slider_mov_dist * 0.7, ((1.0 / fire_rate) - 0.02) * 0.7 ,Tween.TRANS_LINEAR,Tween.EASE_IN)
				tween.start()
	
			
func shoot_bullet():
	for shot in slug_size:
		if projectile == false:
			var bs = Vector2(rand_range(-1, 1), rand_range(-1, 1))
			if bs.length() > 1:
				bs = bs.normalized()
			bullet.rotate_x(deg2rad(bs.y * spread))
			bullet.rotate_y(deg2rad(bs.x * spread))
			bullet.force_raycast_update()
			bullet.rotation = Vector3(0, 0, 0)
			if bullet.is_colliding():
				var target = bullet.get_collider()
				var smoke  = ObjectPool.get_item("gunfire_smoke")
				get_tree().get_root().add_child(smoke)
				smoke.conf(muzzle.global_transform)
				var trail = ObjectPool.get_item("bullet_trail")
				get_tree().get_root().add_child(trail)
				trail.conf(muzzle.global_transform.origin, bullet.get_collision_point())
				var hole = ObjectPool.get_item("bullet_hole")
				target.add_child(hole)
				hole.conf(bullet.get_collision_point(), bullet.get_collision_normal())
				if target.has_method("hit"):
					target.hit(damage)
					Console.target = target
		else:
			var smoke  = ObjectPool.get_item("gunfire_smoke")
			get_tree().get_root().add_child(smoke)
			smoke.conf(muzzle.global_transform)
			var frag = ObjectPool.get_item("granade")
			get_tree().get_root().add_child(frag)
			frag.conf(muzzle.global_transform)


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
	
	
	 
func get_hands():
	match side:
		1:
			main_hand = holder.right_hand
			off_hand = holder.left_hand

		-1:
			main_hand = holder.left_hand
			off_hand = holder.right_hand
			
	holder.hand_motion(main_hand, h_grip_pos)
	if off_hand.weapon == false:
		holder.hand_motion(off_hand, h_secondary_grip_pos)

	
