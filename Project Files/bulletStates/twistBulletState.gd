extends State


@export var wavelength: float
@export var amplitude: float


var velocity: = Vector2()

var timeSinceSpawn: = 0.




func _physics_process(delta):
	
	master.position += velocity * delta
	master.position += velocity.normalized().rotated(-PI/2.) * cos(timeSinceSpawn * 2.*PI / wavelength) * (amplitude * 2.*PI / wavelength) * delta
	timeSinceSpawn += delta
	
	
	
