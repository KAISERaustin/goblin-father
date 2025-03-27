extends CharacterBody2D
const SPEED = 100.0
const JUMP_VELOCITY = -310.0

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var death_timer: Timer = $DeathTimer
@onready var win_timer: Timer = $WinTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	#Gets the input direction -1, 0, 1
	var direction := Input.get_axis("move_left", "move_right")
	
	#flips the sprite based on the direction variable
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	#play the animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jumping")
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("win"):
		print("WINNER")
		win_timer.start()
	elif area.is_in_group("enemy_slime"):
		print("SLIME")
		$CollisionShape2D.set_deferred("disabled", true)
		death_timer.start()
	elif area.is_in_group("killzone"):
		print("DEAD")
	elif area.is_in_group("solid_block"):
		print("GROUND")
		
func _on_death_timer_timeout() -> void:
	Engine.time_scale = 1.0
	$CollisionShape2D.set_deferred("disabled", false)
	get_tree().reload_current_scene()
	
func _on_win_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
