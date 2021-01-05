extends Area2D

#Criar classe para projeteis mais tarde. Este scrip não sera reutilizado.

var speed = 1200 #velocidade em que a balaira se mover.
var damage = 10  #ataque para o calculo de dano.
var dir = 0
var hit_all = false
var team_id = 0

var vector = Vector2(1,0)

func _physics_process(delta):
	translate(vector * speed * delta)

#Ao atingir um corpo(body) verifica se este possue o metodo 'hit' o 
#chamando.
func _on_Zero_Bullet_body_entered(body):
	var x = int(rand_range(-(damage*0.2),damage*0.15))
	if !body.has_method("damage"):
		return
	
	var dam = (damage * 1.2 - body.def * 1.2) + x
	if dam <= 0:
		dam = 0
	
	if hit_all:
		body.damage(dam)
		queue_free()
	elif body.team_id != team_id:
		body.damage(dam + x)
		queue_free()
	

#Define o dano e direção da bala.
func set_bullet(dam, _dir, team_id, all = false):
	hit_all = all
	damage = dam
	#dir = _dir
	vector.x = _dir
