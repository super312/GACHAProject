extends KinematicBody2D

class_name EnemyBasics

signal took_hit
signal died(me)

var speed = 300
var accel = 75
var jump_force = -550
var grav = 25
var weight = 30
var delt

var me = 0
var vector = Vector2()
const buff_debuff = preload("res://prefabs/PlayableCaracters/Buffs_Debuffs.tscn")
const number = preload("res://prefabs/FloatingNumbers/FloatNumbers.tscn")

const team_id = -1
var take_hit = false

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
var continue_attack = false
var dta = 200

var can_move = true
var can_attack = true
var can_dash = true
var can_take_damage = true

var current_attack = 0

var gravity = true
var sprite
var invencible = true

var nEffects = [ #0-Poison / 1-Burning / 2-Freeze / 3-Bleeding / 4-Confusion / 5-Heavy / 6-Cursed / 7-Mark / 8-Slowlness / 9-Rage / 10-Stone
	["Poison", false, null, 0], #[0-stat, 1-is active, 2-timer, 3-stack(max3)]
	["Burning", false, null, 0], 
	["Freeze", false, null, 0], 
	["Bleeding", false, null, 0], 
	["Confusion", false, null, 0], 
	["Heavy", false, null, 0], 
	["Cursed", false, null, 0], 
	["Mark", false, null, 0], 
	["Slowness", false, null, 0], 
	["Rage", false, null, 0], 
	["Stone", false, null, 0] 
]
var imunnity = [false,false,false,false,false,false,false,false,false,false,false] #is immune to...
var mark = null
var timer = null

var dir = 0
var state = 0 	#0-idle / 1-get closer\away 
				#2-jumping / 3-run away / 4-stone\freeze
				# 5-attacking / 6-other actions

func _ready():
	players = get_tree().get_nodes_in_group("Party") #adiciona os jogadores avariavel
	clife = life
	cmana = mana
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout",self,"_on_timer_timeout")
	timer.set_wait_time(1)
	timer.start()

func _physics_process(delta):
	delt = delta
	if gravity:
		vector.y += grav
	
	if target == null:
		get_target() #encontra o alvo atual
	elif !target.is_alive:
		target = null
	elif !can_move:
		if is_on_floor():
			vector.x = lerp(vector.x, 0, 0.3)
		else:
			vector.x = lerp(vector.x, 0, 0.03)
	else:
		match state:
			-1:
				if can_move:
					state = 1
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
						dir = 1
					else:
						vector.x = max(vector.x - accel, -(speed * 20 * delta))
						dir = -1
				else:
					if is_in_range() and get_target_dis() > dta:
						pass
					elif target.position.x < self.position.x:
						vector.x = min(vector.x + accel, speed * delta * 20)
						dir = 1
					else:
						vector.x = max(vector.x - accel, -(speed * 20 * delta))
						dir = -1
			2:
				pass
			3:
				if is_in_range() and !attacking:
					attack()
					continue_attack = false
				elif continue_attack:
					attack()
				elif !attacking:
					state = 1
			4:
				pass
			5:
				if is_on_floor():
					vector.x = lerp(vector.x, 0, 0.07)
				else:
					vector.x = lerp(vector.x, 0, 0.03)
				
		
	vector = move_and_slide(vector,Vector2.UP)
	

func get_target():
	var x = rand_range(1,10)
	var dis = []
	var index = 0
	
	for i in range(players.size()):
		if players[i].is_alive:
			dis.append(self.position.distance_to(players[i].position))
		var minv = dis[0]
	
	var minv = dis[0]
	
	
	
	if x < 8:
		for i in range(dis.size()):
			if minv > dis[i]:
				minv = dis[i]
				index = i
	else:
		for i in range(dis.size()):
			if minv < dis[i]:
				minv = dis[i]
				index = i
	
	target = players[index]
	

func get_target_dis():
	return self.position.distance_to(target.position)

func is_behind():
	pass

func is_in_range():
	pass

func attack():
	pass

func end_attack():
	pass

func damage(value = 0, color = 0):
	if can_take_damage:
		if nEffects[10][1]:
			d_text("immune", 0)
			return
		
		if nEffects[2][1]:
			value += value * 0.2
			nEffects[2][1] = false
			update_effect()
		
		if clife > value:
			clife -= value
			emit_signal("took_hit")
			d_text(value, color)
		else:
			clife = 0
			d_text("DEAD", 10)
			emit_signal("took_hit")
			
			can_move = false
			can_attack = false
			can_dash = false
			yield(get_tree().create_timer(0.1), "timeout")
			death()
func d_text(value, color):
	var n = number.instance()
	$"..".add_child(n)
	n.position = self.position
	n.set_color(color)
	n.start(value)
