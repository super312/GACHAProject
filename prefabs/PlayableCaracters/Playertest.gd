extends PlayerBasics

enum ATTACK{
	PUNCH1,
	PUNCH2,
	PUNCH3,
	KICK1,
	KICK2
}

func _ready():
	#has_dj = false
	pass

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_down"):
		print("aaaaa")
