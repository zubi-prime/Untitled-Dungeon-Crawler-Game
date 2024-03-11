extends Enemy




func _inheritReady():
	$StateMachine/Trudge/MoveTimer.timeout.connect(func():
		$SpriteBuffer.scale.x = abs($SpriteBuffer.scale.x) * sign(velocity.x)
		$AnimationPlayer.play('trudge')
	)
	
	
	


func _physics_process(delta):
	if $StateMachine.currentState == 1:
		if position.distance_to(player.attackPos()) < (320. if elite else 175.) and !($AnimationPlayer.is_playing() and $AnimationPlayer.current_animation == 'attack'):
			var timer: Timer = $MidAttackTimer
			
			
			$SpriteBuffer.scale.x = abs($SpriteBuffer.scale.x) * sign(player.position.x - position.x)
			
			# wind up
			$StateMachine.changeState(0)
			$SpriteBuffer/Sprite.play('attack')
			var attackDir: = position.direction_to(player.attackPos())
			velocity = attackDir * -600.
			$AnimationPlayer.play('attack charge')
			
			timer.start(.35 if elite else (.5*pow(4./5., (dungeon.countEnemyType('shadowMeson') + dungeon.countEnemyType('shadowMesonElite') * 8. - 1)) + .3)) # exponential decay function that makes it .8 if there's one meson, aproaches .3 at infinity. base 4/5. elite mesons give a huge buff
			await timer.timeout
			
			# lunge
			velocity = attackDir * (6600. if elite else 4500.)
			$Attackbox.rotation = (player.attackPos() - position).angle()
			$StateMachine/Idle.friction = .16
			$AnimationPlayer.play('attack')
			$Attackbox.monitoring = true
			
			timer.start(.3)
			await timer.timeout
			
			# turn off attackBox
			$Attackbox.monitoring = false
			
			
			timer.start(.5)
			await timer.timeout
			
			# return to monke
			$StateMachine/Idle.friction = .3
			$StateMachine.changeState(1)
			$SpriteBuffer/Sprite.play('idle')
			$StateMachine/Trudge/MoveTimer.start(0. if elite else ($StateMachine/Trudge/MoveTimer.wait_time + .5))
			
			
		$Attackbox.rotation = (player.attackPos() - position).angle()


func onDestroy():
	for i in range(2):
		var stain: = preload('res://enemies/shadowStain.tscn').instantiate()
		stain.position = position + Vector2(0, 20 * [-1,1][i]).rotated(velocity.angle())
		dungeon.call_deferred('add_child', stain)


func attackboxAreaEntered(area):
	if area.get_parent() == player:
		player.getHit(self)
