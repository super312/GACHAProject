extends KinematicBody2D

class_name PlayerBasics
#variaveis de controle

#1,2 id de cada time.
var team_id = 0 #id para PVP, pvp não implementado ainda.

var is_in_battle = false #Enquanto falsa apenas segue o personagem controlado.
var is_playing = false #Ativo quando o jogar esta no controle.
var is_alive = true 
var party = null
var current_char = null
var changes = true
var min_distance = 300

signal stop_attack
signal took_damage(me)
var me = 0
var current_attack = 0

const buff_debuff = preload("res://prefabs/PlayableCaracters/Buffs_Debuffs.tscn")
const number = preload("res://prefabs/FloatingNumbers/FloatNumbers.tscn")

#variaveis de física
var speed = 900
var grav = 25
var accel = 500
var jump = -750

var vector = Vector2()

#variaveis de status do personagem
var element = 0 # 0-Neutro / 1-Fogo / 2-água / 3-terra / 4-vento
var clan = "none"
var life = 900
var mana = 50
var atk = 10
var def = 5
var inte = 10
var res = 5
var spd = 30
var weight = 100 #não pode passar de 449+
#Vida e mana atuais
var clife = 1
var cmana = 0
#array dos status a serem utilizados.
var stat_array = [0,0,0,0,0,0,0]

var has_dj = false #Tem pulo duplo (double jump).
var can_dj = true  #Pode utiliza-lo

var has_ad = false #Tem dash no ar (air dash).
var can_ad = true  #pode utiliza-lo.
var can_dash = true #pode utilizar dash no chão.
var dir = 1 #direção atual.
var is_dashing = false #Esta utilizando dash.
var is_ad = false #Esta utilizando air dash
var dash_power = 4

var can_move = true #Pode se mover.
var can_attack = true #pode atacar.
var delt = 0 #utilizar o delta fora do _physics_process.

var state = 0 #State atual.
var is_attacking = false #Esta atacando.

var stop_in_air = false #Gravidade não tera mais efeito quando true.
var can_take_damage = true #Quando não invuneravel.

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
#0-Poison / 1-Burning / 2-Freeze / 3-Bleeding / 4-Confusion  
#5-Heavy / 6-Cursed / 7-Mark / 8-Slowlness / 9-Rage / 10-Stone
var imunnity = [false,false,false,false,false,false,false,false,false,false,false] #is immune to...
var stats_timer = null
var AI_timer = null
var sprite = null
var can_add_effects = true

var mark = null
var invencible = true

var frozen_fall = false

var n = null
func _ready():
	n = Node.new()
	self.add_child(n)
	update_stats()
	
	start_stats(0)
	clife = life
	cmana = mana
	stats_timer = Timer.new()
	add_child(stats_timer)
	stats_timer.connect("timeout",self,"_on_timer_timeout")
	stats_timer.set_wait_time(1)
	stats_timer.start()
	AI_timer = Timer.new()
	add_child(AI_timer)
	AI_timer.connect("timeout",self,"_AI_timeout")
	AI_timer.one_shot = true
	pass

