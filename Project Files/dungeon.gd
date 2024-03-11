extends Node2D
class_name Dungeon

var playerResource: = preload('res://player.tscn')
@onready var player: Player = $Player
@onready var main: = get_parent()


@export var zoneTitle: String
var zoneData: ZoneData


var stationChoiceBias: = 0 # positive is blacksmith. negative is teller



@export var dungeonSuccessionTitle: String # an identifier used to fetch the correct data for the next dungeon from GlobalData



var enemies: Array[Enemy] = []
func countEnemyType(title: String) -> int:
	var rtrn: = 0
	for enemy in enemies:
		if enemy.title == title:
			rtrn += 1
	return rtrn

var enemyBullets: Array[EnemyBullet] = []

var rooms: Array[Room] = []

signal enemyDied
signal enemySpawned
signal allEnemiesDead
signal enemyBulletSpawned
signal enemyBulletDestroyed
signal combatEnded
signal combatStarted
signal roomEntered
signal roomTriggered


# dungeon generation params
@export var dungeonLength: float
@export var dungeonDifficulty: float
@export var dungeonDifficultyScaling: float

@export var startWithUpgrade: = false
@export var hasBoss: = false


# debug 
@export var makePissEasy: = false
@export var forcedStationList: Array[String] = []
@export var forcedUpgradeList: Array[String] = []


var startingRoom: Room
var stemRooms: Array[Room]
var splitRoom: Room
var branchARooms: Array[Room]
var branchAGTRoom: Room
var branchABossRoom: Room
var branchBRooms: Array[Room]
var branchBGTRoom: Room
var branchBBossRoom: Room
var branchAExitRoom: Room
var branchBExitRoom: Room


var corridors: Array[Node2D] = []



func updateCombatDependentStuff(combat: bool):
	
	if combat:
		GlobalData.isInCombat = true
	else:
		GlobalData.isInCombat = false
	




func _ready():
	
	setup()
	
	
func setup():
	
	if makePissEasy:
		dungeonDifficulty = 0.
		dungeonLength = 1.
	zoneData = load('res://zoneDatas/' + zoneTitle + '.tres')
	
	generateDungeon()
	
	
	




