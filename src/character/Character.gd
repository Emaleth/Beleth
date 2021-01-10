extends KinematicBody

enum {HIPFIRE, ADS}

var aim_mode
var maxdeg_camera_rotation = 80
var mouse_sensitivity = 0
var gun_sway = 30
var ads_speed = 20
var hipfire_cam_fov = 70
var ads_cam_fov = 40
var hipfire_mouse_sensitivity = 0.2
var ads_mouse_sensitivity = 0.1
var h_bob_hip = 0.03
var h_bob_ads = 0.003
var h_rot_hip = 0.1
var h_rot_ads = 0.01

var speed
var crouch_speed = 3
var normal_speed = 7
var sprint_speed = 15
var crouch_switch_speed = 0.1

var height 
var c_height 
var normal_height = 0.85
var c_normal_height = 1.4
var crouch_height = 0.5
var c_crouch_height = 0.8

var jump = 9
var gravity = 20
var acceleration = 6
var air_acceleration = 1
var ground_acceleration = 6
var full_contact = false
var bobbing_offset = 0.03
var bobbing_rotation = 0.02
var bobbing_dir = 1
var rotation_damping = 0.5

var r_weapon = null 
var l_weapon = null 
var lh_target = null
var rh_target = null
var direction = Vector3()
var velocity = Vector3()
var linear_velocity = Vector3()
var gravity_vec = Vector3()
var current_w = 0
var actor_rotation = 0

onready var head = $Head
onready var head_tween = $Head/HeadBobbing
onready var camera_ray = $Head/Camera/CameraRay
onready var ground_check = $GroundCheck
onready var ceiling_check = $CeilingCheck
onready var camera = $Head/Camera
onready var right_hand = $RHand
onready var left_hand = $LHand
onready var right_hipfire_pos = $Head/Camera/RHipfire
onready var left_hipfire_pos = $Head/Camera/LHipfire
onready var right_ads_pos = $Head/Camera/RAds
onready var left_ads_pos = $Head/Camera/LAds
onready var tween = $Head/Recoil
onready var c_shape = $CollisionShape

onready var rhd_mesh = $RHT
onready var rhd_tween = $RHT/Tween
onready var rhik = $Synth/Armature/Skeleton/RHIK

onready var lhd_mesh = $LHT
onready var lhd_tween = $LHT/Tween
onready var lhik = $Synth/Armature/Skeleton/LHIK

onready var audio_footstep = $AudioFootstep


func _ready():
	get_weapon(Armoury.ak47)
	aim_mode = HIPFIRE
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Console.player = self

	lhik.start()
	rhik.start()
	
	
func _physics_process(delta):
	full_contact = ground_check.is_colliding()
	get_input()
	get_direction()
	touch_cam_dir()
	calculate_gravity(delta)
	calculate_velocity(delta)
	aim(delta) 
	hand_follow()
	if direction != Vector3.ZERO:
		head_bobbing(true)
	else:
		head_bobbing(false)
		
# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector3.UP)


func _input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			actor_rotation += deg2rad(-event.relative.x * mouse_sensitivity)
			head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
			head.rotation.x = clamp(head.rotation.x, deg2rad(-maxdeg_camera_rotation), deg2rad(maxdeg_camera_rotation))
			
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if Input.is_action_just_pressed("ads"):
		aim_mode = ADS
	if Input.is_action_just_released("ads"):
		aim_mode = HIPFIRE
		
		
	if Input.is_action_just_pressed("next_weapon"):
		cycle_w(1)
	if Input.is_action_just_pressed("previous_weapon"):
		cycle_w(-1)

	
func _process(_delta):
	rotation_helper()
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if Input.is_action_pressed("fire"):
			if r_weapon:
				r_weapon.fire()
			if l_weapon:
				l_weapon.fire()
				
		if Input.is_action_just_pressed("reload"):
			if r_weapon:
				r_weapon.reload()
			if l_weapon:
				l_weapon.reload()
		if r_weapon:
			$HUD.r_ammo_label.text = "Right Ammo: " + str(r_weapon.clip_size)
		else:
			$HUD.r_ammo_label.text = "No Right Weapon"
			
		if l_weapon:
			$HUD.l_ammo_label.text = "Left Ammo: " + str(l_weapon.clip_size)
		else:
			$HUD.l_ammo_label.text = "No Left Weapon"
			
		
func rotation_helper():
	rotation.y = lerp_angle(rotation.y, actor_rotation, rotation_damping)
	head.rotation.y = lerp_angle(head.rotation.y, 0, rotation_damping)
		
		
