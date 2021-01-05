extends StaticBody2D

class_name Destructable #Código base para objetos destrutiveis no mapa.

#status nescessarios para calculo de dano.
var life = 50
var def = 5
var res = 5

const team_id = -1

export var type = true

#Verifica se ira sobreviver ao dano recebido (dano já calculado).
func damage(damage, dir, kb): #dir - direção do knock back (a ser implementado).
	if damage < life: #Reduz a vida ou chama a função de morte.
		life -= damage
		print(damage)
		
	else:
		print(damage)
		death()
	

#Em forma de função para poder ser re-escrito animações e outras funções
#para destrutiveis diferentes.
func death():
	queue_free() #Deleta o objeto da cena.
