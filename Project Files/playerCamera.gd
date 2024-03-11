extends Camera2D


@onready var player: = get_parent()

var targetPos: = Vector2()
var currentPos: = Vector2()


func _physics_process(delta):
	var size: = get_viewport_rect().size
	var room: Room = player.currentRoom
	if room:
		targetPos.x = max(min(player.global_position.x, room.global_position.x + room.size.x * 48 - (size.x / 2.) - 48.), room.global_position.x + (size.x / 2.) + 48.) # + (player.velocity.x / 12. if player.isSprinting and GlobalData.isInCombat else 0.)
		targetPos.y = max(min(player.global_position.y, room.global_position.y + room.size.y * 48 - (size.y / 2.) - 48.), room.global_position.y + (size.y / 2.) + 48.) # + (player.velocity.y / 12. if player.isSprinting and GlobalData.isInCombat else 0.) # commented out cause idk
	else:
		targetPos = player.global_position
		
	currentPos = lerp(currentPos, targetPos, pow(.2, delta * 60.))
	global_position = currentPos
	
	if Input.is_action_pressed('map'):
		zoom = lerp(zoom, Vector2(.04,.04), .05)
	else:
		zoom = lerp(zoom, Vector2(1,1), .15)
	

func _ready():
	
	$BackBufferCopy.rect.size = get_viewport_rect().size
	
	$StunWaveEffect.size =  get_viewport_rect().size
	$StunWaveEffect.position = $StunWaveEffect.size / -2.
	
	$StunWaveEffect.material.set_shader_parameter('screenSize', get_viewport_rect().size)
	
	
	# health bar
	$HealthBarBase.position = get_viewport_rect().size / -2.
	$HealthBarBase.size = Vector2(player.maxHealth * 32., 32.)
