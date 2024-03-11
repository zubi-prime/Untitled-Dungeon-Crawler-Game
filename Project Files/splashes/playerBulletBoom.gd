extends GPUParticles2D

var sound: = true

func _ready():
	if sound:
		$Sound.play()
