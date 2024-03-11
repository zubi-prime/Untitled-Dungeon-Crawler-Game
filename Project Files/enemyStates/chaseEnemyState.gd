extends State



@export var friction: float
@export var moveSpeed: float

@onready var player: = get_parent().get_parent().get_parent().get_node('Player')



func _physics_process(delta):
	
	master.move_and_slide()
	
	var accel: = moveSpeed * friction / (1. - friction)
	
	master.velocity += master.position.direction_to(player.attackPos()) * accel * delta
	master.velocity *= (1. - friction)
	
	
