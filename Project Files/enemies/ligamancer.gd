extends Enemy

var bulletSpeed: = 650.
var attackInterval: = 3.

func attackTimerTimeout():
	var timer: Timer = $MidAttackTimer
	
	# charge
	
	$SpriteBuffer/Body.play('charge')
	$SpriteBuffer/Head.play('attack >:3')
	$StateMachine.changeState(0)
	
	timer.start(.75)
	await timer.timeout
	
	
	# attack
	$SpriteBuffer/Body.play('attack')
	knockbackMult = 0.
	
	var attackDir: = position.direction_to(player.attackPos())
	
	var options: = [0, 1, 2]
	if position.distance_to(player.attackPos()) <= 450.:
		options.erase(2)
	if position.distance_to(player.attackPos()) <= 250.:
		options.erase(0)
	if position.distance_to(player.attackPos()) >= 550.:
		options.erase(1)
	match options.pick_random(): # oh laaaawwwd
		
		0: # beeg + smol
			var locBulletSpeed = bulletSpeed
			for k in range(2):
				for i in range(2):
					
					var bullet: = spawnBullet('BasicBeeger', attackDir * locBulletSpeed)
					
					for j in range(2):
						
						for l in range(2):
							bullet = spawnBullet('Twist', attackDir * locBulletSpeed, false)
							bullet.wavelength = 1.4
							bullet.amplitude = 160. * [-1, 1][l]
							dungeon.add_child(bullet)
						
						timer.start(24. / locBulletSpeed) # quick maffs
						await timer.timeout
				timer.start(.2)
				await timer.timeout
			
		1: # smol
			var locBulletSpeed = bulletSpeed * .5
			for i in range(16):
				for j in range(2):
					var bullet: = spawnBullet('Twist', attackDir * locBulletSpeed, false)
					bullet.wavelength = 1.25
					bullet.amplitude = 150. * [-1, 1][j]
					dungeon.add_child(bullet)
				timer.start(24. / locBulletSpeed)
				await timer.timeout
			
		2: # beeg
			var locBulletSpeed = bulletSpeed * 1.3
			for i in range(6):
				
				spawnBullet('BasicBeeger', attackDir * locBulletSpeed)
				
				timer.start(48. / locBulletSpeed)
				await timer.timeout
					
	
	# return to monke
	$SpriteBuffer/Body.play('idle')
	$SpriteBuffer/Head.play('idle :3')
	$StateMachine.changeState(1)
	knockbackMult = .6
	
	
	# timer shit
	# woah hey dude watch you're mouth
	# it's your, dipshit
	$AttackTimer.start(attackInterval * randf_range(.8, 1.2))


func _inheritReady():
	$AttackTimer.start(attackInterval * randf_range(.8, 1.2))
