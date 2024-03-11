extends Label



func _ready():
	
	await get_tree().create_timer(5., false).timeout
	
	var tween: = create_tween()
	tween.tween_property(self, 'modulate:a', 0, 5.)
