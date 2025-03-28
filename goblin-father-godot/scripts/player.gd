extends CharacterBody2D
const SPEED = 100.0
const JUMP_VELOCITY = -310.0

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var death_timer: Timer = $DeathTimer
@onready var win_timer: Timer = $WinTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_noise: AudioStreamPlayer2D = $JumpNoise
@onready var death_noise: AudioStreamPlayer2D = $DeathNoise
@onready var game_manager: Node = %GameManager

func ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_noise.play()

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

func landed_on_enemy_slime() -> void:
	velocity.y = JUMP_VELOCITY * .75


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("win"):
		win_timer.start()
	elif area.is_in_group("enemy_slime"):
		death_noise.play()
		game_manager.pause_music()
		Engine.time_scale = 0
		death_timer.start()
		
func _on_death_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
	
func _on_win_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
