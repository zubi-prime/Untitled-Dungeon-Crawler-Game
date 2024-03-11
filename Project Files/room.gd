extends Node2D
class_name Room


enum {TypeEmpty, TypeCombat, TypeGreaterTreasure, TypeBoss, TypeExit}

const StationTitles: = ['blacksmith', 'fortuneTeller']


@onready var dungeon: Dungeon = get_parent()
@onready var player: = dungeon.get_node('Player')

@export var doorDirs: Array[Vector2]
@export var size: Vector2


var connectedRooms: = {}

var arrowSkin: String




var type: = TypeCombat


var usedDoors: Array[int] = []

var doorBlockers: = {}

var corridors: Array[Node2D] = []

var spawningRects: Array[Rect2]


@onready var centerSpawningPoint: Vector2 = $TiledScale/CenterSpawningPoint.position * 48.


var hasTriggeredEntrance: = false
var hasBeenLeft: = false

var isLocked: = false


# type specific vars:

# combat:
var combatDifficulty: float
var waveCount: int = randi_range(2,3)


var enemyList: = {
	'shadowMeson' : 1.,
	'pyromancerTrainee' : .875,
	'ligamancer' : .7,
}

var enemyCosts: = {
	'shadowMeson' : 1,
	'pyromancerTrainee' : 1,
	'ligamancer' : 8,
}

var altEnemyLists: Array[Dictionary] = [
	{
		'shadowMesonElite': 1.,
	}
]

var altEnemyCosts: Array[Dictionary] = [
	{
		'shadowMesonElite': 3,
	}
]

var altEnemyListQueue: Array[int] = []

var lesserTreasureCount: = 0


# greater treasure:

var station: Station

# /type specific vars



func doorPoses() -> Array[Vector2]:
	var rtrn: Array[Vector2] = []
	for child in $TiledScale/Doors.get_children():
		rtrn.append(child.position)
	return rtrn


func getSpawningPosition(boundingSize: = Vector2(0,0)) -> Vector2:
	var pos: Vector2
	var positionFits: = spawningRects.is_empty()
	pos = position + Vector2(randf_range(boundingSize.x / 2. + 96. + 48., size.x * 48 - (boundingSize.x / 2.) - 96. - 48.), randf_range(boundingSize.y + 96. + 48., size.y * 48 - 96. - 48.))
	while !positionFits:
		pos = position + Vector2(randf_range(boundingSize.x / 2. + 96. + 48., size.x * 48 - (boundingSize.x / 2.) - 96. + 48.), randf_range(boundingSize.y + 96. + 48., size.y * 48 - 96. + 48.))
		positionFits = false
		var enemyRect: = Rect2(pos - position - Vector2(boundingSize.x / 2., boundingSize.y), boundingSize)
		for rect in spawningRects:
			if enemyRect.get_area() == Rect2(rect.position * 48., rect.size * 48.).intersection(enemyRect).get_area():
				positionFits = true
				break # yes I know this will require the object to be entirely inside 1 spawning rect I don't care
	return pos


func spawnEnemies():
	var waveData: = generateCombatWaves(combatDifficulty)
	
	# select enemies to have lts
	var sum: = 0
	for wave in waveData:
		sum += len(wave)
	var lesserTreasureList: = []
	for i in range(lesserTreasureCount):
		var treasureOption: = randi_range(0, sum - 1)
		while lesserTreasureList.has(treasureOption):
			treasureOption = randi_range(0, sum - 1)
		lesserTreasureList.append(treasureOption)
		
	var enemyCounter: = 0
	for wave in waveData:
		for enemyTitle in wave:
			var enemy: Enemy = load('res://enemies/' + enemyTitle + '.tscn').instantiate()
			enemy.position = getSpawningPosition(enemy.boundingSize)
			
			
			dungeon.call_deferred('add_child', enemy)
			
			if lesserTreasureList.has(enemyCounter):
				enemy.drops.append('lesserTreasure')
			
			enemyCounter += 1
		await dungeon.allEnemiesDead
	

		
		
		
func generateCombatWaves(difficulty: int) -> Array:
	var waveData: = []
	for waveNum in range(waveCount):
		waveData.append([])
		var budget: int = max(1, roundi(randf_range(0.8, 1.2) * difficulty / waveCount))
		while budget > 0:
			var enemyChoice: String = Handy.weightedChoice(enemyList if altEnemyListQueue.is_empty() else altEnemyLists[altEnemyListQueue[0]])
			var stack: = 0
			while (enemyCosts if altEnemyListQueue.is_empty() else altEnemyCosts[altEnemyListQueue[0]])[enemyChoice] > budget and stack < 255:
				enemyChoice = Handy.weightedChoice(enemyList if altEnemyListQueue.is_empty() else altEnemyLists[altEnemyListQueue[0]])
				stack += 1
			budget -= (enemyCosts if altEnemyListQueue.is_empty() else altEnemyCosts[altEnemyListQueue[0]])[enemyChoice]
			waveData[waveNum].append(enemyChoice)
			if !altEnemyListQueue.is_empty():
				altEnemyListQueue.remove_at(0)
	return waveData


