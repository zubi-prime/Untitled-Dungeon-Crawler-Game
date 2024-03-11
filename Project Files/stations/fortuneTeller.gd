extends Station


var upgrades: Array[Upgrade] = []

func _inheritReady():
	for i in range(3):
		var upgrade: = preload('res://upgrade.tscn').instantiate()
		
		if dungeon.forcedUpgradeList.is_empty() or len(dungeon.forcedUpgradeList[0].split('/')) - 1 < i:
			upgrade.title = UpgradeLibrary.getAvailableFortuneReadings().pick_random()
		else:
			upgrade.title = dungeon.forcedUpgradeList[0].split('/')[i]
		
		upgrade.position = position + Vector2(112.*i - 56.*(3. - 1.), 76.)
		upgrade.station = self
		dungeon.add_child(upgrade)
		
		upgrades.append(upgrade)
	
	if !dungeon.forcedUpgradeList.is_empty():
		dungeon.forcedUpgradeList.remove_at(0)


func upgradeChosen(title: String):
	
	GlobalData.fortuneReadings.append(title)
	
	for upgrade in upgrades:
		upgrade.queue_free()
		
	changeDialog(DialogLibrary.StationSplashTextDoneFamiliar[stationTitle].pick_random())
	
	done.emit()
