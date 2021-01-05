extends Node2D

const enemy = preload("res://testenemies/link/Link.tscn")
const number = preload("res://prefabs/FloatingNumbers/FloatNumbers.tscn")
var control = null

func _ready():
	control = get_tree().get_nodes_in_group("control")
	

func _process(delta):
	
	
	pass

func _on_Button_pressed():
	control[0].battle(true)
	for i in range (1):
		var e = enemy.instance()
		self.add_child(e)
		e.add_to_group("enemies")
		e.position = $Position2D.position
		e.position.x += 40 * i
		e.connect("died",self,"test_battle")

func test_battle(me):
	var test = get_tree().get_nodes_in_group("enemies")
	if test.size() < 1:
		control.battle(false)
		pass
	pass

func _on_Button2_pressed():
	var x = int(rand_range(1,31))
	var y = int(rand_range(0,6))
	var n = number.instance()
	add_child(n)
	n.set_color(y)
	n.position = $Position2D.position
	n.start(x)
	