func generateDungeon():
	
	var scalingCoefficient: = (dungeonDifficulty * (dungeonDifficultyScaling - 1.)) / (dungeonDifficulty + dungeonLength + 6.) # the scaling part of the room difficulties is multiplied by this to make DungeonDifficultyScaling do its thing. made with wolphram alpha lmao
	
	var newRoom: Room
	
	# note: the  * round(dungeonDifficulty / float((dungeonLength*4 + 12))) in the combatDifficulty lines is quick maffs so that the first room will have dungeonDifficulty difficulty, and the last room will have dungeonDifficulty*dungeonDifficultyScaling difficulty
	
	# This whole function is a shit ton of spaghetti code and trying to rember how it works hurts my brain. However, it is very efficient, so I don't care.
	
	var addSequentialRoom: = func(sequence: Array[Room], _recursive: Callable, stack: = 0) -> Room:
		newRoom = addRoom(sequence.back())
		if !newRoom:
			
			if stack >= 80:
				#fuck
				return null
				
			else:
				var from: Room = sequence.back()
				sequence.erase(from)
				removeRoom(from)
				if sequence.is_empty():
					#fuck
					return null
				sequence.append(addRoom(sequence.back()))
				newRoom = _recursive.call(_recursive, stack + 1)
			
				return newRoom
		
		return newRoom
	
	var addChallengeRoom: = func(from: Array[Room]) -> Room:
		var shuffledRooms: = from.duplicate(); shuffledRooms.shuffle()
		for room in shuffledRooms:
			newRoom = addRoom(room)
			if newRoom:
				break
		if !newRoom:
			# fuck
			destroyDungeon()
			generateDungeon()
			return null
		
		newRoom.waveCount = 2
		newRoom.lesserTreasureCount += 1
		newRoom.arrowSkin = 'red'
		
		return newRoom
	
	
	var addEliteRoom: = func(from: Array[Room], _recursive: Callable, stack: = 0) -> Room:
		
		# combat room
		var shuffledRooms: = from.duplicate(); shuffledRooms.shuffle()
		for room in shuffledRooms:
			newRoom = addRoom(room)
			if newRoom:
				break
		if !newRoom:
			#fuck
			destroyDungeon()
			generateDungeon()
			return null
		
		newRoom.waveCount = 1
		newRoom.altEnemyListQueue.append(0)
		newRoom.arrowSkin = 'red skull'
		var eliteRoom: = newRoom
		# upgrade room
		newRoom = addRoom(eliteRoom)
		if !newRoom:
			
			if stack >= 120:
				#fuck
				destroyDungeon()
				generateDungeon()
				return null
			else:
				removeRoom(eliteRoom)
				return _recursive.call(from, _recursive, stack + 1)
			
		newRoom.arrowSkin = 'blue'
		newRoom.type = Room.TypeGreaterTreasure
		
		return eliteRoom
	
	# stem
	
	# add starting room. bethesda pls fix
	newRoom = load('res://rooms/' + zoneData.title + '/' + zoneData.rooms[0] + '.tscn').instantiate()
	add_child(newRoom)
	rooms.append(newRoom)
	newRoom.type = Room.TypeGreaterTreasure if startWithUpgrade else Room.TypeEmpty
	newRoom.arrowSkin = 'blue' if startWithUpgrade else 'white'
	startingRoom = newRoom
	
	startingRoom.position = player.position - startingRoom.centerSpawningPoint
	if startWithUpgrade: startingRoom.position += Vector2(0,-96)
	
	
	# add first room of stem
	newRoom = addRoom(rooms[0])
	stemRooms.append(newRoom)
	newRoom.combatDifficulty = round(dungeonDifficulty * randf_range(.8,1.2))
	newRoom.arrowSkin = 'white'
	
	
	# add rest of stem
	
	for i in range(round(dungeonLength * 3./5. * randf_range(.8,1.2)) - 1):
		newRoom = addSequentialRoom.call(stemRooms, addSequentialRoom)
		if !newRoom:
			# fuck
			destroyDungeon()
			generateDungeon()
			return
		newRoom.combatDifficulty = randf_range(.8,1.2) * dungeonDifficulty + ((i + 1.)*2.) * scalingCoefficient
		newRoom.arrowSkin = 'white'
		
		stemRooms.append(newRoom)
	
	
	# challenge/elite rooms
	
	for i in range(round(dungeonLength * 2./15.)):
		newRoom = addChallengeRoom.call(stemRooms)
		if newRoom:
			newRoom.combatDifficulty = randf_range(.8,1.2) * dungeonDifficulty + ((1. + (dungeonDifficultyScaling - 1.) * 1.8))
		else:
			return
	
	
	# add split room
	
	newRoom = addRoom(stemRooms[len(stemRooms) - 1])
	if !newRoom:
		# fuck
		destroyDungeon()
		generateDungeon()
		return
	newRoom.type = Room.TypeGreaterTreasure
	newRoom.arrowSkin = 'blue'
	splitRoom = newRoom
	
	# add branch A
	
	# first
	newRoom = addRoom(splitRoom)
	if !newRoom:
			# fuck
			destroyDungeon()
			generateDungeon()
			return
	branchARooms.append(newRoom)
	newRoom.combatDifficulty = randf_range(.8,1.2) * dungeonDifficulty + (6. + (dungeonLength * 3./5.) * 2.) * scalingCoefficient
	newRoom.arrowSkin = 'white'
	
	# rest
	
	for i in range(round(dungeonLength * 2./5. * randf_range(.8,1.2)) - 1):
		newRoom = addSequentialRoom.call(branchARooms, addSequentialRoom)
		if !newRoom:
			# fuck
			destroyDungeon()
			generateDungeon()
			return
		newRoom.combatDifficulty = randf_range(.8,1.2) * dungeonDifficulty + ((i + 1.)*2 + 6. + (dungeonLength * 3./5.) * 2.) * scalingCoefficient
		newRoom.arrowSkin = 'white'
		
		branchARooms.append(newRoom)
	
	# gt room
	newRoom = addRoom(branchARooms.back())
	if !newRoom:
		# fuck
		destroyDungeon()
		generateDungeon()
		return
	branchAGTRoom = newRoom
	newRoom.type = Room.TypeGreaterTreasure
	newRoom.arrowSkin = 'blue'
	
	if hasBoss: # boss room
		newRoom = addRoom(branchAGTRoom)
		if !newRoom:
			# fuck
			destroyDungeon()
			generateDungeon()
			return
		branchABossRoom = newRoom
		newRoom.type = Room.TypeEmpty
		newRoom.arrowSkin = 'white skull'
	
	# exit room
	newRoom = addRoom(branchABossRoom if hasBoss else branchAGTRoom, false, 'exit')
	if !newRoom:
		# fuck
		destroyDungeon()
		generateDungeon()
		return
	branchAExitRoom = newRoom
	newRoom.type = Room.TypeExit
	newRoom.arrowSkin = 'exit'
	add_child(newRoom)
	
	# challenge/elite rooms
	for i in range(round(dungeonLength * 2./15.)):
		newRoom = addChallengeRoom.call(branchARooms)
		if newRoom:
			newRoom.combatDifficulty = randf_range(.8,1.2) * dungeonDifficulty + ((1. + (dungeonDifficultyScaling - 1.) * 2.))
		else:
			return
	for i in range(2 if dungeonLength >= 15 else 1):
		newRoom = addEliteRoom.call(branchARooms, addEliteRoom)
		if newRoom:
			newRoom.combatDifficulty = randf_range(.8,1.2) * dungeonDifficulty + ((1. + (dungeonDifficultyScaling - 1.) * 3.))
		else:
			return
	
	
	# add branch B
	
	# first
	newRoom = addRoom(splitRoom)
	if !newRoom:
			# fuck
			destroyDungeon()
			generateDungeon()
			return
	branchBRooms.append(newRoom)
	newRoom.combatDifficulty = randf_range(.8,1.2) * dungeonDifficulty + (6. + (dungeonLength * 3./5.) * 2.) * scalingCoefficient
	newRoom.arrowSkin = 'white'
	
	# rest
	
	for i in range(round(dungeonLength * 2./5. * randf_range(.8,1.2)) - 1):
		newRoom = addSequentialRoom.call(branchBRooms, addSequentialRoom)
		if !newRoom:
			# fuck
			destroyDungeon()
			generateDungeon()
			return
		newRoom.combatDifficulty = randf_range(.8,1.2) * dungeonDifficulty + ((i + 1.)*2 + 6. + (dungeonLength * 3./5.) * 2.) * scalingCoefficient
		newRoom.arrowSkin = 'white'
		
		branchBRooms.append(newRoom)
	
	# gt room
	newRoom = addRoom(branchBRooms.back())
	if !newRoom:
		# fuck
		destroyDungeon()
		generateDungeon()
		return
	branchBGTRoom = newRoom
	newRoom.type = Room.TypeGreaterTreasure
	newRoom.arrowSkin = 'blue'
	
	if hasBoss: # boss room
		newRoom = addRoom(branchBGTRoom)
		if !newRoom:
			# fuck
			destroyDungeon()
			generateDungeon()
			return
		branchBBossRoom = newRoom
		newRoom.type = Room.TypeEmpty
		newRoom.arrowSkin = 'white skull'
	
	# exit room
	newRoom = addRoom(branchBBossRoom if hasBoss else branchBGTRoom, false, 'exit')
	if !newRoom:
		# fuck
		destroyDungeon()
		generateDungeon()
		return
	branchBExitRoom = newRoom
	newRoom.type = Room.TypeExit
	newRoom.arrowSkin = 'exit'
	add_child(newRoom)
	
	# challenge/elite rooms
	for i in range(round(dungeonLength * 2./15.)):
		newRoom = addChallengeRoom.call(branchBRooms)
		if newRoom:
			newRoom.combatDifficulty = randf_range(.8,1.2) * dungeonDifficulty + ((1. + (dungeonDifficultyScaling - 1.) * 2.))
		else:
			return
	for i in range(2 if dungeonLength >= 15 else 1):
		newRoom = addEliteRoom.call(branchBRooms, addEliteRoom)
		if newRoom:
			newRoom.combatDifficulty = randf_range(.8,1.2) * dungeonDifficulty + ((1. + (dungeonDifficultyScaling - 1.) * 3.))
		else:
			return
	
	
	# add treasure to rooms
	for i in range(2): # stem
		stemRooms.pick_random().lesserTreasureCount += 1
	for i in range(2): # a
		branchARooms.pick_random().lesserTreasureCount += 1
	for i in range(2): # b
		branchBRooms.pick_random().lesserTreasureCount += 1
	
	
	# calibrate rooms
	for room in rooms:
		room.calibrate()
	

