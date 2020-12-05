extends KinematicBody


var maxdeg_camera_rotation = 80
var mouse_sensitivity = 0.2
const GUN_SWAY = 30
const ADS_GUN_SWAY = 30
var ads_speed = 20

var speed = 7
var jump = 8
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
onready var hand = $Head/Camera/Hand
onready var hand_lock = $Head/Camera/HandLock
onready var ads_pos = $Head/Camera/Ads


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	anim.play("Breathing Idle-loop")
	hand.set_as_toplevel(true)
	

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
	if Input.is_action_pressed("ads"):
		hand.global_transform.origin = ads_pos.global_transform.origin
#		hand.global_transform.origin = hand.global_transform.origin.linear_interpolate(ads_pos.global_transform.origin, ads_speed * delta)
		hand.rotation.y = lerp_angle(hand.rotation.y, rotation.y, ADS_GUN_SWAY * delta)
		hand.rotation.x = lerp_angle(hand.rotation.x, head.rotation.x, ADS_GUN_SWAY * delta)
		ads_pos.look_at(camera_ray.get_collision_point(), Vector3.UP)	
	else:
		hand.global_transform.origin = hand_lock.global_transform.origin
#		hand.global_transform.origin = hand.global_transform.origin.linear_interpolate(hand_lock.global_transform.origin, ads_speed * delta)
		hand.rotation.y = lerp_angle(hand.rotation.y, rotation.y, GUN_SWAY * delta)
		hand.rotation.x = lerp_angle(hand.rotation.x, head.rotation.x, GUN_SWAY * delta)
		hand_lock.look_at(camera_ray.get_collision_point(), Vector3.UP)
