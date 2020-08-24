extends StaticBody2D

var life = 50
var def = 5
var res = 5


func _ready():
	pass

func hit(damage):
	if damage < life:
		life -= damage
	else:
		queue_free()
	
	pass
