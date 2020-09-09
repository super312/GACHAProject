extends PlayerBasics



onready var sprite = $Sprite
onready var anim = $AnimationPlayer

func _ready():
	has_dj = true
	pass

func _physics_process(delta):
	var o = 0
	
	match dir:
		0:
			$AttackHitbox/CollisionShape2D.position.x = 50
		1:
			$AttackHitbox/CollisionShape2D.position.x = -50
	
	
	if is_on_floor():
		if Input.is_action_just_pressed("UI_fast"):
			fast_attack()
			o = 1
		if Input.is_action_just_pressed("UI_strong"):
			strong_attack()
			o = 1
	else:
		pass
	
	if o == 0:
		animation()

func fast_attack():
	if state < 3:
		state = 4
		anim.play("ATTACK1")
		is_attacking = true
		yield(anim, "animation_finished")
		is_attacking = false
	elif state == 4: #verifica o state/ataque atual.
		if anim.current_animation_position > 0.7: #verifica o frame da animação.
			anim.play("ATTACK2")
			state = 5
	

func strong_attack():
	if state < 3:
		state = 6
		anim.play("ATTACK3")
		is_attacking = true
		yield(anim, "animation_finished")
		is_attacking = false
		
	

func animation():
	match dir: #inverte o sprite dependendo a direção.
		0:
			sprite.flip_h = false
		1:
			sprite.flip_h = true
	
	if !is_attacking:
		match state:
			0:
				anim.play("IDLE")
			1:
				anim.play("RUN")
			2:
				anim.play("JUMP")
			3:
				anim.play("IDLE")
		
	

func _on_AttackHitbox_body_entered(body):
	if !body.has_method("hit"):
		return
	var damage = 0
	match state:
		4:
			damage = atk * 2 - body.def * 1.5
		5:
			damage = atk * 2.5 - body.def * 1.5
		6:
			damage = atk * 2.7 - body.def
	body.hit(damage, dir)
	
