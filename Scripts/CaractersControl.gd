extends Node2D

var team = [0,1,2]

onready var spawn = $Spawn
onready var pos = [$Spawn/Position1, $Spawn/Position2, $Spawn/Position3]
onready var root = $"."

var current_char = 0
var party = null

func _ready():
	spawn()
	party = get_tree().get_nodes_in_group("Party")
	party[0].is_playing = true

func _physics_process(delta):
	
	if Input.is_action_just_pressed("UI_change"):
		if current_char < 2:
			party[current_char].is_playing = false
			current_char += 1
			party[current_char].is_playing = true
		else:
			party[current_char].is_playing = false
			current_char = 0
			party[current_char].is_playing = true
		
	

func spawn():
	var i = 0
	for i in range(3):
		var c = spawn.get_char(team[i])
		root.add_child(c)
		c.position = pos[i].position
		c.add_to_group("Party")
		pass
	spawn.queue_free()
	pass
