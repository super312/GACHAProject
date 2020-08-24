extends PlayerBasics

#state values
# 0 - IDLE  /  1 - RUNNING  /  2 - JUMPING
# 3 - DASH  /  4 - SWORD1   /  5 - SWORD2
# 6 - SWORD3/  7 - SHOOT1   /  8 - SHOOT2
# 9 - special 1  /  10 - special 2
# 11 - ARIATTACK


#var state_machine

const bullet = preload("res://testCaracters/Zero/Zero_Bullet.tscn")

onready var sprite = $Sprite
onready var sword = $Sword_area/SWORD_HITBOX
onready var anim = $AnimationPlayer

var area = null

func _ready():
	has_ad = true
	has_dj = true

func _physics_process(delta):
	var o = 0
	
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
		if is_attacking:
			if anim.current_animation == "AIRATTACK1":
				anim.stop()
				sword.disabled = true
				is_attacking = false
				state = 0
				
		
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

func air_attack():
	if state < 3:
		state = 11
		anim.play("AIRATTACK1")
		is_attacking = true
		yield(anim, "animation_finished")
		is_attacking = false
		state = 0

func fast_attack():
	if state < 3:
		state = 4
		anim.play("ATTACK1")
		is_attacking = true
		yield(anim, "animation_finished")
		is_attacking = false
		state = 0
	elif state == 4:
		if anim.current_animation_position > 0.4:
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
		
	

func strong_attack():
	
	if state < 3:
		state = 7
		anim.play("SHOOT1")
		is_attacking = true
		yield(get_tree().create_timer(0.2), "timeout")
		var b = bullet.instance()
		self.add_child(b)
		b.position = $SHOOT_POSITION.position
		b.set_bullet(30,dir)
		yield(anim, "animation_finished")
		is_attacking = false
		state = 0
	elif state == 5:
		if anim.current_animation_position > 0.4:
			anim.play("SHOOT2")
			state = 8
			yield(get_tree().create_timer(0.2), "timeout")
			var b = bullet.instance()
			self.add_child(b)
			b.position = $SHOOT_POSITION.position
			b.set_bullet(30,dir)

func special1():
	if state < 3:
		state = 9
		anim.play("SPECIAL1")
		is_attacking = true
		yield(anim, "animation_finished")
		is_attacking = false
		state = 0

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

func animation():
	match dir:
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
		
	

func attack():
	print('kill la kill')

func iec():
	pass

func _on_TP_body_entered(body):
	area = body
func _on_TP_body_exited(body):
	area = null

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
	
	body.hit(damage)










