extends Control


signal startRun


func setTooltip(text: String):
	$Tooltip.text = text



func editCharacterPressed():
	
	visible = false
	
	var characterCreator: = preload('res://characterCreator.tscn').instantiate()
	get_parent().add_child(characterCreator)
	characterCreator.size = get_viewport_rect().size
	characterCreator.get_node('Tabs').size.x = get_viewport_rect().size.x / 2.
	
	var cosmeticData: PlayerCosmeticData = await characterCreator.done
	ResourceSaver.save(cosmeticData, 'res://saveData/cosmetics.tres')
	
	characterCreator.queue_free()
	visible = true
	
	
func startRunPressed():
	startRun.emit()
