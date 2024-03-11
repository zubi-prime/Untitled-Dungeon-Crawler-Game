extends State



@export var friction: float
@export var targetDistance: float
@export var moveSpeed: float
@export var rotationSpeed: float

@export var useNavigation: = true

var rotationDir: float = [-1.,1.].pick_random()

func _physics_process(delta):
	
	master.move_and_slide()
	master.velocity *= (1. - friction)
	
	
	if useNavigation:
		var shapecast: ShapeCast2D = master.get_node('PlayerShapecast')
		shapecast.target_position = master.player.attackGlobalPos() - shapecast.global_position
		if shapecast.is_colliding() and shapecast.get_collider(0) != master.player.get_node('Hurtbox'):
			var navAgent: NavigationAgent2D = master.get_node('NavAgent')
			navAgent.target_position = master.player.attackGlobalPos()
			var navSuggestion: Vector2 = (navAgent.get_next_path_position() - master.global_position).normalized()
			
			master.velocity += navSuggestion * moveSpeed * delta
			
			return
	
	
	var strafeDirection: =  master.position.direction_to(master.player.position).rotated(PI/2.) * rotationDir
	var hittingWall: = false
	for i in range(master.get_slide_collision_count()):
		var collision: KinematicCollision2D = master.get_slide_collision(i)
		if strafeDirection.dot(collision.get_normal()) <= 0.:
			strafeDirection = collision.get_normal().rotated((PI/2. + .1) * rotationDir)
			hittingWall = true
			break
			
	if (!hittingWall and (master.position.distance_to(master.player.position) - targetDistance) <= -10.) or (master.position.distance_to(master.player.position) - targetDistance) >= 10.:
		master.velocity += delta * moveSpeed * master.position.direction_to(master.player.position) * sign(master.position.distance_to(master.player.position) - targetDistance) / 2.
		master.velocity += delta * strafeDirection * rotationSpeed / 2.
	else:
		master.velocity += delta * strafeDirection * rotationSpeed
	
	
	
	
