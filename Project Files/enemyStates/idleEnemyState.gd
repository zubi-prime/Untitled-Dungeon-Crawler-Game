extends State


@export var friction: float


func _physics_process(delta):
	master.move_and_slide()
	master.velocity *= (1. - friction)
