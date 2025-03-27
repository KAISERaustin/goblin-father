extends CharacterBody2D

const SPEED = 30
var direction = 1

@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight

@onready var head_hit_check: Area2D = $HeadHitCheck

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
 
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0
	
	#will apply the current velocity to move the characterbody2d
	move_and_slide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	#swapes the direction of the slime if the raycast for that side collides with something.  
	if ray_cast_left.is_colliding():
		direction = -1
		#also swapes the sprite based on the side that the slime is moving
		animated_sprite.flip_h = true
	if ray_cast_right.is_colliding():
		direction = 1
		#also swapes the sprite based on the side that the slime is moving
		animated_sprite.flip_h = false
	# the actual movement 
	position.x += direction * SPEED * delta
