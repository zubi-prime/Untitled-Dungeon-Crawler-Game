extends Control

var cosmeticData: PlayerCosmeticData

@onready var previewSprite: Node2D = $Preview



signal done


func _ready():
	
	loadCosmeticData(load('res://saveData/cosmetics.tres'))
	
	
	previewSprite.updateSprite()
	
	
	for partName in cosmeticData.PartNames:
		var node: = get_node('Tabs/Clothes/VBox/' + partName)
		if node: 
			node.changed.connect(Callable(partChanged).bind(partName))
			
	for partName in cosmeticData.PartNames:
		var node: = get_node('Tabs/Colors/VBox/' + partName)
		if node: 
			node.color_changed.connect(Callable(colorChanged).bind(partName))
			
			
	$Tabs/Body/VBox/SkinColor.color_changed.connect(func(color: Color):
		cosmeticData.skinColor = color
		previewSprite.updateSprite()
	)
	
	$Tabs/Body/VBox/SoulColor.color_changed.connect(func(color: Color):
		cosmeticData.soulColor = color
		previewSprite.updateSprite()
	)
	
	$Tabs/Body/VBox/Tiddies.toggled.connect(func(value: bool):
		
		var shirt: = $Tabs/Clothes/VBox/Shirt
		cosmeticData.tiddies = value
		previewSprite.updateSprite()
		
		if value == true:
			shirt.disableOption(0)
		else:
			shirt.enableOption(0)
		
	)
	$Tabs/Body/VBox/SoulVisible.toggled.connect(func(value: bool):
		
		cosmeticData.soulVisible = value
		previewSprite.updateSprite()
		
	)
	



func partChanged(value: int, title: String):
	cosmeticData.parts[cosmeticData.PartNames.find(title)] = value
	previewSprite.updateSprite()

func colorChanged(value: Color, title: String):
	cosmeticData.plainColors[cosmeticData.PartNames.find(title)] = value
	previewSprite.updateSprite()


func confirmPressed():
	done.emit(cosmeticData)
	
	
	
	
	
func loadCosmeticData(loadData: PlayerCosmeticData):
	cosmeticData = loadData
	
	# oh lawd he comin
	$Tabs/Body/VBox/SkinColor.color = cosmeticData.skinColor
	$Tabs/Body/VBox/SoulColor.color = cosmeticData.soulColor
	$Tabs/Body/VBox/Tiddies.set_pressed_no_signal(cosmeticData.tiddies)
	$Tabs/Body/VBox/SoulVisible.set_pressed_no_signal(cosmeticData.soulVisible)
	$Tabs/Clothes/VBox/Shirt.value = cosmeticData.parts[0]; $Tabs/Clothes/VBox/Shirt.updateVisuals()
	$Tabs/Clothes/VBox/Pants.value = cosmeticData.parts[1]; $Tabs/Clothes/VBox/Pants.updateVisuals()
	$Tabs/Colors/VBox/Shirt.color = cosmeticData.plainColors[0]
	$Tabs/Colors/VBox/Pants.color = cosmeticData.plainColors[1]
	
	if cosmeticData.tiddies:
		$Tabs/Clothes/VBox/Shirt.disableOption(0)
	else:
		$Tabs/Clothes/VBox/Shirt.enableOption(0)
	
	
	
	
