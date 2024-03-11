extends Node2D
class_name Station

@export var stationTitle: String
@onready var dungeon: Dungeon = get_parent()
@onready var player: = dungeon.get_node('Player')

@onready var dialogTween: = create_tween()


signal done


func _ready():
	
	position.y -= 48. # spaghetti that gives it a bottom margin when spawning
	
	changeDialog(DialogLibrary.StationSplashTextIntroFamiliar[stationTitle].pick_random())
	
	if has_method('_inheritReady'):
		call('_inheritReady')
	


func changeDialog(text: String):
	var dialog: Label = $Dialog
	dialog.text = text
	dialog.visible_ratio = 0.
	dialogTween.stop()
	dialogTween = create_tween()
	dialogTween.tween_property(dialog, 'visible_ratio', 1., len(dialog.text) / 12.)


func playerReturned():
	changeDialog(DialogLibrary.StationSplashTextReturnedFamiliar[stationTitle].pick_random())