func _physics_process(delta):
	randomize()
	delt = delta
	if !is_ad and !stop_in_air: #não adiciona gravidade durante air dash.
		vector.y += grav #adiciona gravidade.
	elif nEffects[10][1]:
		vector.y += grav * weight * 2
	var friction = false
	if nEffects[2][1] or nEffects[10][1]:
		friction = true
	
	if is_playing:
		
		var x = 0
		
		if Input.is_action_just_pressed("UI_damageTest"): #Q
			add_buff_debuff(2,0.5,false)
		
		if Input.is_action_just_pressed("UI_spawn_test"): #W
			add_buff_debuff(2,0.5)
		
		if !is_dashing and can_move and !is_attacking:
			#Inputs de movimentação.
			if Input.is_action_pressed("ui_right"):
				if !nEffects[4][1]:
					vector.x = min(vector.x + accel, speed * spd * delta)
					x = 1
					dir = 1
					state = 1
				else:
					vector.x = max(vector.x - accel, -(speed * spd * delta))
					x = 1
					dir = -1
					state = 1
			if Input.is_action_pressed("ui_left"):
				if !nEffects[4][1]:
					vector.x = max(vector.x - accel, -(speed * spd * delta))
					x = 1
					dir = -1
					state = 1
				else:
					vector.x = min(vector.x + accel, speed * spd * delta)
					x = 1
					dir = 1
					state = 1
			if x == 0: #Ativa fricção ao estar parado.
				friction = true
				state = 0
			
		elif is_attacking: #Adiciona fricção ao atacar.
			friction = true
		elif is_dashing: #Entra apenas durante o dash.
			#Define direção e força do dash
			vector.x = d_vet() * delta
			
		
		if is_on_floor():
			if nEffects[2][1] and frozen_fall:
				damage((life*0.01) * (grav/10 + weight/4),6)
				frozen_fall = false
			
			can_dj = true
			can_ad = true
			#Input para descer de semi-solid plataforms.
			if Input.is_action_pressed("ui_down") and Input.is_action_just_pressed("ui_up") and can_move:
				self.position.y += 2
			elif Input.is_action_just_pressed("ui_up") and !is_dashing and !is_attacking and !nEffects[5][1]:
				#Input de pulo
				vector.y = jump
			if Input.is_action_just_pressed("UI_dash") and can_dash:
				dash(1)
			if friction and !is_dashing: #Para lentamente / fricção
				if is_attacking or nEffects[2][1]:
					vector.x = lerp(vector.x, 0, 0.07)
				else:
					vector.x = lerp(vector.x, 0, 0.3)
		else:
			if nEffects[2][1]:
				frozen_fall = true
			if !is_attacking and !is_dashing and !nEffects[2][1] and !nEffects[10][1]:
				state = 2
			#Dash no ar.
			if Input.is_action_just_pressed("UI_dash") and has_ad and can_ad and can_move:
				dash(0)
			if Input.is_action_just_pressed("ui_up") and has_dj and can_dj and can_move and !nEffects[2][1]:
				#double jump.
				vector.y = jump
				can_dj = false
			if friction: #fricção reduzida
				vector.x = lerp(vector.x, 0, 0.03)
	elif is_in_battle and false: # and can_move  / AI code for battles.
		
		if rand_range(0,10) > 9.5:
			pass
		elif is_in_range() and changes:
			
			pass
		else: #persegue o inimigo.
			pass
		
		if is_on_floor():
			if nEffects[2][1] and frozen_fall:
				damage((life*0.01) * (grav/10 + weight/4),6)
				frozen_fall = false
			
		else:
			if nEffects[2][1]:
				frozen_fall = true
			
	elif can_move: #AI code outside of battles.
		
		if is_on_floor():
			if nEffects[2][1] and frozen_fall:
				damage((life*0.01) * (grav/10 + weight/4),6)
				frozen_fall = false
			
		else:
			if nEffects[2][1]:
				frozen_fall = true
			
		
		if is_dashing: #speed * spd * dash_power * dir
			if is_on_floor():
				vector.x =  d_vet() * delta
		elif party == null:
			party = get_tree().get_nodes_in_group("Party")
		elif current_char == null:
			for i in range(party.size()):
				if party[i].is_playing:
					current_char = party[i]
		elif !current_char.is_playing:
			for i in range(party.size()):
				if party[i].is_playing:
					current_char = party[i]
		else:
			if rand_range(0,5) < 4.85 and changes:
				follow_target(current_char, delta)
			elif changes:
				changes = false
				follow_target(current_char, delta, 1)
				yield(get_tree().create_timer(int(rand_range(1,6))), "timeout")
				changes = true
			else:
				follow_target(current_char, delta, 1)
	
	
	#Bom e velho move_and_slide, acredito dispensar apresentações kkk.
	vector = move_and_slide(vector, Vector2.UP)
	

