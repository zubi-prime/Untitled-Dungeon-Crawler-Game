extends Enemy

const BulletSpeed: = 420.
const AttackInterval: = 2.


func attackTimerTimeout():
	
	var timer: Timer = $MidAttackTimer
	
	#charge
	$StateMachine.changeState(0)
	$SpriteBuffer/Sprite.play('charge')
	$AnimationPlayer.play('charge')
	
	timer.start(.8)
	await timer.timeout
	
	#attack
	$SpriteBuffer/Sprite.play('attack')
	
	for i in range(3):
		
		spawnBullet('BasicBeeg', position.direction_to(player.attackPos()) * BulletSpeed)
		$AnimationPlayer.stop()
		$AnimationPlayer.play('attack')
		
		timer.start(.2)
		await timer.timeout
	
	
	#postlag  
	timer.start(.4)
	await timer.timeout
	
	#return to monke
	$StateMachine.changeState(1)
	$AttackTimer.start(AttackInterval * randf_range(.8, 1.2))
	$SpriteBuffer/Sprite.play('idle')
	$AnimationPlayer.play('walk')
	
	


func _inheritReady():
	$AttackTimer.start(AttackInterval * randf_range(.8, 1.2))


func _physics_process(delta):
	$SpriteBuffer.scale.x = abs($SpriteBuffer.scale.x) * sign(player.position.x - position.x)
