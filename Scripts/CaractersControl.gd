extends Node2D

var team = [0,1,2]

onready var spawn = $Spawn
onready var pos = [$Spawn/Position1, $Spawn/Position2, $Spawn/Position3]
onready var root = $"."
onready var cam = $Camera
onready var tween = $Camera/Camera2D/CanvasLayer/Control/Tween

onready var hp = [
	$Camera/Camera2D/CanvasLayer/Control/VBoxContainer/Char1,
	$Camera/Camera2D/CanvasLayer/Control/VBoxContainer/Char2,
	$Camera/Camera2D/CanvasLayer/Control/VBoxContainer/Char3,
	$Camera/Camera2D/CanvasLayer/Control/VBoxContainer2/Char1,
	$Camera/Camera2D/CanvasLayer/Control/VBoxContainer2/Char2,
	$Camera/Camera2D/CanvasLayer/Control/VBoxContainer2/Char3
	]
onready var twe = $Camera/Camera2D/CanvasLayer/Control/VBoxContainer/Tween1


var current_char = 0
var party = null

var follow_player = true
var stay_pos = null

func _ready():
	self.add_to_group("control")
	spawn()
	party = get_tree().get_nodes_in_group("Party")
	party[0].is_playing = true
	set_max_HP()
	for i in range(party.size()):
		party[i].connect("took_damage", self, "current_HP")
		party[i].me = i
	

func _physics_process(delta):
	if follow_player:
		cam.position = party[current_char].position
	else:
		cam.position = stay_pos
	
	if !party[current_char].is_alive:
		next_char()
		pass
	
	if Input.is_action_just_pressed("UI_change"):
		next_char()
	

func next_char():
	var x = 0
	for i in range(party.size()):
		if party[i].is_alive:
			x += 1
	if x == 0:
		game_over()
		return
	
	var b = true
	x = current_char
	while(b):
		
		current_char += 1
		if current_char > party.size() - 1:
			current_char = 0
		
		if party[current_char].is_alive:
			party[x].is_playing = false
			party[current_char].is_playing = true
			b = false

func game_over():
	get_tree().reload_current_scene()

func spawn():
	for i in range(team.size()):
		var c = spawn.get_char(team[i])
		root.add_child(c)
		c.position = pos[1].position
		c.position.x += 80 * i
		c.add_to_group("Party")
		pass
	spawn.queue_free()
	pass

func current_HP(i):
	hp[i+3].value = party[i].clife
	twe.interpolate_property(hp[i],"value",hp[i].value,party[i].clife,0.3,Tween.TRANS_SINE,Tween.EASE_IN_OUT, 0.3)
	twe.start()
	#hp[i].value = party[i].clife

func set_max_HP():
	for i in range(3):
		hp[i].max_value = party[i].life
		hp[i].value = party[i].clife
		hp[i+3].max_value = party[i].life
		hp[i+3].value = party[i].clife

func set_team(chars):
	team = chars

func battle(is_in):
	for i in range(party.size()):
		party[i].is_in_battle = is_in
	










