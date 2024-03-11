extends Node



@onready var player: = get_parent()
@onready var dungeon: Dungeon = player.get_parent()



const BaseBulletSpeed: = 750.
const BaseRecoil: = 0.



var cooldownTimer: Timer



func hasUpgrade(title: String) -> bool:
	return GlobalData.weaponMods.has(title) or GlobalData.fortuneReadings.has(title)





func _ready():
	cooldownTimer = Timer.new()
	add_child(cooldownTimer)
	cooldownTimer.one_shot = true
	
	cooldownTimer.start()
	
	

func _physics_process(delta):
	if Input.is_action_pressed('attack'):
		player.isAttacking = true
		if cooldownTimer.time_left == 0.:
			cooldownTimer.start(attackInterval())
			attack()
	else:
		player.isAttacking = false
		
	
	
	
# utility

func getNearestEnemy() -> Enemy:
	var enemyList: Array[Enemy] = dungeon.enemies.duplicate()
	enemyList.sort_custom(func(a, b): return (b.position.distance_squared_to(player.position) > a.position.distance_squared_to(player.position)))
	return enemyList[0]


func attackInterval() -> float:
	var rtrn: = .2
	
	if hasUpgrade('doubleVision'): rtrn *= 1.5 # double vision gives *2/3 attack speed (*1.5 interval)
	
	if hasUpgrade('clusteredShot'): rtrn *= 1.5 # clustered shot gives *2/3 attack speed (*1.5 interval)
	
	if hasUpgrade('metaboloader'): rtrn *= 1. - ((.40 if hasUpgrade('sprayMetaboloader') else .25) * player.metaboloaderCharge) # metaboloader gives up to *4/3 attack speed (*.75 interval)
	
	if hasUpgrade('desperado'): if Input.is_action_pressed('special'): rtrn *= 3.
	
	return rtrn


func attack():
	
	var volleyCount: = 1
	
	if hasUpgrade('clusteredShot'): volleyCount += 1 # cluster shot adds 1 volley
	
	for j in volleyCount:
		var bulletCount: = 1
		
		if hasUpgrade('doubleVision'): bulletCount += 1 # double vision adds 1 bullet
		
		if hasUpgrade('fullbodyMetaboloader'): if player.metaboloaderCharge == 1.: bulletCount *= 2 # double vision adds 1 bullet
		
		
		var bulletSpread: = deg_to_rad(10.)
		
		if hasUpgrade('fullbodyMetaboloader'): if player.metaboloaderCharge == 1.: bulletSpread *= 2 # double vision adds 1 bullet
		
		
		for i in bulletCount:
			
			var bullet: = preload('res://bullets/playerBulletHoming.tscn').instantiate()
			
			if dungeon.enemies.is_empty():
				bullet.startingVelocity = player.pointingDir * BaseBulletSpeed
			else:
				bullet.startingVelocity = (getNearestEnemy().position - player.position).normalized() * BaseBulletSpeed
			
			
			var rot: = ((i + .5) / bulletCount) * bulletSpread - bulletSpread / 2.
			if hasUpgrade('sprayMetaboloader'): rot = randf_range(0, 2.*PI)
			
			bullet.startingVelocity = bullet.startingVelocity.rotated(rot) # rotate the first bit
			bullet.global_position = player.global_position + bullet.startingVelocity.normalized() * 20. # calculate the position based on the half rotation
			if GlobalData.isInCombat: bullet.startingVelocity = bullet.startingVelocity.rotated(5.5 * rot) # rotate the rest of the way if in combat, since the homing will pull them together
			
			
			if player.velocity.length() <= 300.:
				player.velocity += bullet.startingVelocity.normalized() * -BaseRecoil
			
			

			
			
			# bullet stats
			
			bullet.damage = 1.
			if hasUpgrade('atpCharges'): bullet.damage *= (1. + (2./3.)*player.metaboloaderCharge)
			
			
			bullet.knockback = 600.
			
			
			bullet.pierce = 1
			
			
			bullet.speed = BaseBulletSpeed
			
			
			bullet.scale = Vector2(1,1)
			if hasUpgrade('atpCharges'): bullet.scale *= (1. + (1./3.)*player.metaboloaderCharge)
			
			
			bullet.get_node('StateMachine/Homing').steepnessBase = 14.
			if hasUpgrade('sprayMetaboloader'): bullet.get_node('StateMachine/Homing').steepnessBase *= .2
			
			
			bullet.get_node('StateMachine/Homing').homingDelay = 0.
			if hasUpgrade('sprayMetaboloader'): bullet.get_node('StateMachine/Homing').homingDelay = .25
			
			dungeon.add_child(bullet)
			
			
		
		await get_tree().create_timer(.075, false).timeout
		
		$AttackNoise.play()
