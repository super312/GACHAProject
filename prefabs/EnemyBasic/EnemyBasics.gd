extends KinematicBody2D

class_name enemyBasics

var speed = 300
var accel = 75
var jump_force = -550
var grav = 25

var vector = Vector2()

var life = 300
var mana = 50
var atk = 10
var def = 5
var inte = 10
var res = 5
var spd = 30

var clife = 0
var cmana = 0

var target = null #alvo atual.
var players = null #lista dos jogadores.
var get_closer = true #true - melee attacks / false - range attacks.
var attack_behind = false #inimigos que atacam enquanto fogem.
var attacking = false
var dta = 200

var gravity = true

var dir = 0
var state = 0 	#0-idle / 1-get closer\away 
				#2-run away / 3-attacking
				#4-other actions

func _ready():
	players = get_tree().get_nodes_in_group("Party") #adiciona os jogadores avariavel
	clife = life
	cmana = mana

func _physics_process(delta):
	if gravity:
		vector.y += grav
	
	if target == null:
		get_target() #encontra o alvo atual
	elif !target.is_alive:
		target = null
	else:
		match state:
			0:
				state = 1
			1:
				if get_closer:
					if is_in_range():
						state = 3
					elif target.position.y > self.position.y and Vector2(self.position.x,0).distance_to(Vector2(target.position.x,0)) < 100 and is_on_floor():
						self.position.y += 2
					elif Vector2(self.position.x,0).distance_to(Vector2(target.position.x,0)) < 100 and is_on_floor() and Vector2(self.position.y,0).distance_to(Vector2(target.position.y,0)) > 75:
						vector.y = -750
					elif target.position.x - position.x > 0:
						vector.x = min(vector.x + accel, speed * delta * 20)
					else:
						vector.x = max(vector.x - accel, -(speed * 20 * delta))
				else:
					if is_in_range() and get_target_dis() > dta:
						pass
					elif target.position.x < self.position.x:
						vector.x = min(vector.x + accel, speed * delta * 20)
					else:
						vector.x = max(vector.x - accel, -(speed * 20 * delta))
			2:
				pass
			3:
				if is_in_range() and !attacking:
					attack()
				else:
					state = 1
		
	vector = move_and_slide(vector,Vector2.UP)
	

func get_target(dis = [9999,9999,9999]):
	
	for i in range(players.size()):
		if players[i].is_alive:
			dis[i] = self.position.distance_to(players[i].position)
		pass
	
	var minv = dis[0]
	var index = 0
	
	for i in range(players.size()):
		if minv > dis[i]:
			minv = dis[i]
			index = i
			pass
		pass
	
	target = players[index]
	

func get_target_dis():
	return self.position.distance_to(target.position)

func is_behind():
	pass

func is_in_range():
	pass

func attack():
	pass