func follow_target(target, delta, precision = 0): #follow a target
	match precision:
		0:
			if target.position.y > self.position.y and Vector2(target.position.x,0).distance_to(Vector2(self.position.x,0)) < 300 and is_on_floor() and Vector2(target.position.y,0).distance_to(Vector2(self.position.y,0)) > 10:
				self.position.y += 2
			elif Vector2(self.position.x,0).distance_to(Vector2(target.position.x,0)) < 300 and is_on_floor() and Vector2(self.position.y,0).distance_to(Vector2(target.position.y,0)) > 75:
				vector.y = jump
			elif Vector2(self.position.x,0).distance_to(Vector2(current_char.position.x,0)) > min_distance * 15 and can_move and can_dash:
				if is_on_floor():
					dash(1)
				elif has_ad and can_ad:
					dash(0)
			elif Vector2(self.position.x,0).distance_to(Vector2(current_char.position.x,0)) > min_distance and !is_dashing and can_move:
				if target.position.x > self.position.x:
					vector.x = min(vector.x + accel, speed * spd * delta)
					dir = 1
					state = 1
				else:
					vector.x = max(vector.x - accel, -(speed * spd * delta))
					dir = -1
					state = 1
				min_distance = int(rand_range(20,101)) * ((me + 1)/2)
			else:
				if is_on_floor():
					state = 0
					vector.x = lerp(vector.x, 0, 0.3)
				else:
					state = 2
					vector.x = lerp(vector.x, 0, 0.03)
		1:
			if Vector2(self.position.x,0).distance_to(Vector2(current_char.position.x,0)) > min_distance * 15 and can_move and can_dash:
				if is_on_floor():
					dash(1)
				elif has_ad and can_ad:
					dash(0)
			elif Vector2(self.position.x,0).distance_to(Vector2(current_char.position.x,0)) > min_distance and !is_dashing and can_move:
				if target.position.x > self.position.x:
					vector.x = min(vector.x + accel, speed * spd * delta)
					dir = 1
					state = 1
				else:
					vector.x = max(vector.x - accel, -(speed * spd * delta))
					dir = -1
					state = 1
				min_distance = int(rand_range(20,201))
			else:
				if is_on_floor():
					state = 0
					vector.x = lerp(vector.x, 0, 0.3)
				else:
					state = 2
					vector.x = lerp(vector.x, 0, 0.03)
		2:
			if target.position.y > self.position.y and Vector2(target.position.x,0).distance_to(Vector2(self.position.x,0)) < 300 and is_on_floor():
				vector.y = jump
			elif Vector2(self.position.x,0).distance_to(Vector2(target.position.x,0)) < 300 and is_on_floor() and Vector2(self.position.y,0).distance_to(Vector2(target.position.y,0)) > 75:
				self.position.y += 2
			elif Vector2(self.position.x,0).distance_to(Vector2(current_char.position.x,0)) > min_distance:
				if target.position.x > self.position.x:
					vector.x = min(vector.x + accel, speed * spd * delta)
					dir = 1
					state = 1
				else:
					vector.x = max(vector.x - accel, -(speed * spd * delta))
					dir = -1
					state = 1
				min_distance = int(rand_range(20,201))
			else:
				if is_on_floor():
					state = 0
					vector.x = lerp(vector.x, 0, 0.3)
				else:
					state = 2
					vector.x = lerp(vector.x, 0, 0.03)
			
				
	pass

#Função utilizada para a AI, deve ser sobrescrista no personagem.
func attack():
	pass

func is_in_range():
	pass

func disable_hurtbox():
	pass



