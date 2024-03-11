extends Area2D


@onready var dungeon: Dungeon = get_parent()
@onready var player: = dungeon.get_node('Player')


var isConfirming: = false
var popupOpen: = false


func _ready():
	
	$Sprite.play('closed')
	$Popup/Confirmation.visible = false
	$Popup.scale.y = 0.
	




func _physics_process(delta):
	
	if popupOpen:
		
		if Input.is_action_just_pressed('interact'):
			
			if isConfirming:
				
				dungeon.finishDungeon()
				
			
			else:
				
				# ask confirmation
				isConfirming = true
				$Sprite.play('open')
				$Popup/Info.visible = false
				$Popup/Confirmation.visible = true




func areaEntered(area: Area2D):
	if area.get_parent() == player:
		$AnimationPlayerPopup.play('appear')
		popupOpen = true
	
	
func areaExited(area: Area2D):
	if area.get_parent() == player:
		$AnimationPlayerPopup.play('disappear')
		popupOpen = false
		$AnimationPlayerPopup.animation_finished.connect(func(_uhh):
			isConfirming = false
			$Sprite.play('closed')
			$Popup/Info.visible = true
			$Popup/Confirmation.visible = false
			, 4) # oneshot flag
	
