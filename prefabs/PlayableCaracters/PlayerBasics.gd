extends KinematicBody2D

class_name PlayerBasics

#variaveis de física
var speed = 900
var grav = 25
var accel = 500
var jump = -750

var vector = Vector2()

#variaveis de status do personagem
var life = 300
var mana = 50
var atk = 10
var def = 5
var inte = 10
var res = 5
var spd = 30
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

var state = 0 #State atual.
var is_attacking = false #Esta atacando.

func _ready():
	clife = life
	cmana = mana
	pass

func _physics_process(delta):
	
	if !is_ad: #não adiciona gravidade durante air dash.
		vector.y += grav #adiciona gravidade.
	var friction = false
	
	var x = 0
	
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
	else: #Entra apenas durante o dash.
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
			vector.x = lerp(vector.x, 0, 0.3)
	else:
		state = 2
		#Dash no ar.
		if Input.is_action_just_pressed("UI_dash") and has_ad and can_ad:
			is_dashing = true
			is_ad = true
			can_ad = false
			can_move = false
			
			yield(get_tree().create_timer(0.1), "timeout")
			is_dashing = false
			is_ad = false
			yield(get_tree().create_timer(0.1), "timeout")
			can_move = true
		if Input.is_action_just_pressed("ui_up") and has_dj and can_dj:
			#double jump.
			vector.y = jump
			can_dj = false
		if friction: #fricção reduzida
			vector.x = lerp(vector.x, 0, 0.075)
	
	#Bom e velho move_and_slide, acredito dispensar apresentações kkk.
	vector = move_and_slide(vector, Vector2.UP)
	

#Funções a serem feitas.
func attack():
	pass

func damage(value):
	if clife > value:
		clife -= value
	else:
		death()

func death():
	queue_free()
