extends Node


# player stats
var coins: = 0


var RoomSizes: = {}
var RoomDoorPoses: = {}
var RoomDoorDirs: = {}

const RoomList: = {
	'pinkDungeon':
		[
			'normal1',
			'elbow1',
			'ring1',
			'exit'
		]
}


const DungeonSuccessionData: = {
	'pinkDungeon1': {
		'zoneTitle': 'pinkDungeon',
		'dungeonSuccessionTitle': 'pinkDungeon2',
		'dungeonLength': 8.,
		'dungeonDifficulty': 16.,
		'dungeonDifficultyScaling': 2.,
		'hasBoss': true,
		'startWithUpgrade': false,
	},
	'pinkDungeon2': {
		'zoneTitle': 'pinkDungeon',
		'dungeonSuccessionTitle': 'pinkDungeon2',
		'dungeonLength': 8.,
		'dungeonDifficulty': 38.,
		'dungeonDifficultyScaling': 3.,
		'hasBoss': true,
		'startWithUpgrade': false,
	},
	'shoreline1': {
		'zoneTitle': 'pinkDungeon',
		'dungeonSuccessionTitle': 'shoreline2',
		'dungeonLength': 6.,
		'dungeonDifficulty': 106.,
		'dungeonDifficultyScaling': 3.,
		'hasBoss': true,
		'startWithUpgrade': true,
	},
}



var weaponMods: Array[String] = []
var fortuneReadings: Array[String] = []
	
func getUpgradeCount(title: String) -> int:
	var rtrn: = 0
	for mod in fortuneReadings:
		if mod == title:
			rtrn += 1
	for mod in weaponMods:
		if mod == title:
			rtrn += 1
	return rtrn
	
func hasUpgrade(title: String) -> bool:
	return weaponMods.has(title) or fortuneReadings.has(title)





var isInCombat: = false


func _ready():
	for zone in RoomList.keys():
		RoomSizes[zone] = {}
		RoomDoorPoses[zone] = {}
		RoomDoorDirs[zone] = {}
		for roomTitle in RoomList[zone]:
			var room: Room = load('res://rooms/' + zone + '/' + roomTitle + '.tscn').instantiate()
			RoomSizes[zone][roomTitle] = room.size
			RoomDoorPoses[zone][roomTitle] = room.doorPoses()
			RoomDoorDirs[zone][roomTitle] = room.doorDirs




