extends EnemyBasics

onready var sword = $SwordHitBox/CollisionShape2D
onready var anim = $AnimationPlayer
onready var ray = $RayCast2D
onready var a = $Sprite

func _ready():
	sprite = $Sprite
	pass

func _physics_process(delta):
	anim()

func anim():
	match dir:
		-1:
			sword.position.x = -30
			sprite.flip_h = false
			ray.cast_to = Vector2(-50,0)
		1:
			sword.position.x = 30
			sprite.flip_h = true
			ray.cast_to = Vector2(50,0)
	
	match state:
		-1:
			anim.play("TOOK_DAMAGE")
		0:
			anim.play("IDLE")
		1:
			anim.play("RUN")
		2:
			anim.play("IDLE")
		3:
			anim.play("RUN")
	

func is_in_range():
	var objects = []
	var b = false
	while ray.is_colliding():
		var obj = ray.get_collider()
		objects.append(obj)
		ray.add_exception(obj)
		if obj.team_id != team_id:
			b = true
		ray.force_raycast_update()
	
	for i in range(objects.size()):
		ray.remove_exception(objects[i])
	
	return b

func attack():
	attacking = true
	state = 5
	if current_attack == 0:
		current_attack = 1
		sword.position.y = -15
		vector.x += 10
		anim.play("ATTACK1")
	elif current_attack == 1:
		current_attack = 2
		sword.position.y = 0
		anim.play("ATTACK2")
	

func end_attack():
	if attacking:
		attacking = false
		sword.disabled = true
		state = 0
		if take_hit:
			current_attack = 0
			take_hit = false
		elif is_in_range() and current_attack < 2:
			continue_attack = true
		else:
			current_attack = 0

func _on_SwordHitBox_body_entered(body):
	if !body.has_method("damage"):
		return
	var x = int(rand_range(-(atk*0.2),atk*0.2))
	var b = true
	x = (atk * 1.2 - body.def * 1.1) + x
	if x < 1:
		x = 0
	if current_attack == 1:
		b = false
	if (nEffects[4][1] or nEffects[9][1]) or body.team_id != team_id:
		body.damage(x,0)
		body.knockback(dir)

func _on_AnimationPlayer_animation_finished(anim_name):
	end_attack()
func _on_Link_took_hit():
	take_hit = true
	end_attack()
