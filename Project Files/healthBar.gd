extends NinePatchRect


@onready var player: = get_parent().get_parent()

var rubies: Array[Node2D] = []


func _ready():
	for i in range(player.maxHealth):
		var ruby: = preload('res://healthRuby.tscn').instantiate()
		ruby.position = Vector2(16 + 32 * i, 16)
		rubies.append(ruby)
		add_child(ruby)


func decreaseHealth(by: int):
	for i in range(by):
		if rubies.back():
			rubies.back().queue_free()
			rubies.pop_back()


func increaseHealth(by: int):
	for i in range(by):
		var ruby: = preload('res://healthRuby.tscn').instantiate()
		ruby.position = Vector2(16 + len(rubies) * 32, 16)
		rubies.append(ruby)
		add_child(ruby)


func healthChanged(by: int):
	if by > 0:
		increaseHealth(by)
	elif by < 0:
		decreaseHealth(-by)

