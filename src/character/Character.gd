extends KinematicBody

enum {HIPFIRE, ADS}

var aim_mode
var maxdeg_camera_rotation = 80
var mouse_sensitivity = 0
var  GUN_SWAY = 30
var MAX_CAMERA_SHAKE = 0.01
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
onready var crosshair = $Head/Camera/Hud/Crosshair


func _ready():
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
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x
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
	"""
	THIS HAS TO BE RE-DONE TO SEPARATE SWAY FROM ADS-IN, ADS-OUT
	"""
	match aim_mode:
		HIPFIRE:
			mouse_sensitivity = hipfire_mouse_sensitivity
			crosshair.show()
			camera.fov = lerp(camera.fov, hipfire_cam_fov, ads_speed * delta)
			hand.global_transform.origin = hand.global_transform.origin.linear_interpolate(hipfire_pos.global_transform.origin, ads_speed * delta)
			
		ADS:
			mouse_sensitivity = ads_mouse_sensitivity
			crosshair.hide()
			camera.fov = lerp(camera.fov, ads_cam_fov, ads_speed * delta)
			hand.global_transform.origin = hand.global_transform.origin.linear_interpolate(ads_pos.global_transform.origin, ads_speed * delta)
		
	hand.look_at(camera_ray.get_collision_point(), Vector3.UP)
