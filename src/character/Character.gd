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

var speed = 7
var jump = 9
var gravity = 20
var acceleration = 6
var air_acceleration = 1
var ground_acceleration = 6
var full_contact = false

var r_weapon = null 
var l_weapon = null 
var direction = Vector3()
var velocity = Vector3()
var linear_velocity = Vector3()
var gravity_vec = Vector3()

onready var head = $Head
onready var camera_ray = $Head/Camera/CameraRay
onready var ground_check = $GroundCheck
onready var anim = $Ybot/AnimationPlayer
onready var camera = $Head/Camera
onready var right_hand = $RHand
onready var left_hand = $LHand
onready var right_hipfire_pos = $Head/Camera/RHipfire
onready var left_hipfire_pos = $Head/Camera/LHipfire
onready var right_ads_pos = $Head/Camera/RAds
onready var left_ads_pos = $Head/Camera/LAds
onready var tween = $Head/Tween

onready var p_frenzy = preload("res://src/weapons/p_frenzy/p_Frenzy.tscn")
onready var p_rabidity = preload("res://src/weapons/p_rabidity/p_Rabidity.tscn")


func _ready():
	get_weapon(p_rabidity)
	aim_mode = HIPFIRE
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	anim.play("Breathing Idle-loop")


func _physics_process(delta):
	full_contact = ground_check.is_colliding()
	get_direction()
	calculate_gravity(delta)
	calculate_velocity(delta)
	aim(delta)

# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector3.UP)


func _input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			if r_weapon:
				r_weapon.mm_v = event.relative.normalized()
			if l_weapon:
				l_weapon.mm_v = event.relative.normalized()
			if event.relative.y != 0:
				tween.stop_all() # THIS WORKS. IT WORKS TOO WELL IN FACT. NEED TO ADD MOUSE MOTION TO THE TWEEN.
			rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
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
		
	#
	if Input.is_action_just_pressed("semi"):
		if r_weapon.fire_mode.SEMI in r_weapon.permited_modes:
			r_weapon.f_mode = r_weapon.fire_mode.SEMI
		if l_weapon:
			if l_weapon.fire_mode.SEMI in l_weapon.permited_modes:
				l_weapon.f_mode = l_weapon.fire_mode.SEMI
	if Input.is_action_just_pressed("burst"):
		if r_weapon.fire_mode.BURST in r_weapon.permited_modes:
			r_weapon.f_mode = r_weapon.fire_mode.BURST
		if l_weapon:
			if l_weapon.fire_mode.BURST in l_weapon.permited_modes:
				l_weapon.f_mode = l_weapon.fire_mode.BURST
	if Input.is_action_just_pressed("auto"):
		if r_weapon.fire_mode.AUTO in r_weapon.permited_modes:
			r_weapon.f_mode = r_weapon.fire_mode.AUTO
		if l_weapon:
			if l_weapon.fire_mode.AUTO in l_weapon.permited_modes:
				l_weapon.f_mode = l_weapon.fire_mode.AUTO
		
		
func _process(_delta):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		match r_weapon.f_mode:
			r_weapon.fire_mode.SEMI:
				if Input.is_action_just_pressed("fire"):
					if r_weapon:
						r_weapon.fire(1)
					if l_weapon:
						l_weapon.fire(1)
					
			r_weapon.fire_mode.AUTO:
				if Input.is_action_pressed("fire"):
					if r_weapon:
						r_weapon.fire(1)
					if l_weapon:
						l_weapon.fire(1)
		
			r_weapon.fire_mode.BURST:
				if Input.is_action_just_pressed("fire"):
					if r_weapon:
						r_weapon.fire(3)
					if l_weapon:
						l_weapon.fire(3)
					
					
