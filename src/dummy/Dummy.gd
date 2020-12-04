extends KinematicBody


var health = 100

onready var anim = $Ybot/AnimationPlayer


func _ready():
	anim.play("Breathing Idle-loop")
	

func _physics_process(_delta):
	if get_parent().get_node("Character"):
		look_at(get_parent().get_node("Character").global_transform.origin, Vector3.UP)


func hit(amount):
	health -= amount
	health = max(health, 0)
	if health == 0:
		queue_free()


