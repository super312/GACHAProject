extends Node

class_name buff_debuff

signal end

#0-LIFE / 1-MANA / 2-ATK / 3-DEF / 4-INTE / 5-RES / 6-SPD
var value = 0
var current_stat
var buff = true

func start(stat,_value,time,_buff):
	current_stat = stat
	value = _value
	buff = _buff
	if time > 0:
		yield(get_tree().create_timer(time), "timeout")
		clear()

func get_stat():
	return [current_stat,value,buff]

func clear():
	value = 0
	emit_signal("end")
	queue_free()
