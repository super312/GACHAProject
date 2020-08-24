extends PlayerBasics

#state values
# 0 - IDLE  /  1 - RUNNING  /  2 - JUMPING
# 3 - DASH  /  4 - SWORD1   /  5 - SWORD2
# 6 - SWORD3/  7 - SHOOT1   /  8 - SHOOT2
# 9 - special 1  /  10 - special 2
# 11 - ARIATTACK

#Pré carrega o projetil.
const bullet = preload("res://testCaracters/Zero/Zero_Bullet.tscn")

#variaveis para simplificar o path dos objetos.
onready var sprite = $Sprite
onready var sword = $Sword_area/SWORD_HITBOX
onready var anim = $AnimationPlayer

var area = null #verificação de paredes para o teleporte (valeu pela ideia andrei).

func _ready():
	has_ad = true #Coloque como true para obter air dash (falso por padrão).
	has_dj = true #Coloque como true para obter double jump (falso por padrão).

func _physics_process(delta):
	var o = 0
	
	#altera a direção dos hitboxes.
	match dir:
		0:
			sword.position.x = 70
			$TP/area.position.x = 100
			$SHOOT_POSITION.position.x = 70
		1:
			sword.position.x = -70
			$TP/area.position.x = -100
			$SHOOT_POSITION.position.x = -70
	
	if is_on_floor():
		#Cancela o ataque areo ao atingir o chão. 
		#Futuramente adicionar animação ao pousar (landing delay).
		if is_attacking and anim.current_animation == "AIRATTACK1":
			anim.stop()
			sword.disabled = true
			is_attacking = false
			state = 0
			
		
		#verifica qual botão de ataque foi prescionado.
		if Input.is_action_just_pressed("UI_fast"):
			fast_attack()
			o = 1
		if Input.is_action_just_pressed("UI_strong"):
			strong_attack()
			o = 1
		if Input.is_action_just_pressed("UI_special1"):
			special1()
			o = 1
		if Input.is_action_just_pressed("UI_special2"):
			special2()
			o = 1
		
	else:
		if Input.is_action_just_pressed("UI_fast"):
			air_attack()
			o = 1
	
	if o == 0:
		animation()

#ataque aereo.
func air_attack():
	if state < 3:
		state = 11
		anim.play("AIRATTACK1")
		is_attacking = true
		yield(anim, "animation_finished")
		is_attacking = false
		state = 0

#Ataque rapido (z).
func fast_attack():
	if state < 3:
		state = 4
		anim.play("ATTACK1")
		is_attacking = true
		yield(anim, "animation_finished")
		is_attacking = false
		state = 0
	elif state == 4: #verifica o state/ataque atual.
		if anim.current_animation_position > 0.4: #verifica o frame da animação.
			anim.play("ATTACK2")
			if area == null:
				match dir:
					0:
						self.position.x += 140
						dir = 1
					1:
						self.position.x -= 140
						dir = 0
			state = 5
			
	elif state == 5:
		if anim.current_animation_position > 0.4:
			anim.play("ATTACK3")
			state == 6
		
	

#Ataque forte (x).
func strong_attack():
	var b = bullet.instance()
	if state < 3:
		state = 7
		anim.play("SHOOT1")
		is_attacking = true
		yield(get_tree().create_timer(0.2), "timeout")
		self.add_child(b)
		b.position = $SHOOT_POSITION.position
		b.set_bullet(atk,dir)
		yield(anim, "animation_finished")
		is_attacking = false
		state = 0
	elif state == 5:
		if anim.current_animation_position > 0.4:
			anim.play("SHOOT2")
			state = 8
			yield(get_tree().create_timer(0.2), "timeout")
			self.add_child(b)
			b.position = $SHOOT_POSITION.position
			b.set_bullet(atk,dir)

#Especial 1 (a).
func special1():
	if state < 3:
		state = 9
		anim.play("SPECIAL1")
		is_attacking = true
		yield(anim, "animation_finished")
		is_attacking = false
		state = 0

#Especial 2 (s).
func special2():
	if state < 3:
		var holder = def
		
		def = def * 3
		state = 10
		anim.play("SPECIAL2")
		is_attacking = true
		yield(anim, "animation_finished")
		is_attacking = false
		def = holder
		state = 0

#Chama as animações basicas.
func animation():
	match dir: #inverte o sprite dependendo a direção.
		0:
			sprite.flip_h = true
		1:
			sprite.flip_h = false
	
	if !is_attacking:
		match state:
			0:
				anim.play("IDLE")
			1:
				anim.play("RUN")
			2:
				anim.play("IDLE")
			3:
				anim.play("IDLE")
		
	

#Função de ataque da AI (por emplementar).
func attack():
	print('kill la kill')

#Função de verificação de inimigos próximos para AI (por emplementar).
func iec():
	pass

#Evita teleportar atraves de uma parede.
func _on_TP_body_entered(body):
	area = body
func _on_TP_body_exited(body):
	area = null

#Verifica se alguem entrou no hitbox da espada 
#e calcua o dano a ser causado.
func _on_Sword_area_body_entered(body):
	
	if !body.has_method("hit"):
		return
	print('entro')
	var damage = 0
	match state:
		4:
			damage = atk * 1.5 - body.def
		5:
			damage = atk * 1.5 - body.def
		6:
			damage = atk * 1.8 - body.def
	
	body.hit(damage, dir)