func destroyDungeon():
	
	for child in get_children():
		
		if child != player:
			child.queue_free()
		
	
	rooms = []
	stemRooms = []
	splitRoom = null
	branchABossRoom = null
	branchAGTRoom = null
	branchBBossRoom = null
	branchBGTRoom = null
	branchAExitRoom = null
	branchBExitRoom = null
	branchARooms = []
	branchBRooms = []
	corridors = []
	
	
	
	
func finishDungeon(exitId: = 0):
	
	destroyDungeon()
	
	var data: Dictionary = GlobalData.DungeonSuccessionData[dungeonSuccessionTitle]
	for key in data.keys():
		set(key, data[key])
	
	
	player.currentRoom = null
	player.changeHealth(player.maxHealth - player.health)
	
	setup()
	
	
	
func addRoomRaw(path: String, fromRoom: Room, fromDoor: int, intoDoor: int, addToTree: = true) -> Room:
	var newRoom: Room = load('res://rooms/' + path + '.tscn').instantiate()
	newRoom.position = fromRoom.position + (fromRoom.doorPoses()[fromDoor] - newRoom.doorPoses()[intoDoor]) * 48 + fromRoom.doorDirs[fromDoor] * 576. 
	
	rooms.append(newRoom)
	
	if addToTree:
		add_child(newRoom)
	
	fromRoom.usedDoors.append(fromDoor)
	newRoom.usedDoors.append(intoDoor)
	
	fromRoom.connectedRooms[fromDoor] = newRoom
	newRoom.connectedRooms[intoDoor] = fromRoom
	
	var corridor: Node2D
	if fromRoom.doorDirs[fromDoor].y == 0:
		corridor = preload('res://corridorH.tscn').instantiate()
	else:
		corridor = preload('res://corridorV.tscn').instantiate()
	
	corridor.position = fromRoom.position + fromRoom.doorPoses()[fromDoor] * 48 + fromRoom.doorDirs[fromDoor] * 288.
	
	add_child(corridor)
	corridors.append(corridor)
	fromRoom.corridors.append(corridor)
	newRoom.corridors.append(corridor)
	
	
	return newRoom


