extends KinematicBody

var speed = 7
var jump = 8
var gravity = 20
var h_acceleration = 6
var air_acceleration = 1
var ground_acceleration = 6
var mouse_sensitivity = 0.3
var maxdeg_camera_rotation = 80


var full_contact = false

var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()

onready var head = $Head
onready var ground_check = $GroundCheck


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _physics_process(delta):
	full_contact = ground_check.is_colliding()
	get_direction()
	calculate_gravity(delta)
	calculate_movement(delta)
	
# warning-ignore:return_value_discarded
	move_and_slide(movement, Vector3.UP)


func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-maxdeg_camera_rotation), deg2rad(maxdeg_camera_rotation))
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		
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
		h_acceleration = air_acceleration
	elif is_on_floor() and full_contact:
		gravity_vec = -get_floor_normal() * gravity
		h_acceleration = ground_acceleration
	else:
		gravity_vec = -get_floor_normal()
		h_acceleration = ground_acceleration
		
	if Input.is_action_just_pressed("jump") and (is_on_floor() or full_contact):
		gravity_vec = Vector3.UP * jump
		
		
func calculate_movement(delta):
	h_velocity = h_velocity.linear_interpolate(direction * speed, h_acceleration * delta)
	movement.z = h_velocity.z + gravity_vec.z
	movement.x = h_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
