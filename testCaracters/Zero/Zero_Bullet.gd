extends Area2D

var speed = 900
var damage = 25

var vector = Vector2(1,0)

func _physics_process(delta):
	translate(vector * speed * delta)

func _on_Zero_Bullet_body_entered(body):
	if body.has_method("hit"):
		body.hit(damage)
	queue_free()

func set_bullet(dam, dir):
	damage = dam
	match dir:
		0:
			vector.x = 1
		1:
			vector.x = -1
