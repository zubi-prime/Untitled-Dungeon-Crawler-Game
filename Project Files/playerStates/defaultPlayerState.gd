extends State

@export var moveSpeed: float
@export var friction: float
@export var sprintCostBase: float
@export var sprintMult: float

signal startWalking
signal stopWalking

var isWalking: = false



func _physics_process(delta):
	master.move_and_slide()
	
	var isSprinting: bool
	if Input.is_action_pressed('run'):
		if GlobalData.isInCombat:
			if master.stamina > 0.:
				isSprinting = true
				
				var sprintCost: = sprintCostBase
				
				if GlobalData.weaponMods.has('atpCharges'): if master.isAttacking: sprintCost *= 1.5
				
				master.stamina -= sprintCost * delta
				master.stamina = max(master.stamina, 0.)
			else:
				isSprinting = false
		else:
			isSprinting = true
	else:
		isSprinting = false
	
	master.isSprinting = isSprinting
	
	
	var accel: = moveSpeed * (sprintMult if (isSprinting) else 1.) * friction / (1. - friction) * 100.
	master.velocity += Input.get_vector('walk left', 'walk right', 'walk up', 'walk down') * delta * accel
	master.velocity *= (1. - friction)
	
	if Input.get_vector('walk left', 'walk right', 'walk up', 'walk down') != Vector2():
		
		if !isWalking:
			startWalking.emit()
			isWalking = true
			
	else:
		
		if isWalking:
			stopWalking.emit()
			isWalking = false
	master.isWalking = isWalking
	
	
