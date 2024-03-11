extends State



@export var friction: float
@export var moveSpeed: float
@export var interval: float
@export var useNavigation: = true

@onready var player: = get_parent().get_parent().get_parent().get_node('Player')


var moveTimer: Timer



var navigationAgent: NavigationAgent2D
var navigationSuggestion: Vector2 # computed every frame in _physics_process()



func _physics_process(delta):
	master.move_and_slide()
	master.velocity *= (1. - friction)



func _ready():
	moveTimer = Timer.new()
	add_child(moveTimer)
	moveTimer.name = 'MoveTimer'
	moveTimer.wait_time = interval
	moveTimer.timeout.connect(trudge)
	moveTimer.start()
	moveTimer.one_shot = true
	
	if useNavigation:
		navigationAgent = master.get_node('NavAgent')
		
	
func trudge():
	if useNavigation:
		navigationAgent.target_position = player.attackGlobalPos()
		navigationSuggestion = (navigationAgent.get_next_path_position() - master.global_position).normalized()
	
		master.velocity += navigationSuggestion * moveSpeed * 100
	else:
		master.velocity += (player.position - master.position).normalized() * moveSpeed * 100
	
	moveTimer.start(interval)




