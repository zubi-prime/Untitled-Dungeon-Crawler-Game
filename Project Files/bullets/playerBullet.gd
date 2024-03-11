extends Area2D
class_name PlayerBullet



# stats
var speed: float
var damage: float
var knockback: float
var pierce: int

var startingVelocity: Vector2


@onready var dungeon: Dungeon = get_parent()
@onready var player: = dungeon.get_node('Player')




func areaEntered(area: Area2D):
	if area.is_in_group('enemy hurtbox'):
		area.get_parent().getHit(self)
		pierce -= 1
		if pierce <= 0:
			destroy()
	
	
func bodyEntered(body: Node2D):
	if body.is_in_group('walls'):
		destroy(false)
		
		
		
func destroy(sound: = true):
	if has_method('inheritDestroy'):
		call('inheritDestroy', sound)
		
	
	# particles
	var particles: = preload('res://splashes/playerBulletBoom.tscn').instantiate()
	particles.position = position
	particles.finished.connect(particles.queue_free)
	particles.sound = sound
	dungeon.call_deferred('add_child', particles)
	particles.emitting = true
	
	queue_free()


func getNearestEnemy() -> Enemy:
	var enemyList: Array[Enemy] = dungeon.enemies.duplicate()
	enemyList.sort_custom(func(a, b): return (b.position.distance_squared_to(position) > a.position.distance_squared_to(position)))
	return enemyList[0]


func getKnockbackDirection():
	if has_method('inheritGetKnockbackDirection'):
		return call('inheritGetKnockbackDirection')
	return $StateMachine.getCurrentState().velocity.normalized()


func _ready():
	$StateMachine.getCurrentState().velocity = startingVelocity
