extends Node

@onready var dungeon: = get_parent()
@onready var player: = dungeon.get_node('Player')
@onready var stunWaveEffect: = player.get_node('Camera/StunWaveEffect')
@onready var targets: Array = dungeon.enemies.duplicate() + dungeon.enemyBullets.duplicate()

var destroyingDisabled: = false

const Speed: = 1000.

var dist: = 0.

func _physics_process(delta):
	dist += Speed * delta
	if !destroyingDisabled:
		var removalList: = []
		for target in targets:
			if target != null and !target.is_queued_for_deletion():
				if player.position.distance_to(target.position) <= dist:
					if target is EnemyBullet:
						target.destroy()
					else: # is Enemy
						target.getStunned(3.2)
					removalList.append(target)
			else:
				removalList.append(target)
		for target in removalList:
			targets.erase(target)
			if targets.is_empty():
				destroyingDisabled = true
		
	if dist >= 3000.:
		stunWaveEffect.visible = false
		queue_free()
		
	stunWaveEffect.material.set_shader_parameter('dist', dist)
	stunWaveEffect.material.set_shader_parameter('playerPos', player.get_global_transform_with_canvas().get_origin())
	

func _ready():
	
	stunWaveEffect.visible = true
	
	dungeon.enemyBulletSpawned.connect(enemyBulletAdded)
	


func enemyBulletAdded(bullet):
	targets.append(bullet)
