extends CharacterBody2D
class_name Player



signal tookDamage
signal healthChanged
signal enteredRoom


@onready var dungeon: Dungeon = get_parent()


@onready var coinCollectedAudioPlayers: = {
	'copper': $AudioPlayers/CoinCollectedCopper,
	'silver': $AudioPlayers/CoinCollectedSilver,
	'gold': $AudioPlayers/CoinCollectedGold,
}



var maxHealth: = 6
var health: = maxHealth


func maxStamina() -> float:
	
	var rtrn: = 100.
	
	if GlobalData.weaponMods.has('metaboloader'): rtrn *= 5./6.
	
	return rtrn
	
var stamina: = maxStamina()
func staminaRegen() -> float: 
	
	var rtrn: = 50.
	
	if GlobalData.hasUpgrade('succubus'): rtrn *= .5
	
	
	if GlobalData.hasUpgrade('vampire'): rtrn = 0.
	
	return rtrn
	



var currentRoom: Room


var pointingDir: = Vector2(1,0)
var isSprinting: = false
var isWalking: = false
var isAttacking: = false



# upgrade specific vars:

# metaboloader
var metaboloaderCharge: = 0.
const MetaboloaderChargeTime: = .5

# /upgrade specific vars



func areaEntered(area: Area2D):
	if area.get_parent().get_parent() is Room:
		currentRoom = area.get_parent().get_parent()
		enteredRoom.emit()
	if area.get_parent().is_in_group('corridor'):
		currentRoom = null




func getHit(hitter: Node2D):
	if $InvincibilityTimer.time_left == 0.:
		health -= hitter.damage
		if health <= 0:
			die()
			return
		tookDamage.emit(hitter.damage)
		healthChanged.emit(-hitter.damage)
			
		var stun: = Node.new()
		stun.set_script(preload('res://playerHitStun.gd'))
		dungeon.add_child(stun)
		
		$InvincibilityTimer.start()
		
		$AudioPlayers/Hit.play()
		
		
		# timescale effect
		var tween: = create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_CUBIC)
		Engine.time_scale = 0.
		tween.tween_property(Engine,'time_scale', 1., .06)
		
		# red flash effect
		tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_QUINT)
		$Sprite/RedFlashModulate.modulate = Color('ff0000')
		tween.tween_property($Sprite/RedFlashModulate, 'modulate', Color('ffffff'), 1.2)



func changeHealth(by: int):
	health += by
	healthChanged.emit(by)
	
func die(): #rip 2pac
	get_tree().quit()
	
	

func _physics_process(delta):
	
	if !velocity.is_equal_approx(Vector2(0,0)):
		pointingDir = velocity.normalized()
		
	
	# stamina bar
	var staminaBar: TextureProgressBar = $StaminaBar
	staminaBar.value = stamina
	staminaBar.max_value = maxStamina()
	if stamina == maxStamina():
		staminaBar.modulate.a = lerp(staminaBar.modulate.a, 0., .4)
	else:
		staminaBar.modulate.a = lerp(staminaBar.modulate.a, 1., .4)
		
	# stamina
	if !(Input.is_action_pressed('run') and GlobalData.isInCombat):
		stamina += staminaRegen() * delta
		stamina = min(stamina, maxStamina())
	
	
	if GlobalData.weaponMods.has('metaboloader'): # metaboloader stuff
		
		if isSprinting and !(GlobalData.weaponMods.has('fullbodyMetaboloader') and isWalking): # fullbody metaboloader makes you have to stand still for the metaboloader to work
				metaboloaderCharge += (1. / MetaboloaderChargeTime) * delta
				metaboloaderCharge = min(metaboloaderCharge, 1.)
		else:
			metaboloaderCharge = 0.
	


func attackPos() -> Vector2:
	return position + Vector2(0,-24)
	
func attackGlobalPos() -> Vector2:
	return global_position + Vector2(0,-24)




func _ready():
	
	for i in range(12):
		var arrow: = preload('res://exitArrow.tscn').instantiate()
		arrow.id = i
		add_child(arrow)
	
	$StaminaBar.modulate.a = 0.


func changeStamina(by: float):
	stamina += by
	stamina = clamp(stamina, 0., maxStamina())



func killedEnemy(enemy: Enemy):
	if GlobalData.hasUpgrade('succubus'):
		if GlobalData.hasUpgrade('vampire'):
			changeStamina(enemy.maxHealth * 75./4.)
		else:
			changeStamina(enemy.maxHealth * 25./4.)
			




func updateProgressBars():
	pass
