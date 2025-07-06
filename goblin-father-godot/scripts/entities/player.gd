extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -310.0
var exiting_pipe = false

@onready var collision_shape_2d: CollisionShape2D     = $CollisionShape2D
@onready var death_timer: Timer                      = $DeathTimer
@onready var win_timer: Timer                        = $WinTimer
@onready var animated_sprite: AnimatedSprite2D       = $AnimatedSprite2D
@onready var jump_noise: AudioStreamPlayer2D         = $JumpNoise
@onready var death_noise: AudioStreamPlayer2D        = $DeathNoise
@onready var game_manager: Node                      = %GameManager
@onready var pipe_noise: AudioStreamPlayer2D         = $PipeNoise
@onready var pipe_timer: Timer                       = $PipeTimer

func _ready() -> void:
	# Register this node in the "player" group
	add_to_group("player")

func _physics_process(delta: float) -> void:
	# Apply gravity if airborne
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump input
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_noise.play()

	# Left/right input (-1, 0, +1)
	var direction := Input.get_axis("move_left", "move_right")
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Footprint animations
	if is_on_floor() and not exiting_pipe:
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	elif not exiting_pipe:
		animated_sprite.play("jumping")

	# Horizontal velocity (with smoothing when no input)
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func landed_on_enemy_slime() -> void:
	# Called by slime to bounce the player
	velocity.y = JUMP_VELOCITY * 0.75

func _on_area_2d_area_entered(area: Area2D) -> void:
	# Win, death, and pipe interactions
	if area.is_in_group("win"):
		set_physics_process(false)
		win_timer.start()
	elif area.is_in_group("enemy_slime"):
		death_noise.play()
		game_manager.pause_music()
		Engine.time_scale = 0
		death_timer.start()
	elif area.is_in_group("pipe"):
		set_physics_process(false)
		animated_sprite.play("pipe_up")
		pipe_noise.play()
		exiting_pipe = true
		pipe_timer.start()
		velocity.y = 0

func _on_death_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()

func _on_win_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_pipe_timer_timeout() -> void:
	# After pipe animation, restore control
	animated_sprite.flip_h = false
	animated_sprite.play("pipe_right")
	await get_tree().create_timer(0.75).timeout
	set_physics_process(true)
	exiting_pipe = false
