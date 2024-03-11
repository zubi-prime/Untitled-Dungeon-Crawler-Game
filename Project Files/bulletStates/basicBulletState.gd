extends State


var velocity: = Vector2()

func _physics_process(delta):
	master.position += velocity * delta
	
