extends KinematicBody2D

class_name PlayerBasics

var speed = 900
var grav = 25
var accel = 500
var jump = -750

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

var has_dj = false
var can_dj = true

var has_ad = false
var can_ad = true
var can_dash = true
var dir = 0
var is_dashing = false
var is_ad = false

var can_move = true

var state = 0
var is_attacking = false

func _ready():
	clife = life
	pass

func _physics_process(delta):
	
	if !is_ad:
		vector.y += grav
	var friction = false
	
	var x = 0
	
	if !is_dashing and can_move and !is_attacking:
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
		if x == 0:
			friction = true
			state = 0
		
	elif is_attacking:
		friction = true
	else:
		match dir:
				0:
					vector.x = (speed * spd * delta) * 4
				1:
					vector.x = -(speed * spd * delta) * 4
		
	
	if is_on_floor():
		can_dj = true
		can_ad = true
		
		if Input.is_action_pressed("ui_down") and Input.is_action_just_pressed("ui_up"):
			self.position.y += 2
		elif Input.is_action_just_pressed("ui_up") and !is_dashing and !is_attacking:
			vector.y = jump
		if Input.is_action_just_pressed("UI_dash") and can_dash:
			is_dashing = true
			can_dash = false
			can_move = false
			yield(get_tree().create_timer(0.15), "timeout")
			is_dashing = false
			yield(get_tree().create_timer(0.1), "timeout")
			can_move = true
			yield(get_tree().create_timer(0.1), "timeout")
			can_dash = true
		if friction and !is_dashing:
			vector.x = lerp(vector.x, 0, 0.3)
	else:
		state = 2
		
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
			vector.y = jump
			can_dj = false
		if friction:
			vector.x = lerp(vector.x, 0, 0.075)
	
	if Input.is_action_just_pressed("ui_select"):
		attack()
	
	vector = move_and_slide(vector, Vector2.UP)
	

func attack():
	pass

func damage(value):
	if clife > value:
		clife -= value
	else:
		death()

func death():
	pass
