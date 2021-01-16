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
var acceleration = null
var air_acceleration = 1
var ground_acceleration = 15
var full_contact = false
var bobbing_offset = 0.03
var bobbing_rotation = 0.02
var bobbing_dir = 1
var rotation_damping = 0.5

var direction = Vector3()
var velocity = Vector3()
var linear_velocity = Vector3()
var gravity_vec = Vector3()
var current_w = 0

onready var head = $UpperBody/Head
onready var upper_body = $UpperBody
onready var bobbing_tween = Utility.create_new_tween(self)
onready var recoil_tween = Utility.create_new_tween(self)
onready var camera_ray = $UpperBody/Head/WorldCamera/CameraRay
onready var ground_check = $GroundCheck
onready var camera = $UpperBody/Head/WorldCamera
onready var camera2 = $UpperBody/Head/CharacterViewportRender/CharacterCameraViewport/CharacterCamera
onready var c_shape = $CollisionShape
onready var sk = $UpperBody/Hands/tentacles/Armature/Skeleton

onready var right_hand = {
	"ik_target" : $UpperBody/Hands/Right/IKTarget,
	"hand" : $UpperBody/Hands/Right/Hand,
	"tween" : Utility.create_new_tween(self),
	"hipfire_pos" : $UpperBody/Hands/Right/HipfirePos,
	"ads_pos" : $UpperBody/Hands/Right/AdsPos,
	"ik" : null,
	"weapon" : null,
	"follow_pos" : null
	}
	
onready var left_hand = {
	"ik_target" : $UpperBody/Hands/Left/IKTarget,
	"hand" : $UpperBody/Hands/Left/Hand,
	"tween" : Utility.create_new_tween(self),
	"hipfire_pos" : $UpperBody/Hands/Left/HipfirePos,
	"ads_pos" : $UpperBody/Hands/Left/AdsPos,
	"ik" : null,
	"weapon" : null,
	"follow_pos" : null
	}

onready var spine_ik = null
onready var audio_footstep = $AudioFootstep


func _ready():
	aim_mode = HIPFIRE
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Console.player = self
	get_weapon(Armoury.ak47) 
	get_ik_nodes()
	start_ik_chains()
	
	
func get_ik_nodes():
	spine_ik = find_node("SpineIK")
	right_hand.ik = find_node("RightHandIK")
	left_hand.ik = find_node("LeftHandIK")
	

func start_ik_chains():
	left_hand.ik.start()
	right_hand.ik.start()
	spine_ik.start()
	
	
func _physics_process(delta):
	full_contact = ground_check.is_colliding()
	get_input()
	get_direction()
#	touch_cam_dir()
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
			rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
			upper_body.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
			upper_body.rotation.x = clamp(upper_body.rotation.x, deg2rad(-maxdeg_camera_rotation), deg2rad(maxdeg_camera_rotation))
			
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
#	direction += $HUD.direction.y * transform.basis.z
#	direction += $HUD.direction.x * transform.basis.x
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
			camera2.fov = lerp(camera.fov, hipfire_cam_fov, ads_speed * delta)
			
			right_hand.hand.global_transform.origin = right_hand.hand.global_transform.origin.linear_interpolate(right_hand.hipfire_pos.global_transform.origin, ads_speed * delta)		
			left_hand.hand.global_transform.origin = left_hand.hand.global_transform.origin.linear_interpolate(left_hand.hipfire_pos.global_transform.origin, ads_speed * delta)
		
				
		ADS:
			if (right_hand.weapon && right_hand.weapon.reloading) || (left_hand.weapon && left_hand.weapon.reloading):
				aim_mode = HIPFIRE
			$HUD/Crosshair.visible = false
			bobbing_offset = h_bob_ads
			bobbing_rotation = h_rot_ads
			mouse_sensitivity = ads_mouse_sensitivity
			camera.fov = lerp(camera.fov, ads_cam_fov, ads_speed * delta)
			camera2.fov = lerp(camera.fov, ads_cam_fov, ads_speed * delta)
			
			right_hand.hand.global_transform.origin = right_hand.hand.global_transform.origin.linear_interpolate(right_hand.ads_pos.global_transform.origin, ads_speed * delta)
			left_hand.hand.global_transform.origin = left_hand.hand.global_transform.origin.linear_interpolate(left_hand.ads_pos.global_transform.origin, ads_speed * delta)
			
	
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
	var head_recoil_y = upper_body.rotation.x + deg2rad(force.y)
	head_recoil_y = clamp(head_recoil_y, deg2rad(-maxdeg_camera_rotation), deg2rad(maxdeg_camera_rotation))
	
	var possible_head_recoil_x = [-force.x, force.x]
	var head_recoil_x = deg2rad(possible_head_recoil_x[randi() % 2]) 

	recoil_tween.remove_all()
	recoil_tween.interpolate_property(upper_body, "rotation:x", upper_body.rotation.x, head_recoil_y, 0.02 ,Tween.TRANS_LINEAR, Tween.EASE_OUT)
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

	sk.clear_bones_global_pose_override()

func cycle_w(updown):
	var w = [Armoury.usp, Armoury.ak47, Armoury.mosberg_shotgun]
	current_w += updown
	current_w = clamp(current_w, 0, w.size() - 1)
	get_weapon(w[current_w])


func head_bobbing(moving):
	if is_on_ceiling() && head.translation.y < height:
		pass
	else:
		head.translation.y = lerp(head.translation.y, height, crouch_switch_speed)
		c_shape.shape.height = lerp(c_shape.shape.height, c_height, crouch_switch_speed)
		ground_check.translation.y = - (c_height - 0.05)

	if bobbing_tween.is_active():
		return
	else:
		if direction != Vector3.ZERO:
			audio_footstep.play()
		bobbing_dir *= -1
		if moving:
			bobbing_tween.remove_all()
			bobbing_tween.interpolate_property(head, "translation:y", head.translation.y, height +bobbing_offset * bobbing_dir, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			bobbing_tween.interpolate_property(head, "rotation_degrees:y", head.rotation_degrees.y, bobbing_rotation * bobbing_dir, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			bobbing_tween.start()
		else:
			bobbing_tween.remove_all()
			bobbing_tween.interpolate_property(head, "translation:y", head.translation.y, height+bobbing_offset * 0.5 * bobbing_dir, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			bobbing_tween.interpolate_property(head, "rotation_degrees:y", head.rotation_degrees.y, bobbing_rotation * 0.5 * bobbing_dir, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			bobbing_tween.start()


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
		

func hand_motion(hand, target, time = 0.3): 
	hand.follow_pos = target

	hand.tween.remove_all()
	hand.tween.interpolate_property(hand.ik_target, "transform", hand.ik_target.transform, target.transform, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	hand.tween.start()

#	print("target: " + str(target.name) + "reached")


func hand_follow():
	if not right_hand.tween.is_active() && right_hand.follow_pos:
		right_hand.ik_target.global_transform = right_hand.follow_pos.global_transform

	if not left_hand.tween.is_active() && left_hand.follow_pos:
		left_hand.ik_target.global_transform = left_hand.follow_pos.global_transform
			

#func touch_cam_dir():
#	var evrel = $HUD.cam_dir.normalized()
#	if evrel != Vector2.ZERO:
#		actor_rotation += deg2rad(-evrel.x * 4)
#		head.rotate_x(deg2rad(-evrel.y * 4))
#		head.rotation.x = clamp(head.rotation.x, deg2rad(-maxdeg_camera_rotation), deg2rad(maxdeg_camera_rotation))
#		$HUD.cam_dir = Vector2.ZERO


func weapon_sway():
	pass
	
	
	
	
	
	
