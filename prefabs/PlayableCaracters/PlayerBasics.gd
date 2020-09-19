extends KinematicBody2D

class_name PlayerBasics

var is_playing = false
var is_alive = true

signal took_damage(me)
var me = 0

#variaveis de física
var speed = 900
var grav = 25
var accel = 500
var jump = -750

var vector = Vector2()

#variaveis de status do personagem
var element = 0 # 0-Neutro / 1-Fogo / 2-água / 3-terra / 4-vento
var clan = "none"
var life = 300
var mana = 50
var atk = 10
var def = 5
var inte = 10
var res = 5
var spd = 30
var weight = 10
#Vida e mana atuais
var clife = 0
var cmana = 0

var has_dj = false #Tem pulo duplo (double jump).
var can_dj = true  #Pode utiliza-lo

var has_ad = false #Tem dash no ar (air dash).
var can_ad = true  #pode utiliza-lo.
var can_dash = true #pode utilizar dash no chão.
var dir = 0 #direção atual.
var is_dashing = false #Esta utilizando dash.
var is_ad = false #Esta utilizando air dash

var can_move = true #Pode se mover.
var can_attack = true #pode atacar.
var block_move = false #pode recuperar o pulo duplo ou dash no ar.
var is_in_battle = false #Enquanto falsa apenas segue o personagem controlado.
var delt = 0 #utilizar o delta fora do _physics_process.

var state = 0 #State atual.
var is_attacking = false #Esta atacando.

var stop_in_air = false #Gravidade não tera mais efeito se true.
var can_take_damage = true #Quando não invuneravel.

func _ready():
	clife = life
	cmana = mana
	pass

func _physics_process(delta):
	delt = delta
	if !is_ad and !stop_in_air: #não adiciona gravidade durante air dash.
		vector.y += grav #adiciona gravidade.
	var friction = false
	
	if is_playing:
		
		var x = 0
		
		if Input.is_action_just_pressed("UI_damageTest"):
			damage(20,0)
			pass
		
		if !is_dashing and can_move and !is_attacking:
			#Inputs de movimentação.
			if Input.is_action_pressed("ui_right"):
				vector.x = min(vector.x + accel, speed * spd * delta)
				x = 1
				dir = 0
				state = 1
			if Input.is_action_pressed("ui_left"):
				vector.x = max(vector.x - accel, -(speed * spd * delta))
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
			match dir:
					0:
						vector.x = (speed * spd * delta) * 4
					1:
						vector.x = -(speed * spd * delta) * 4
			
		
		if is_on_floor():
			can_dj = true
			can_ad = true
			#Input para descer de semi-solid plataforms.
			if Input.is_action_pressed("ui_down") and Input.is_action_just_pressed("ui_up"):
				self.position.y += 2
			elif Input.is_action_just_pressed("ui_up") and !is_dashing and !is_attacking:
				#Input de pulo
				vector.y = jump
			if Input.is_action_just_pressed("UI_dash") and can_dash:
				#Script de dash.
				is_dashing = true
				can_dash = false
				can_move = false
				yield(get_tree().create_timer(0.15), "timeout")
				is_dashing = false
				yield(get_tree().create_timer(0.1), "timeout")
				can_move = true
				yield(get_tree().create_timer(0.1), "timeout")
				can_dash = true
			if friction and !is_dashing: #Para lentamente / fricção
				if is_attacking:
					vector.x = lerp(vector.x, 0, 0.07)
				else:
					vector.x = lerp(vector.x, 0, 0.3)
		else:
			state = 2
			#Dash no ar.
			if Input.is_action_just_pressed("UI_dash") and has_ad and can_ad and !block_move:
				is_dashing = true
				is_ad = true
				can_ad = false
				can_move = false
				
				yield(get_tree().create_timer(0.1), "timeout")
				is_dashing = false
				is_ad = false
				yield(get_tree().create_timer(0.1), "timeout")
				can_move = true
			if Input.is_action_just_pressed("ui_up") and has_dj and can_dj and !block_move:
				#double jump.
				vector.y = jump
				can_dj = false
			if friction: #fricção reduzida
				vector.x = lerp(vector.x, 0, 0.03)
	else: #AI code
		pass #TO DO
	
	
	#Bom e velho move_and_slide, acredito dispensar apresentações kkk.
	vector = move_and_slide(vector, Vector2.UP)
	

#Função utilizada para a AI, deve ser sobrescrista no personagem.
func attack():
	pass

func damage(value, dir, kforce = 50):
	if can_take_damage:
		if clife > value:
			can_take_damage = false
			clife -= value
			emit_signal("took_damage", me)
			knockback(dir, kforce)
			yield(get_tree().create_timer(0.6), "timeout")
			can_take_damage = true
		else:
			clife = 0
			emit_signal("took_damage", me)
			death()
			knockback(dir, kforce * 0.75)
		

func knockback(dir, kforce = 200): 
	#Separado de dano para que possa ter ataques que apenas 
	#empurrem sem deixar invulneravel.
	can_move = false
	can_attack = false
	can_dash = false
	block_move = true
	
	state = -1
	if vector.y > 0:
		vector.y = -170
	else:
		vector.y -= 170
	match dir:
		0:
			vector.x = (speed/2 - weight) * delt * kforce
		1:
			vector.x = -((speed/2 - weight) * delt * kforce)
	yield(get_tree().create_timer(0.35), "timeout")
	can_move = true
	can_attack = true
	can_dash = true
	block_move = false
	

func death():
	is_alive = false
	#queue_free()
	pass
