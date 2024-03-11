extends Node2D

var cosmetics: PlayerCosmeticData = preload('res://saveData/cosmetics.tres')
const PartNodeNames: Array[String] = ['Shirt', 'Pants']
const partPath: String = 'RedFlashModulate/'

const UnmodulatedSprites: Array[Array] = [
	[],
	[],
]

func updateSprite():
	
	get_node(partPath + 'Body').modulate = cosmetics.skinColor
	get_node(partPath + 'Soul').modulate = cosmetics.soulColor
	
	for i in range(len(PartNodeNames)):
		var node: = get_node(partPath + PartNodeNames[i])
		node.frame = cosmetics.parts[i]
		if !UnmodulatedSprites[i].has(cosmetics.parts[i]):
			node.modulate = cosmetics.plainColors[i]
		for child in node.get_children():
			if child is AnimatedSprite2D:
				child.frame = cosmetics.parts[i]
			
	get_node(partPath + 'Shirt/Tiddies').visible = cosmetics.tiddies
	get_node(partPath + 'Soul').visible = cosmetics.soulVisible
	
	
	
	
func _ready():
	updateSprite()
