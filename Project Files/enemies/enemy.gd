extends CharacterBody2D
class_name Enemy


signal killed
signal destroyed


@onready var dungeon: Dungeon = get_parent()
@onready var player: Player = dungeon.get_node('Player')


@export var title: String

@export var maxHealth: float
@export var knockbackMult: float
@export var damage: int = 1

@export var goldDroppedMean: float
@export var goldDroppedDeviation: float


var drops: Array[String] = []


@export var elite: = false


@export var boundingSize: Vector2

var health: float

var isStunned: = false

var enemyShaders: Array[ShaderMaterial] = []


func _ready():
	
	killed.connect(player.killedEnemy)
	
	if has_method('_inheritReady'):
		call('_inheritReady')
	
	dungeon.enemies.append(self)
	
	health = maxHealth
	
	dungeon.onEnemySpawned(self)
	
	
	# find and uniqueify shaders
	var searchChild: = func(node, _recursiveFunction):
		for child in node.get_children():
			if child.get('material') and child.material.shader == preload('res://enemies/enemySprite.gdshader'):
				child.material = child.material.duplicate()
				enemyShaders.append(child.material)
			_recursiveFunction.call(child, _recursiveFunction)
	searchChild.call(self, searchChild)
	


func getHit(hitter: PlayerBullet):
	if !is_queued_for_deletion():
		health -= hitter.damage
		if health <= 0:
			killed.emit(self)
			destroy()
		
		if !isStunned:
			#knockback
			velocity += hitter.getKnockbackDirection() * hitter.knockback * knockbackMult

		#white flash
		var tween: = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CIRC)
		tween.tween_method(_setPropertyOnEnemyShaders.bind('whiteFlash'), 1., 0., .12)
		
		
		
func destroy():
	
	destroyed.emit(self)
	
	if has_method('onDestroy'):
		call('onDestroy')
	
	# coins
	var coinCount: int = round(min(goldDroppedMean + goldDroppedDeviation * 2., max(goldDroppedMean - goldDroppedDeviation * 2., randfn(goldDroppedMean, goldDroppedDeviation))))
	while coinCount > 0:
		var spawnName: String
		if coinCount >= 100:
			spawnName = 'Gold'
			coinCount -= 100
		elif coinCount >= 10:
			spawnName = 'Silver'
			coinCount -= 10
		else:
			spawnName = 'Copper'
			coinCount -= 1
		
		var coin: Node2D = load('res://pickups/coin' + spawnName + '.tscn').instantiate()
		coin.position = position + Handy.pol2Car(randf_range(15.,40.), randf_range(0, 2*PI))
		dungeon.call_deferred('add_child', coin)
		
		
	
	# drops
	for item in drops:
		match item:
			'lesser treasure':
				pass
	
	
	dungeon.enemies.erase(self)
	dungeon.call_deferred('onEnemyDied', self)
	queue_free()
	
	
	
func getStunned(time: float): # haha get stunned n00b ez clap
	isStunned = true
	var oldState: int = $StateMachine.currentState
	$StateMachine.changeStateByName('Idle')
	process_mode = Node.PROCESS_MODE_DISABLED
	var splash: = preload('res://splashes/stunnedEffect.tscn').instantiate()
	splash.process_mode = Node.PROCESS_MODE_PAUSABLE
	splash.position.y = -boundingSize.y
	add_child(splash)
	
	await get_tree().create_timer(time, false).timeout
	
	isStunned = false
	splash.queue_free()
	process_mode = PROCESS_MODE_INHERIT
	$StateMachine.changeState(oldState)
	


func _setPropertyOnEnemyShaders(value: Variant, property: String):
	for shader in enemyShaders:
		shader.set_shader_parameter(property, value)


func spawnBullet(title: String, bulletVel: Vector2, addToTree: = true, bulletPos: = position, bulletDamage: = damage) -> EnemyBullet:
	var bullet: EnemyBullet = load('res://bullets/enemyBullet' + title + '.tscn').instantiate()
	bullet.position = bulletPos + bulletVel.normalized() * 50.
	bullet.startingVelocity = bulletVel
	bullet.damage = bulletDamage
	if addToTree:
		dungeon.add_child(bullet)
	return bullet