func get_direction():
	direction = Vector3()
	
	direction += (Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")) * transform.basis.z
	direction += (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * transform.basis.x
	
	direction = direction.normalized()
	if r_weapon:
		r_weapon.mm_v += Vector2(
			(Input.get_action_strength("move_right") - Input.get_action_strength("move_left")),
			(Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")) 
			).normalized()
	if l_weapon:
		l_weapon.mm_v += Vector2(
			(Input.get_action_strength("move_right") - Input.get_action_strength("move_left")),
			(Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward"))
			).normalized()
	
	
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
			mouse_sensitivity = hipfire_mouse_sensitivity
			camera.fov = lerp(camera.fov, hipfire_cam_fov, ads_speed * delta)
			
			right_hand.global_transform.origin = right_hand.global_transform.origin.linear_interpolate(right_hipfire_pos.global_transform.origin, ads_speed * delta)
			if r_weapon:
				r_weapon.sway(delta, HIPFIRE)
				r_weapon.align_sights(HIPFIRE)
			
			left_hand.global_transform.origin = left_hand.global_transform.origin.linear_interpolate(left_hipfire_pos.global_transform.origin, ads_speed * delta)
			if l_weapon:
				l_weapon.sway(delta, HIPFIRE)
				l_weapon.align_sights(HIPFIRE)
			
		ADS:
			mouse_sensitivity = ads_mouse_sensitivity
			camera.fov = lerp(camera.fov, ads_cam_fov, ads_speed * delta)
			
			right_hand.global_transform.origin = right_hand.global_transform.origin.linear_interpolate(right_ads_pos.global_transform.origin, ads_speed * delta)
			if r_weapon:
				r_weapon.sway(delta, ADS)
				r_weapon.align_sights(ADS)
			
			left_hand.global_transform.origin = left_hand.global_transform.origin.linear_interpolate(left_ads_pos.global_transform.origin, ads_speed * delta)
			if l_weapon:			
				r_weapon.rotation.z = lerp_angle(r_weapon.rotation.z, deg2rad(r_weapon.ads_akimbo_z_rot), ads_speed * delta)				
				l_weapon.rotation.z = lerp_angle(l_weapon.rotation.z, deg2rad(-l_weapon.ads_akimbo_z_rot), ads_speed * delta)
				l_weapon.sway(delta, ADS)
				l_weapon.align_sights(ADS)
	
	if camera_ray.global_transform.origin.distance_to(camera_ray.get_collision_point()) > 0.5:
		right_hand.look_at(camera_ray.get_collision_point(), Vector3.UP)
		left_hand.look_at(camera_ray.get_collision_point(), Vector3.UP)
	
	# RIGHT HAND
	right_hand.rotation_degrees.x = clamp(right_hand.rotation_degrees.x, -70, 70)
	right_hand.rotation_degrees.y = clamp(right_hand.rotation_degrees.y, -70, 70)
	right_hand.rotation_degrees.z = clamp(right_hand.rotation_degrees.z, 0, 0)
	# LEFT HAND
	left_hand.rotation_degrees.x = clamp(left_hand.rotation_degrees.x, -70, 70)
	left_hand.rotation_degrees.y = clamp(left_hand.rotation_degrees.y, -70, 70)
	left_hand.rotation_degrees.z = clamp(left_hand.rotation_degrees.z, 0, 0)
	
		
func view_recoil(force):
	tween.stop_all()

	tween.remove_all()
	tween.interpolate_property(head, "rotation:x", head.rotation.x, head.rotation.x + deg2rad(force.y), 0.01 ,Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(camera, "rotation:y", camera.rotation.y, head.rotation.y + deg2rad(rand_range(-force.x, force.x)), 0.01 ,Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

	yield(tween, "tween_all_completed")

	tween.remove_all()
	tween.interpolate_property(head, "rotation:x", head.rotation.x, head.rotation.x - deg2rad(force.y), 0.4 ,Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(camera, "rotation:y", camera.rotation.y, 0, 0.01 ,Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()


func get_weapon(wpn):
	for w in right_hand.get_children():
		w.queue_free()
	for w in left_hand.get_children():
			w.queue_free()
			
	r_weapon = wpn.instance()
	right_hand.add_child(r_weapon)
	r_weapon.holder = self
	right_ads_pos.transform.origin = -r_weapon.sight_pivot.transform.origin
	
	if r_weapon.akimbo == true:
		l_weapon = wpn.instance()
		left_hand.add_child(l_weapon)
		l_weapon.holder = self
		left_ads_pos.transform.origin = -l_weapon.sight_pivot.transform.origin - l_weapon.akimbo_offset
		right_ads_pos.transform.origin = -r_weapon.sight_pivot.transform.origin + r_weapon.akimbo_offset
	




