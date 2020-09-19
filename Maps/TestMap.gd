extends Node2D

const enemy = preload("res://prefabs/EnemyBasic/EnemyBasics.tscn")

func _ready():
	pass

func _physics_process(delta):
	
	if Input.is_action_just_pressed("UI_damageTest") and false:
		var e = enemy.instance()
		self.add_child(e)
		e.position = $Position2D.position
		pass
