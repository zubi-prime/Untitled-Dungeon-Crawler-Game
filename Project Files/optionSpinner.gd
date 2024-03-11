extends PanelContainer



@export var options: Array[String]
@export var title: String

@export var disabledOptions: Array[int]

var value: = 0



signal changed


func changeValue(by: int):
	
	value = (value + by + len(options)) % len(options)
	while disabledOptions.has(value):
		value += sign(by)
	value = (value + len(options)) % len(options)
	
	
	updateVisuals()
	
	changed.emit(value)



func _ready():
	changeValue(0)
	
	
func disableOption(i: int):
	if !disabledOptions.has(i):
		disabledOptions.append(i)
		if i == value:
			changeValue(1)
		changed.emit(value)
				
func enableOption(i: int):
	disabledOptions.erase(i)
	
	
	
func updateVisuals():
	if title == '':
		$HBoxContainer/Label.text = options[value]
	else:
		$HBoxContainer/Label.text = title + ': ' + options[value]
