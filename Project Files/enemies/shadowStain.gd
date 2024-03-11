extends Enemy




func _inheritReady():
	$StateMachine/Trudge/MoveTimer.timeout.connect(func():
		$SpriteBuffer.scale.x = abs($SpriteBuffer.scale.x) * sign(player.position.x - position.x)
		$AnimationPlayer.play('trudge')
	)


func _physics_process(delta):
	if $StateMachine.currentState == 1:
		if position.distance_to(player.attackPos()) < 125. and !($AnimationPlayer.is_playing() and $AnimationPlayer.current_animation == 'attack'):
			var timer: Timer = $MidAttackTimer
			
			$SpriteBuffer.scale.x = abs($SpriteBuffer.scale.x) * sign(player.position.x - position.x)
			$StateMachine.changeState(0)
			$SpriteBuffer/Sprite.play('attack')
			
			var attackDir: = position.direction_to(player.attackPos())
			velocity += attackDir * -300.
			$AnimationPlayer.play('attack charge')
			
			timer.start(.4)
			await timer.timeout
			
			velocity += attackDir * 2550.
			$StateMachine/Idle.friction = .16
			$AnimationPlayer.play('attack')
			$Attackbox.monitoring = true
			
			timer.start(.2)
			await timer.timeout
			
			$Attackbox.monitoring = false
			$StateMachine/Idle.friction = .3
			$StateMachine.changeState(1)
			$SpriteBuffer/Sprite.play('idle')
			$StateMachine/Trudge/MoveTimer.start()
			
	$Attackbox.rotation = (player.attackPos() - position).angle()



func attackboxAreaEntered(area):
	if area.get_parent() == player:
		player.getHit(self)
