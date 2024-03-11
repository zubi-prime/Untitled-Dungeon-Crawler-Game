extends Area2D
class_name Upgrade


@onready var dungeon: Dungeon = get_parent()
@onready var player: = dungeon.get_node('Player')

@export var title: String


var popupOpen: = false






var isConfirming: = false

var station: Station



func _ready():
	$Sprite.texture = load('res://art/upgrades/' + title + '.png')
	$Popup.scale.y = 0.
	$Popup/Info/Title.text = UpgradeLibrary.UpgradeShownTitles[title]
	$Popup/Info/Description.text = UpgradeLibrary.UpgradeDescriptions[title]
	
	$Popup/Confirmation.visible = false
	




func _physics_process(delta):
	
	if popupOpen:
		if Input.is_action_just_pressed('interact'):
			
			if isConfirming:
				
				# is chosen
				station.upgradeChosen(title)
			
			else:
				
				# ask confirmation
				isConfirming = true
				$Popup/Info.visible = false
				$Popup/Confirmation.visible = true
	
	
	# make popup bigger if needed to contain content
	$Popup/Background.size = $Popup/Info.size + Vector2(24, 24)
	$Popup/Background.position = $Popup/Info.position + Vector2(0,-12)




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
			$Popup/Info.visible = true
			$Popup/Confirmation.visible = false
			, 4) # oneshot flag
	