func removeRoom(room: Room):
	
	for corridor in room.corridors:
		corridor.queue_free()
	
	for connectedRoom: Room in room.connectedRooms.values():
		var door: int = connectedRoom.connectedRooms.keys()[connectedRoom.connectedRooms.values().find(room)]
		connectedRoom.connectedRooms.erase(door)
		connectedRoom.usedDoors.erase(door)
	
	room.queue_free()
	rooms.erase(room)
	# make sure to erase the room from any other lists its in outside of the function



func addRoom(fromRoom: Room, addToTree: = true, roomOptionsOverride: = ''):
	
	var roomsFromDirection: = {
		Vector2(1,0): zoneData.roomsFromLeft,
		Vector2(-1,0): zoneData.roomsFromRight,
		Vector2(0,-1): zoneData.roomsFromDown,
		Vector2(0,1): zoneData.roomsFromUp,
	}
	
	var exits: = range(len(fromRoom.doorDirs))
	
	exits.shuffle()
	for fromExit in exits:
		var possibleRooms: Array[String] = roomsFromDirection[fromRoom.doorDirs[fromExit]]
		if roomOptionsOverride == 'exit':
			possibleRooms = zoneData.exitRooms
		possibleRooms.shuffle()
		for newRoom in possibleRooms:
			var possibleExits: = range(len(GlobalData.RoomDoorDirs[zoneData.title][newRoom]))
			possibleExits.shuffle()
			for toExit in possibleExits:
				if GlobalData.RoomDoorDirs[zoneData.title][newRoom][toExit] == -fromRoom.doorDirs[fromExit]:
					var roomRect: = Rect2(fromRoom.doorDirs[fromExit] * 576. + fromRoom.position + (fromRoom.doorPoses()[fromExit] - GlobalData.RoomDoorPoses[zoneData.title][newRoom][toExit]) * 48., GlobalData.RoomSizes[zoneData.title][newRoom] * 48.)
					
					var fits: = true
					for room in rooms:
						if Rect2(room.position, room.size * 48.).intersects(roomRect):
							fits = false
							break
					if fits:
						return addRoomRaw(zoneData.title + '/' + newRoom, fromRoom, fromExit, toExit, addToTree)
	return null


func onEnemyDied(enemy: Enemy):
	if enemies.is_empty():
		allEnemiesDead.emit()
	enemyDied.emit()
	
	
func onEnemySpawned(enemy: Enemy):
	enemySpawned.emit()
	


	
	
func onCombatEnded():
	
	updateCombatDependentStuff(false)
	

func onCombatStarted():
	
	updateCombatDependentStuff(true)
	