func dash(type): #vector.x = ((speed * spd * delta) * 4) * dir
	match type:
		0:
			is_dashing = true
			is_ad = true
			can_ad = false
			state = 4
			yield(get_tree().create_timer(0.12), "timeout")
			is_dashing = false
			is_ad = false
		1:
			is_dashing = true
			can_dash = false
			state = 4
			yield(get_tree().create_timer(0.15), "timeout")
			is_dashing = false
			yield(get_tree().create_timer(0.2), "timeout")
			can_dash = true
func d_vet():
	return speed * spd * dash_power * dir

func heal(value):
	if !nEffects[6][1]:
		if clife + value > life:
			clife = life
		else:
			clife += value
		emit_signal("took_damage", me)

func update_stats():
	#0-LIFE / 1-MANA / 2-ATK / 3-DEF / 4-INTE / 5-RES / 6-SPD
	var buffs = n.get_children()
	
	for j in range(stat_array.size()):
		var bu = 0
		var de = []
		for i in range(buffs.size()):
			var bs = buffs[i].get_stat()
			if bs[0] == j:
				if bs[2]:
					bu += bs[1]
				else:
					de.append(bs[1])
		match j:
			0:
				stat_array[j] = life
			1:
				stat_array[j] = mana
			2:
				stat_array[j] = atk
			3:
				stat_array[j] = def
			4:
				stat_array[j] = inte
			5:
				stat_array[j] = res
			6:
				stat_array[j] = spd
		stat_array[j] += stat_array[j] * bu
		for i in range(de.size()):
			stat_array[j] -= stat_array[j] * de[i]
			
		
	print(stat_array)
	pass
func get_stats(stat): 
	#0-LIFE / 1-MANA / 2-ATK / 3-DEF / 4-INTE / 5-RES / 6-SPD
	return stat_array[stat]
func damage(value, color):
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
			d_text(value, color)
		else:
			clife = 0
			d_text("DEAD", 10)
			can_move = false
			can_attack = false
			can_dash = false
			yield(get_tree().create_timer(0.1), "timeout")
			death()
		emit_signal("took_damage", me)
		print(value)
	
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
			can_take_damage = false
			invencible()
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
		if nEffects[effect][2] != null:
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
	
func remove_effect(effect = -1): # -1 remove todos os status.
	if effect >= 0:
		nEffects[effect][1] = false
		nEffects[effect][2].queue_free()
		nEffects[effect][2] = null
		nEffects[effect][3] = 0
		update_effect()
	else:
		for i in range(11):
			nEffects[effect][1] = false
			nEffects[effect][2].queue_free()
			nEffects[effect][2] = null
			nEffects[effect][3] = 0
			update_effect()
		pass
	
	pass
func update_effect():
	if nEffects[2][1]:
		emit_signal("stop_attack")
		can_move = false
		can_dash = false
		can_attack = false
		state = 3
		sprite.modulate = Color(0,0,1)
	elif nEffects[10][1]:
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
		if clife - (life * (0.008 * nEffects[0][3])) > 0:
			clife -= life * (0.008 * nEffects[0][3]) #3 stack of poison
			emit_signal("took_damage", me)
		else:
			clife = 0
			emit_signal("took_damage", me)
			death()
	if nEffects[1][1]:
		if clife - (life * 0.012) > 0:
			clife -= life * 0.012
			emit_signal("took_damage", me)
		else:
			clife = 0
			emit_signal("took_damage", me)
			death()
	if nEffects[3][1]:
		if clife - (life * 0.005) > 0:
			clife -= life * 0.005
			emit_signal("took_damage", me)
		else:
			clife = 0
			emit_signal("took_damage", me)
			death()
	

func add_buff_debuff(stat, value, buff = true, time = 20):
	#0-LIFE / 1-MANA / 2-ATK / 3-DEF / 4-INTE / 5-RES / 6-SPD
	var b = buff_debuff.instance()
	n.add_child(b)
	b.start(stat,value,time,buff)
	b.add_to_group("buff_debuff")
	b.connect("end", self,"update_stats")
	update_stats()

func start_stats(ID):
	pass

func death():
	is_alive = false
	#queue_free()
	pass
