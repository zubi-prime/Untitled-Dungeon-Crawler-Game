extends State


@export var steepnessBase: float
@export var homingDelay: float

var delayTimer: SceneTreeTimer


var velocity: = Vector2()

func _physics_process(delta):
	master.position += velocity * delta
	if delayTimer.time_left == 0. and !master.dungeon.enemies.is_empty():
		var steepness: = steepnessBase
		if GlobalData.hasUpgrade('desperado'): if Input.is_action_pressed('special'): steepness *= 4.
		velocity += master.position.direction_to(master.getNearestEnemy().position) * master.speed * steepness * delta
		if velocity.length() > master.speed:
			velocity = velocity.normalized() * master.speed


func _ready():
	delayTimer = get_tree().create_timer(homingDelay, false)
