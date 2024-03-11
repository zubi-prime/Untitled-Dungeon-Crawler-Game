extends Area2D
class_name EnemyBullet



# stats
var damage: = 1
var pierce: = 1

var startingVelocity: Vector2


@onready var dungeon: Dungeon = get_parent()
@onready var player: = dungeon.get_node('Player')




func areaEntered(area: Area2D):
	if area.is_in_group('player hurtbox'):
		area.get_parent().getHit(self)
		pierce -= 1
		if pierce <= 0:
			destroy()
	
	
func bodyEntered(body: Node2D):
	if body.is_in_group('walls'):
		destroy()
		
		
		
func destroy():
	if has_method('inheritDestroy'):
		call('inheritDestroy')
	dungeon.enemyBullets.erase(self)
	dungeon.enemyBulletDestroyed.emit(self)
	queue_free()
	
	# particles
	var splash: = preload('res://splashes/enemyBulletBoom.tscn').instantiate()
	splash.position = position
	splash.finished.connect(splash.queue_free)
	splash.emitting = true
	dungeon.call_deferred('add_child', splash)



func _ready():
	
	dungeon.enemyBullets.append(self)
	dungeon.enemyBulletSpawned.emit(self)
	
	if has_method('_inheritReady'):
		call('_inheritReady')
	
	$StateMachine.getCurrentState().velocity = startingVelocity
