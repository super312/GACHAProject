extends PlayerBasics

#state values
# 0 - IDLE  /  1 - RUNNING  /  2 - JUMPING
# 3 - DASH  /  4 - FROZEN   /  5 - IS ATTACKING

#Pré carrega o projetil.
const bullet = preload("res://testCaracters/Zero/Zero_Bullet.tscn")

#variaveis para simplificar o path dos objetos.
onready var sword = $Sword_area/SWORD_HITBOX
onready var anim = $AnimationPlayer

var area = null #verificação de paredes para o teleporte (valeu pela ideia andrei).
var got_hit = false

func _ready():
	atk = 30
	has_ad = true #Coloque como true para obter air dash (falso por padrão).
	has_dj = true #Coloque como true para obter double jump (falso por padrão).
	sprite = $Sprite
	self.connect("stop_attack", self, "end_attack")
	self.connect("took_damage", self, "took_hit")

func _physics_process(delta):
	#altera a direção dos hitboxes.
	match dir:
		1:
			sword.position.x = 70
			$TP/area.position.x = 100
			$SHOOT_POSITION.position.x = 70
		-1:
			sword.position.x = -70
			$TP/area.position.x = -100
			$SHOOT_POSITION.position.x = -70
	if Input.is_action_just_pressed("UI_special1") and can_attack and is_playing:
		special1()
	if is_on_floor():
		#Cancela o ataque areo ao atingir o chão. 
		#Futuramente adicionar animação ao pousar (landing delay).
		if is_attacking and anim.current_animation == "AIRATTACK1":
			end_attack()
		
		#verifica qual botão de ataque foi prescionado.
		if Input.is_action_just_pressed("UI_fast") and can_attack and is_playing:
			fast_attack()
		if Input.is_action_just_pressed("UI_strong") and can_attack and is_playing:
			strong_attack()
		
		if Input.is_action_just_pressed("UI_special2") and can_attack and is_playing:
			special2()
		
	else:
		if Input.is_action_just_pressed("UI_fast") and can_attack and is_playing:
			air_attack()
	
	animation()

#ataque aereo.
func air_attack():
	is_attacking = true
	state = 5
	if current_attack == 0:
		current_attack = 6
		anim.play("AIRATTACK1")

#Ataque rapido (z).
func fast_attack():
	is_attacking = true
	state = 5
	if current_attack == 0:
		current_attack = 1
		anim.play("ATTACK1")
	elif current_attack == 1 and anim.current_animation_position > 0.2:
		current_attack = 2
		#if area == null:
		#	match dir:
		#		1:
		#			dir = -1
		#			position.x += 100
		#		-1:
		#			dir = 1
		#			position.x -= 100
		anim.play("ATTACK2")
	elif current_attack == 2 and anim.current_animation_position > 0.2:
		current_attack = 3
		anim.play("ATTACK3")
		
	

#Ataque forte (x).
func strong_attack():
	var b = bullet.instance()
	is_attacking = true
	state = 5
	if current_attack == 0:
		current_attack = 4
		anim.play("SHOOT1")
		yield(get_tree().create_timer(0.2), "timeout")
		self.add_child(b)
		b.position = $SHOOT_POSITION.position
		b.set_bullet(atk,dir,team_id,nEffects[4][1] or nEffects[9][1])
		
	elif current_attack == 2 and anim.current_animation_position > 0.2:
		current_attack = 5
		anim.play("SHOOT2")
		yield(get_tree().create_timer(0.2), "timeout")
		self.add_child(b)
		b.position = $SHOOT_POSITION.position
		b.set_bullet(atk,dir,team_id,nEffects[4][1] or nEffects[9][1])
	pass

#Especial 1 (a).
func special1():
	is_attacking = true
	if current_attack == 0:
		state = 5
		anim.play("SPECIAL1")
		yield(get_tree().create_timer(0.1), "timeout")
		add_effect(10)

#Especial 2 (s).
func special2():
	is_attacking = true
	got_hit = false
	if current_attack == 0:
		state = 5
		anim.play("SPECIAL2")
		yield(anim, "animation_finished")
		if !got_hit:
			var party = get_tree().get_nodes_in_group("Party")
			for i in range(party.size()):
				party[i].heal(30)
	
func took_hit(i):
	got_hit = true

#Chama as animações basicas.
func animation():
	match dir: #inverte o sprite dependendo a direção.
		1:
			sprite.flip_h = true
		-1:
			sprite.flip_h = false
	
	if !is_attacking:
		match state:
			-1:
				anim.play("IDLE")
			0:
				anim.play("IDLE")
			1:
				anim.play("RUN")
			2:
				anim.play("IDLE")
			3:
				anim.stop(false)
			4:
				anim.play("AIRATTACK1")

#Função de ataque da AI (por emplementar).
func attack():
	pass

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
	
	if !body.has_method("damage"):
		return
	if !((nEffects[4][1] or nEffects[9][1]) or body.team_id != team_id):
		return
	
	var x = int(rand_range(-(atk*0.3),atk*0.3))
	var damage = 0
	var type = 0
	match current_attack:
		1:
			damage = stat_array[2] * 1.5 - body.def
			type = 2
		2:
			damage = stat_array[2] * 1.5 - body.def
			type = 2
		3:
			damage = stat_array[2] * 1.8 - body.def
		6:
			damage = stat_array[2] * 1.5 - body.def
	damage += x
	if damage < 1:
		damage = 1
	body.damage(damage, 0)
	body.knockback(dir,type)
	
	#elif body.team_id != team_id:
	#	body.damage(damage, dir, kb)
	

func end_attack():
	if is_attacking:
		is_attacking = false
		state = 0
		current_attack = 0
		sword.disabled = true
func _on_AnimationPlayer_animation_finished(anim_name):
	end_attack()