func areaEntered(area: Area2D):
	
	dungeon.roomEntered.emit(self)
	
	if area.get_parent() == player:
		if !hasTriggeredEntrance:
			
			dungeon.roomTriggered.emit(self)
			
			hasTriggeredEntrance = true
			
			match type:
				
				TypeEmpty:
					
					pass
					
				TypeCombat:
						
					dungeon.combatStarted.emit()
					
					lockRoom()
					
					await spawnEnemies()
					
					unlockRoom()
							
					dungeon.combatEnded.emit()
				
				TypeGreaterTreasure:
					
					lockRoom()
					
					var title: String
					if dungeon.forcedStationList.is_empty():
						if UpgradeLibrary.getAvailableWeaponMods().is_empty():
								title = 'fortuneTeller'
						elif UpgradeLibrary.getAvailableFortuneReadings().is_empty():
								title = 'blacksmith'
						else:
							match abs(dungeon.stationChoiceBias):
								2:
									if dungeon.stationChoiceBias == 2:
										title = 'blacksmith'
									else:
										title = 'fortuneTeller'
								1:
									if dungeon.stationChoiceBias == 1:
										title = ['blacksmith', 'blacksmith', 'fortuneTeller'].pick_random()
									else:
										title = ['blacksmith', 'fortuneTeller', 'fortuneTeller'].pick_random()
								0:
									title = ['blacksmith', 'fortuneTeller'].pick_random()
					else:
						title = dungeon.forcedStationList[0]
						dungeon.forcedStationList.remove_at(0)
					
					var biasDir: int = {'blacksmith':-1,'fortuneTeller':1}[title]
					match sign(dungeon.stationChoiceBias) * sign(biasDir):
						1, 0: dungeon.stationChoiceBias += biasDir
						-1: dungeon.stationChoiceBias = 0
					
					var station: Station = spawnStation(title)
					await station.done
					
					unlockRoom()
		else:
			match type:
				
				TypeEmpty:
					
					pass
					
				TypeCombat:
						
					pass
				
				TypeGreaterTreasure:
					
					if hasBeenLeft:
						station.playerReturned()
						
	hasBeenLeft = false






func calibrate():
	
	dungeon.roomEntered.connect(func(room: Room): if room != self: otherRoomEntered(room))
	
	# seal unused doors
	for i in range(len(doorDirs)):
		if !usedDoors.has(i):
			var tileMap: TileMap = $TileMap
			var poses: = doorPoses()
			tileMap.set_cells_terrain_connect(1, [doorPoses()[i], doorPoses()[i] + Vector2(0,-1), doorPoses()[i] + Vector2(-1,-1), doorPoses()[i] + Vector2(-1,0)] + {
				Vector2(1,0): [poses[i] + Vector2(-2,-1), poses[i] + Vector2(-2,0)],
				Vector2(-1,0): [poses[i] + Vector2(1,-1), poses[i] + Vector2(1,0)],
				Vector2(0,1): [poses[i] + Vector2(0,-2), poses[i] + Vector2(-1,-2)],
				Vector2(0,-1): [poses[i] + Vector2(0,1), poses[i] + Vector2(-1,1)],
			}[doorDirs[i]], 0, 0)
	
	
	if has_node('TiledScale/SpawningRects'): # calculate spawningRects
		for child in $TiledScale/SpawningRects.get_children():
			spawningRects.append(Rect2(child.position, child.size))
	
	
	match type:
		
		TypeEmpty:
			
			pass
			
		
		TypeCombat:
			
			pass
			
		TypeGreaterTreasure:
			
			pass
			
		TypeExit:
			
			var exitDoor: = preload('res://exitDoor.tscn').instantiate()
			exitDoor.position = position + centerSpawningPoint
			dungeon.add_child(exitDoor)



func spawnStation(title: String) -> Station:
	station = load('res://stations/' + title + '.tscn').instantiate()
	station.position = position + centerSpawningPoint
	dungeon.call_deferred('add_child', station)
	return station
	
	
func lockRoom():
	
	# add blockers to used 8oors
	for i in range(len(doorPoses())):
		if usedDoors.has(i):
			var blocker: = preload('res://doorBlocker.tscn').instantiate()
			blocker.position = position + doorPoses()[i] * 48.
			dungeon.add_child(blocker)
			doorBlockers[i] = blocker
	isLocked = true


func unlockRoom():
	
	# remove blockers from used doors
	for i in range(len(doorPoses())):
		if usedDoors.has(i):
			doorBlockers[i].queue_free()
			doorBlockers.erase(i)
	isLocked = false


func otherRoomEntered(room: Room):
	if hasTriggeredEntrance:
		hasBeenLeft = true

