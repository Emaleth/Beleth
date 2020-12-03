extends KinematicBody

var speed = 7
var jump = 8
var gravity = 20
var acceleration = 6
var air_acceleration = 1
var ground_acceleration = 6
var mouse_sensitivity = 0.3
var maxdeg_camera_rotation = 80


var full_contact = false

var direction = Vector3()
var velocity = Vector3()
var linear_velocity = Vector3()
var gravity_vec = Vector3()

onready var head = $Head
onready var ground_check = $GroundCheck


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _physics_process(delta):
	full_contact = ground_check.is_colliding()
	get_direction()
	calculate_gravity(delta)
	calculate_velocity(delta)
	
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
