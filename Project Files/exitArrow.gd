extends Node2D


var id: int

@onready var dungeon: Dungeon = get_parent().dungeon
@onready var player: = dungeon.get_node('Player')


func _physics_process(delta):
	
	if player.currentRoom and !player.currentRoom.isLocked:
		
		var room: Room = player.currentRoom
		
		if room and room.usedDoors.has(id):
			
			modulate.a = lerp(modulate.a, .15 if room.connectedRooms[id].hasTriggeredEntrance else 1., .18)
			$Sprite.play(room.connectedRooms[id].arrowSkin)
			
			var targetPos: = room.global_position + room.doorPoses()[id] * 48. + room.doorDirs[id] * 288.
			rotation = (targetPos - global_position).angle()
			
		else:
			modulate.a = lerp(modulate.a, 0., .12)
			
	else:
		
		modulate.a = lerp(modulate.a, 0., .12)
			
			
			
		

	
