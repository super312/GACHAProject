extends Position2D

var color = null
var vector = Vector2()
var decrease = 0

func _physics_process(delta):
	color.a -= decrease
	$Label.modulate = color
	vector.y += 0.02
	vector.x -= 0.03
	translate(vector * delta * 30)
	
	if color.a <= 0:
		queue_free()

func start(value):
	$Label.text = str(value)
	vector = Vector2(0.9,-2)
	yield(get_tree().create_timer(0.5), "timeout")
	decrease = 0.05

func set_color(col):
	#0-white / 1-red / 2-blue / 3-green / 4-purple / 5-orange / 6-Cyan
	#10-black
	match col:
		0:
			color = Color(1,1,1)
		1:
			color = Color(1,0,0)
		2:
			color = Color(0,0,1)
		3:
			color = Color(0,1,0)
		4:
			color = Color(0.5,0,1)
		5:
			color = Color(0.8,0.5,0)
		6:
			color = Color(0,1,1)
		10:
			color = Color(0,0,0)
	$Label.modulate = color
