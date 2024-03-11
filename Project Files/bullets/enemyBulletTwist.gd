extends EnemyBullet


@export var amplitude: float
@export var wavelength: float


func _inheritReady():
	$StateMachine/Twist.amplitude = amplitude
	$StateMachine/Twist.wavelength = wavelength