func get_direction():
	direction = Vector3()
	direction += $HUD.direction.y * transform.basis.z
	direction += $HUD.direction.x * transform.basis.x
	direction += (Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")) * transform.basis.z
	direction += (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * transform.basis.x
#
	direction = direction.normalized()
	
	
func calculate_gravity(delta):
	if not is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
		acceleration = air_acceleration
	elif is_on_floor() and full_contact:
		gravity_vec = -get_floor_normal() * gravity
		acceleration = ground_acceleration
	else:
		gravity_vec = -get_floor_normal()
		acceleration = ground_acceleration
		
	if Input.is_action_just_pressed("jump") and (is_on_floor() or full_contact):
		gravity_vec = Vector3.UP * jump
		
		
func calculate_velocity(delta):
	linear_velocity = linear_velocity.linear_interpolate(direction * speed, acceleration * delta)
	velocity.z = linear_velocity.z + gravity_vec.z
	velocity.x = linear_velocity.x + gravity_vec.x
	velocity.y = gravity_vec.y


func aim(delta):
	match aim_mode:
		HIPFIRE:
			$HUD/Crosshair.visible = true
			bobbing_offset = h_bob_hip
			bobbing_rotation = h_rot_hip
			mouse_sensitivity = hipfire_mouse_sensitivity
			camera.fov = lerp(camera.fov, hipfire_cam_fov, ads_speed * delta)
			
			right_hand.global_transform.origin = right_hand.global_transform.origin.linear_interpolate(right_hipfire_pos.global_transform.origin, ads_speed * delta)		
			left_hand.global_transform.origin = left_hand.global_transform.origin.linear_interpolate(left_hipfire_pos.global_transform.origin, ads_speed * delta)
		
			if r_weapon:
				r_weapon.rotation.z = lerp_angle(r_weapon.rotation.z, deg2rad(0), ads_speed * delta)
			if l_weapon:
				l_weapon.rotation.z = lerp_angle(r_weapon.rotation.z, deg2rad(0), ads_speed * delta)
				
		ADS:
			if (r_weapon && r_weapon.reloading) || (l_weapon && l_weapon.reloading):
				aim_mode = HIPFIRE
			$HUD/Crosshair.visible = false
			bobbing_offset = h_bob_ads
			bobbing_rotation = h_rot_ads
			mouse_sensitivity = ads_mouse_sensitivity
			camera.fov = lerp(camera.fov, ads_cam_fov, ads_speed * delta)
			
			right_hand.global_transform.origin = right_hand.global_transform.origin.linear_interpolate(right_ads_pos.global_transform.origin, ads_speed * delta)
			left_hand.global_transform.origin = left_hand.global_transform.origin.linear_interpolate(left_ads_pos.global_transform.origin, ads_speed * delta)
			
			if r_weapon:
				r_weapon.rotation.z = lerp_angle(r_weapon.rotation.z, deg2rad(0), ads_speed * delta)
			if l_weapon:
				r_weapon.rotation.z = lerp_angle(r_weapon.rotation.z, deg2rad(r_weapon.ads_akimbo_z_rot), ads_speed * delta)
				l_weapon.rotation.z = lerp_angle(l_weapon.rotation.z, deg2rad(-l_weapon.ads_akimbo_z_rot), ads_speed * delta)

	
	if camera_ray.global_transform.origin.distance_to(camera_ray.get_collision_point()) > 1.0:
		
		var rh_basis = (right_hand.global_transform.basis).get_rotation_quat()
		var rh_final_basis = (right_hand.global_transform.looking_at(camera_ray.get_collision_point(), Vector3.UP).basis).get_rotation_quat()
		var rh_rot = rh_basis.slerp(rh_final_basis, rotation_damping)
		right_hand.global_transform.basis = Basis(rh_rot)
		
		var lh_basis = (left_hand.global_transform.basis).get_rotation_quat()
		var lh_final_basis = (left_hand.global_transform.looking_at(camera_ray.get_collision_point(), Vector3.UP).basis).get_rotation_quat()
		var lh_rot = lh_basis.slerp(lh_final_basis, rotation_damping)
		left_hand.global_transform.basis = Basis(lh_rot)

	
	# RIGHT HAND
	right_hand.rotation_degrees.x = clamp(right_hand.rotation_degrees.x, -70, 70)
	right_hand.rotation_degrees.y = clamp(right_hand.rotation_degrees.y, -70, 70)
	right_hand.rotation_degrees.z = clamp(right_hand.rotation_degrees.z, 0, 0)
	# LEFT HAND
	left_hand.rotation_degrees.x = clamp(left_hand.rotation_degrees.x, -70, 70)
	left_hand.rotation_degrees.y = clamp(left_hand.rotation_degrees.y, -70, 70)
	left_hand.rotation_degrees.z = clamp(left_hand.rotation_degrees.z, 0, 0)

		
func view_recoil(force):
	tween.remove_all()
	var new_head = head.rotation.x + deg2rad(force.y)
	new_head = clamp(new_head, deg2rad(-maxdeg_camera_rotation), deg2rad(maxdeg_camera_rotation))
	tween.interpolate_property(head, "rotation:x", head.rotation.x, new_head, 0.01 ,Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(head, "rotation:y", head.rotation.y, head.rotation.y + deg2rad(rand_range(-force.x, force.x)), 0.01 ,Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	tween.start()


func get_weapon(wpn):
	for w in right_hand.get_children():
		w.queue_free()
	for w in left_hand.get_children():
		w.queue_free()
			
	r_weapon = wpn.instance()
	r_weapon.holder = self
	right_hand.add_child(r_weapon)
	right_ads_pos.transform.origin = Vector3(0, 0, r_weapon.akimbo_offset.z)
	
	if r_weapon.akimbo == true:
		l_weapon = wpn.instance()
		l_weapon.side = -1
		l_weapon.holder = self
		left_hand.add_child(l_weapon)
		right_ads_pos.transform.origin = Vector3(r_weapon.akimbo_offset.x, r_weapon.akimbo_offset.y, r_weapon.akimbo_offset.z)
		left_ads_pos.transform.origin = Vector3(l_weapon.akimbo_offset.x, l_weapon.akimbo_offset.y, l_weapon.akimbo_offset.z)


func cycle_w(updown):
	var w = [Armoury.usp, Armoury.ak47, Armoury.mosberg_shotgun]
	current_w += updown
	current_w = clamp(current_w, 0, w.size() - 1)
	get_weapon(w[current_w])


func head_bobbing(moving):
	if ceiling_check.is_colliding() && head.translation.y < height:
		pass
	else:
		head.translation.y = lerp(head.translation.y, height, crouch_switch_speed)
		c_shape.shape.height = lerp(c_shape.shape.height, c_height, crouch_switch_speed)
		ceiling_check.translation.y = (c_height - 0.05)
		ground_check.translation.y = - (c_height - 0.05)

	if head_tween.is_active():
		return
	else:
		if direction != Vector3.ZERO:
			audio_footstep.play()
		bobbing_dir *= -1
		if moving:
			head_tween.remove_all()
			head_tween.interpolate_property(camera, "translation:y", camera.translation.y, bobbing_offset * bobbing_dir, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			head_tween.interpolate_property(camera, "rotation_degrees:y", camera.rotation_degrees.y, bobbing_rotation * bobbing_dir, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			head_tween.start()
		else:
			head_tween.remove_all()
			head_tween.interpolate_property(camera, "translation:y", camera.translation.y, bobbing_offset * 0.5 * bobbing_dir, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			head_tween.interpolate_property(camera, "rotation_degrees:y", camera.rotation_degrees.y, bobbing_rotation * 0.5 * bobbing_dir, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			head_tween.start()


func get_input():
	if Input.is_action_pressed("crouch"):
		speed = crouch_speed
		height = crouch_height
		c_height = c_crouch_height
	elif Input.is_action_pressed("sprint"):
		speed = sprint_speed
		height = normal_height
		c_height = c_normal_height
	else:
		speed = normal_speed
		height = normal_height
		c_height = c_normal_height
		

func hand_motion(hand, target):
	var t = null
	
	match hand:
		rhd_mesh:
			rh_target = target
			t = rhd_tween
		lhd_mesh:
			lh_target = target
			t = lhd_tween
			
	t.reset_all()
	t.interpolate_property(hand, "global_transform", hand.global_transform, target.global_transform, 0.3 ,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
	t.start()


func hand_follow():
	if not rhd_tween.is_active():
		if rh_target:
			rhd_mesh.global_transform = rh_target.global_transform

	if not lhd_tween.is_active():
		if lh_target:
			lhd_mesh.global_transform = lh_target.global_transform

func touch_cam_dir():
	var evrel = $HUD.cam_dir.normalized()
	if evrel != Vector2.ZERO:
		actor_rotation += deg2rad(-evrel.x * 2)
		head.rotate_x(deg2rad(-evrel.y * 2))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-maxdeg_camera_rotation), deg2rad(maxdeg_camera_rotation))
		$HUD.cam_dir = Vector2.ZERO
