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
var h_rot_hip = 0.5
var h_rot_ads = 0.05

var snap_vec = Vector3.ZERO

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
var air_acceleration = 1
var ground_acceleration = 15
var acceleration = ground_acceleration
var rotation_damping = 0.5

var direction = Vector3()
var velocity = Vector3()
var linear_velocity = Vector3()
var gravity_vec = Vector3()
var current_w = 0

onready var head = $UpperBody/Head
onready var hands = $UpperBody/Hands
onready var camera_ray = $UpperBody/Head/WorldCamera/CameraRay
onready var camera = $UpperBody/Head/WorldCamera
onready var camera2 = $UpperBody/Head/CharacterViewportRender/CharacterCameraViewport/CharacterCamera
onready var c_shape = $CollisionShape

onready var recoil_tween = Creator.request_tween(self)

var cosine_time = 0
var cosine_waves : Dictionary = {
	"vertical" : {
		"amplitude" : -0.005,
		"frequency" : 3,
		},
		
	"horizontal" : {
		"amplitude" : 0.01,
		"frequency" : 1.5,
		}
	}

onready var right_hand : Dictionary = {
	"hand" : $UpperBody/Hands/Right/Hand,
	"tween" : Creator.request_tween(self),
	"hipfire_pos" : $UpperBody/Hands/Right/HipfirePos,
	"ads_pos" : $UpperBody/Hands/Right/AdsPos,
	"weapon" : null
	}
	
onready var left_hand : Dictionary = {
	"hand" : $UpperBody/Hands/Left/Hand,
	"tween" : Creator.request_tween(self),
	"hipfire_pos" : $UpperBody/Hands/Left/HipfirePos,
	"ads_pos" : $UpperBody/Hands/Left/AdsPos,
	"weapon" : null
	}

onready var spine_ik = null
onready var audio_footstep = $AudioFootstep


func _ready():
	Relay.player = self
	aim_mode = HIPFIRE
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Console.player = self
	get_weapon(Armoury.ak47) 

	
func _physics_process(delta):
	get_input()
	get_direction()
	calculate_velocity(delta)
	aim(delta) 
	head_bobbing()

	move_and_slide(velocity + gravity_vec, Vector3.UP, true, 4, deg2rad(45), false)


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
		
		
	if Input.is_action_just_pressed("next_weapon"):
		cycle_w(1)
	if Input.is_action_just_pressed("previous_weapon"):
		cycle_w(-1)

	
func _process(delta):
	calculate_gravity(delta)

	cosine_time += delta
	if Input.is_action_pressed("fire"):
		if right_hand.weapon:
			right_hand.weapon.fire()
		if left_hand.weapon:
			left_hand.weapon.fire()
			
	if Input.is_action_just_pressed("reload"):
		if right_hand.weapon:
			right_hand.weapon.reload()
		if left_hand.weapon:
			left_hand.weapon.reload()
	if right_hand.weapon:
		$HUD.r_ammo_label.text = "Right Ammo: " + str(right_hand.weapon.clip_size)
	else:
		$HUD.r_ammo_label.text = "No Right Weapon"
		
	if left_hand.weapon:
		$HUD.l_ammo_label.text = "Left Ammo: " + str(left_hand.weapon.clip_size)
	else:
		$HUD.l_ammo_label.text = "No Left Weapon"
		
		