func knockback(dir, type = 0,  vet = Vector2(1,1), kforce = 50):
	if !can_take_damage:
		return
	
	can_move = false
	can_attack = false
	can_dash = false
	state = -1
	var time = 0.2
	# 0-normal knockback / 1-special knockback / 2-just stun
	match type:
		0:
			if vector.y > 0:
				vector.y = -170
			else:
				vector.y -= 170
			vector.x = dir * (speed/2 - weight) * delt * kforce
			time = 0.4
			can_take_damage = false
			invencible()
		1:
			vet.x = vet.x * dir
			vector = vet * (speed/2 - weight) * delt * kforce
			time = 0.4
		2:
			if vector.y > 0:
				vector.y = -5
			else:
				vector.y -= 2
			vector.x = dir * (speed/2 - weight) * delt * kforce * 0.1
			time = 0.3
	yield(get_tree().create_timer(time), "timeout")
	if !nEffects[10][1] and !nEffects[2][1]:
		can_move = true
		can_attack = true
		can_dash = true
	yield(get_tree().create_timer(2.6), "timeout")
	can_take_damage = true
	
func invencible():
	if !can_take_damage:
		if invencible:
			sprite.visible = false
			invencible = false
			yield(get_tree().create_timer(0.08), "timeout")
			invencible()
		else:
			sprite.visible = true
			invencible = true
			yield(get_tree().create_timer(0.2), "timeout")
			invencible()
	else:
		sprite.visible = true
		invencible = true
func is_on_effect(effect):
	return nEffects[effect][1]
func add_effect(effect, time = 0): 
	#0-Poison / 1-Burning / 2-Freeze / 3-Bleeding / 4-Confusion
	#5-Heavy / 6-Cursed / 7-Mark / 8-Slowlness / 9-Rage / 10-Stone
	if nEffects[2][1] and effect == 10:
		return
	elif nEffects[10][1] and effect == 2:
		return
	elif imunnity[effect]:
		return
	
	
	if time == 0:
		time = get_effect_time(effect)
	if !nEffects[effect][1]: #[1-is active]
		nEffects[effect][1] = true
		nEffects[effect][3] = 1 #[3-stack]
		nEffects[effect][2] = Timer.new() #[2-timer]
		add_child(nEffects[effect][2])
		nEffects[effect][2].set_wait_time(time)
		nEffects[effect][2].start()
		update_effect()
		yield(nEffects[effect][2],"timeout")
		nEffects[effect][1] = false
		nEffects[effect][2].queue_free()
		nEffects[effect][2] = null
		nEffects[effect][3] = 0
		update_effect()
	elif nEffects[effect][3] < 3 and effect != 2 and effect != 10:
		nEffects[effect][3] += 1
		nEffects[effect][2].stop()
		nEffects[effect][2].set_wait_time(time)
		nEffects[effect][2].start()
		print(nEffects[effect][2].get_time_left())
	elif effect != 2 and effect != 10:
		nEffects[effect][2].stop()
		nEffects[effect][2].set_wait_time(time)
		nEffects[effect][2].start()
		print(nEffects[effect][2].get_time_left())
	
func get_effect_time(effect):
	#0-Poison / 1-Burning / 2-Freeze / 3-Bleeding / 4-Confusion 
	#5-Heavy / 6-Cursed / 7-Mark / 8-Slowlness / 9-Rage / 10-Stone
	match effect:
		0:
			return 15
		1:
			return 10
		2:
			return 5
		3:
			return 30
		4:
			return 10
		5:
			return 15
		6:
			return 30
		7:
			return 25
		8:
			return 35
		9:
			return 15
		10:
			return 10
func update_effect():
	if nEffects[2][1]: #Freeze.
		emit_signal("stop_attack")
		can_move = false
		can_dash = false
		can_attack = false
		state = 3
		sprite.modulate = Color(0,0,1)
	elif nEffects[10][1]: #Stone.
		emit_signal("stop_attack")
		can_move = false
		can_dash = false
		can_attack = false
		can_take_damage = false
		state = 3
		sprite.modulate = Color(1,0.55,0)
	else:
		emit_signal("stop_attack")
		can_move = true
		can_dash = true
		can_attack = true
		can_take_damage = true
		sprite.modulate = Color(1,1,1)
	
	if nEffects[7][1]:
		if mark == null:
			var d = buff_debuff.instance()
			self.add_child(d)
			d.start(3,def * 0.3 * -1,0)
			d.add_to_group("buff_debuff")
			
			var r = buff_debuff.instance()
			self.add_child(r)
			r.start(5,res * 0.3 * -1,0)
			r.add_to_group("buff_debuff")
			
			mark = [d,r]
	else:
		if mark != null:
			mark[0].clear()
			mark[1].clear()
			mark = null
func _on_timer_timeout():
	#0-Poison / 1-Burning / 2-Freeze / 3-Bleeding / 4-Confusion 
	#5-Heavy / 6-Cursed / 7-Mark / 8-Slowlness / 9-Rage / 10-Stone
	if nEffects[0][1]: #[0-Poison][1-is active]
		damage(life * (0.008 * nEffects[0][3]),0)
	if nEffects[1][1]:
		damage(life * 0.012,0)
	if nEffects[3][1]:
		damage(life * 0.005,0)

func death():
	emit_signal("died",me)
	queue_free()
	pass
