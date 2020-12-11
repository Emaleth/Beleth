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

var weapon = null 
var direction = Vector3()
var velocity = Vector3()
var linear_velocity = Vector3()
var gravity_vec = Vector3()

onready var head = $Head
onready var camera_ray = $Head/Camera/CameraRay
onready var ground_check = $GroundCheck
onready var anim = $Ybot/AnimationPlayer
onready var camera = $Head/Camera
onready var hand = $Hand
onready var hipfire_pos = $Head/Camera/Hipfire
onready var ads_pos = $Head/Camera/Ads
onready var tween = $Head/Tween


onready var pistol = preload("res://src/weapons/pistol/Pistol.tscn")
onready var smg = preload("res://src/weapons/smg/Smg.tscn")
onready var ar = preload("res://src/weapons/ar/Ar.tscn")
onready var sr = preload("res://src/weapons/sr/Sr.tscn")
onready var shotgun = preload("res://src/weapons/shotgun/Shotgun.tscn")



func _ready():
	get_weapon(ar)
	aim_mode = HIPFIRE
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	anim.play("Breathing Idle-loop")


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
		
	
func get_direction():
	direction = Vector3()
	
	direction += (Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")) * transform.basis.z
	direction += (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * transform.basis.x
	
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
			mouse_sensitivity = hipfire_mouse_sensitivity
			camera.fov = lerp(camera.fov, hipfire_cam_fov, ads_speed * delta)
			hand.global_transform.origin = hand.global_transform.origin.linear_interpolate(hipfire_pos.global_transform.origin, ads_speed * delta)
			weapon.sway(delta, HIPFIRE)
			weapon.align_sights(HIPFIRE)
			
		ADS:
			mouse_sensitivity = ads_mouse_sensitivity
			camera.fov = lerp(camera.fov, ads_cam_fov, ads_speed * delta)
			hand.global_transform.origin = hand.global_transform.origin.linear_interpolate(ads_pos.global_transform.origin, ads_speed * delta)
			weapon.sway(delta, ADS)
			weapon.align_sights(ADS)
			
	hand.look_at(camera_ray.get_collision_point(), Vector3.UP)
	
	hand.rotation_degrees.x = clamp(hand.rotation_degrees.x, -70, 70)
	hand.rotation_degrees.y = clamp(hand.rotation_degrees.y, -70, 70)
	hand.rotation_degrees.z = clamp(hand.rotation_degrees.z, 0, 0)
	
	
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
	for w in hand.get_children():
		w.queue_free()
	weapon = wpn.instance()
	hand.add_child(weapon)
	weapon.holder = self
	ads_pos.transform.origin = -weapon.sight_pivot.transform.origin




# DEBUG #
func _on_ar_pressed():
	get_weapon(ar)


func _on_sr_pressed():
	get_weapon(sr)


func _on_pistol_pressed():
	get_weapon(pistol)


func _on_smg_pressed():
	get_weapon(smg)


func _on_shotgun_pressed():
	get_weapon(shotgun)