func get_direction():
	direction = Vector3()
	direction += (Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")) * transform.basis.z
	direction += (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * transform.basis.x
#
	direction = direction.normalized()
	
	
var floor_state = false

func calculate_gravity(delta):
	if is_on_floor():
		floor_state = true
		gravity_vec = gravity * get_floor_normal() * -1
	else:
		if floor_state:
			if gravity_vec.y < 0:
				gravity_vec = Vector3.ZERO
			floor_state = false
		else:
			gravity_vec += (Vector3.DOWN * gravity * delta)
#			
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		gravity_vec = Vector3.UP * jump

		
		
func calculate_velocity(delta):
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)


func aim(delta):
	var f =  Vector3(Utility.calculate_cosine_wave(cosine_waves.horizontal.frequency, cosine_waves.horizontal.amplitude, cosine_time), (Utility.calculate_cosine_wave(cosine_waves.vertical.frequency, cosine_waves.vertical.amplitude, cosine_time)), 0)
	match aim_mode:
		HIPFIRE:
			$HUD/Crosshair.visible = true
			mouse_sensitivity = hipfire_mouse_sensitivity
			camera.fov = lerp(camera.fov, hipfire_cam_fov, ads_speed * delta)
			camera2.fov = lerp(camera.fov, hipfire_cam_fov, ads_speed * delta)
			
			right_hand.hand.transform.origin = right_hand.hand.transform.origin.linear_interpolate(right_hand.hipfire_pos.transform.origin + f, ads_speed * delta)		
			left_hand.hand.transform.origin = left_hand.hand.transform.origin.linear_interpolate(left_hand.hipfire_pos.transform.origin + f, ads_speed * delta)
		
				
		ADS:
			if (right_hand.weapon && right_hand.weapon.reloading) || (left_hand.weapon && left_hand.weapon.reloading):
				aim_mode = HIPFIRE
			$HUD/Crosshair.visible = false
			mouse_sensitivity = ads_mouse_sensitivity
			camera.fov = lerp(camera.fov, ads_cam_fov, ads_speed * delta)
			camera2.fov = lerp(camera.fov, ads_cam_fov, ads_speed * delta)
			
			right_hand.hand.transform.origin = right_hand.hand.transform.origin.linear_interpolate(right_hand.ads_pos.transform.origin + f / 4, ads_speed * delta)
			left_hand.hand.transform.origin = left_hand.hand.transform.origin.linear_interpolate(left_hand.ads_pos.transform.origin + f / 4, ads_speed * delta)
			
	
	if camera_ray.global_transform.origin.distance_to(camera_ray.get_collision_point()) > 1.0:
		
		var rh_basis = (right_hand.hand.global_transform.basis).get_rotation_quat()
		var rh_final_basis = (right_hand.hand.global_transform.looking_at(camera_ray.get_collision_point(), Vector3.UP).basis).get_rotation_quat()
		var rh_rot = rh_basis.slerp(rh_final_basis, rotation_damping)
		right_hand.hand.global_transform.basis = Basis(rh_rot)
		
		var lh_basis = (left_hand.hand.global_transform.basis).get_rotation_quat()
		var lh_final_basis = (left_hand.hand.global_transform.looking_at(camera_ray.get_collision_point(), Vector3.UP).basis).get_rotation_quat()
		var lh_rot = lh_basis.slerp(lh_final_basis, rotation_damping)
		left_hand.hand.global_transform.basis = Basis(lh_rot)

	
	# RIGHT HAND
	right_hand.hand.rotation_degrees.x = clamp(right_hand.hand.rotation_degrees.x, -70, 70)
	right_hand.hand.rotation_degrees.y = clamp(right_hand.hand.rotation_degrees.y, -70, 70)
	right_hand.hand.rotation_degrees.z = clamp(right_hand.hand.rotation_degrees.z, 0, 0)
	# LEFT HAND
	left_hand.hand.rotation_degrees.x = clamp(left_hand.hand.rotation_degrees.x, -70, 70)
	left_hand.hand.rotation_degrees.y = clamp(left_hand.hand.rotation_degrees.y, -70, 70)
	left_hand.hand.rotation_degrees.z = clamp(left_hand.hand.rotation_degrees.z, 0, 0)

		
func view_recoil(force):
	var head_recoil_y = head.rotation.x + deg2rad(force.y)
	head_recoil_y = clamp(head_recoil_y, deg2rad(-maxdeg_camera_rotation), deg2rad(maxdeg_camera_rotation))
	
	var possible_head_recoil_x = [-force.x, force.x]
	var head_recoil_x = deg2rad(possible_head_recoil_x[randi() % 2]) 

	recoil_tween.remove_all()
	recoil_tween.interpolate_property(head, "rotation:x", head.rotation.x, head_recoil_y, 0.02 ,Tween.TRANS_LINEAR, Tween.EASE_OUT)
	recoil_tween.interpolate_property(self, "rotation:y", rotation.y, rotation.y + head_recoil_x, 0.02 ,Tween.TRANS_LINEAR, Tween.EASE_OUT)
	recoil_tween.start()


func get_weapon(wpn):
	for w in right_hand.hand.get_children():
		w.queue_free()
#	for w in left_hand.hand.get_children():
#		w.queue_free()
			
	right_hand.weapon = wpn.instance()
	right_hand.weapon.holder = self
	right_hand.hand.add_child(right_hand.weapon)


func cycle_w(updown):
	var w = [Armoury.usp, Armoury.ak47, Armoury.mosberg_shotgun]
	current_w += updown
	current_w = clamp(current_w, 0, w.size() - 1)
	get_weapon(w[current_w])


func head_bobbing():
	if is_on_ceiling() && head.translation.y < height:
		pass
	else:
		head.translation.y = lerp(head.translation.y, height, crouch_switch_speed)
		c_shape.shape.height = lerp(c_shape.shape.height, c_height, crouch_switch_speed)


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
		
