extends Node

const chars = [
	preload("res://testCaracters/Zero/Zero.tscn"),    #Zero - 0
	preload("res://testCaracters/Mario/Mario.tscn"),  #Mario1 - 1
	preload("res://testCaracters/Mario2/Mario2.tscn") #Mario2 - 2
]

func get_char(x):
	if x < chars.size():
		return chars[x].instance()
	else:
		print("o pora")

