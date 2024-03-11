extends Node2D


func _ready():
	
	Input.set_custom_mouse_cursor(preload('res://art/cursor.png'))
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	
	var titleScreen: = preload('res://titleScreen.tscn').instantiate()
	add_child(titleScreen)
	titleScreen.size = get_viewport_rect().size
	await titleScreen.startRun
	titleScreen.queue_free()
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	var dungeon: = preload('res://dungeon.tscn').instantiate()
	add_child(dungeon)
	
	
