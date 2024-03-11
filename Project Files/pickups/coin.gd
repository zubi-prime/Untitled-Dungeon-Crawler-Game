extends Area2D


@export var value: int
@export var title: String


@onready var dungeon: Dungeon = get_parent()
@onready var player: = dungeon.get_node('Player')


var velocity: = Vector2()
const MoveSpeed: = 500000.
const Friction: = .05


func _physics_process(delta):
	
	
	var accel: float = max(60000., min(100000., MoveSpeed * Friction / (1. - Friction) / pow(position.distance_squared_to(player.attackPos()) / 300., 2.) * 1000.))
	velocity += position.direction_to(player.attackPos()) * accel * delta
		
	position += velocity * delta
	velocity *= pow(Friction, 60. * delta)
	



func areaEntered(area):
	if area.get_parent() == player:
		getCollected()
		
		
		
func getCollected():
	
	GlobalData.coins += value
	
	player.coinCollectedAudioPlayers[title].play()
	
	queue_free()
