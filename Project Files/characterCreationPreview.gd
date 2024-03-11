extends Node2D

@onready var creator: Control = get_parent()
const PartNodeNames: Array[String] = ['Shirt', 'Pants']

const UnmodulatedSprites: Array[Array] = [
	[],
	[],
]


func updateSprite():
	
	$Body.modulate = creator.cosmeticData.skinColor
	$Soul.modulate = creator.cosmeticData.soulColor
	
	for i in range(len(PartNodeNames)):
		var node: = get_node(PartNodeNames[i])
		node.frame = creator.cosmeticData.parts[i]
		if !UnmodulatedSprites[i].has(creator.cosmeticData.parts[i]):
			node.modulate = creator.cosmeticData.plainColors[i]
		for child in node.get_children():
			if child is AnimatedSprite2D:
				child.frame = creator.cosmeticData.parts[i]
			
	$Shirt/Tiddies.visible = creator.cosmeticData.tiddies
	$Soul.visible = creator.cosmeticData.soulVisible
	
	
