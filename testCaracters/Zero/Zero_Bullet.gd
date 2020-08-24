extends Area2D

#Criar classe para projeteis mais tarde. Este scrip não sera reutilizado.

var speed = 1200 #velocidade em que a balaira se mover.
var damage = 10  #ataque para o calculo de dano.
var dir = 0

var vector = Vector2(1,0)

func _physics_process(delta):
	translate(vector * speed * delta)

#Ao atingir um corpo(body) verifica se este possue o metodo 'hit' o 
#chamando.
func _on_Zero_Bullet_body_entered(body):
	if body.has_method("hit"):
		body.hit(damage * 1.6 - body.def * 1.2, dir)
	queue_free()

#Define o dano e direção da bala.
func set_bullet(dam, _dir):
	damage = dam
	dir = _dir
	match dir:
		0:
			vector.x = 1
		1:
			vector.x = -1
