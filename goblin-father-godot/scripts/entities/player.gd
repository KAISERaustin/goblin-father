# res://scripts/player.gd
extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -310.0

# — NodePath injections for child nodes —
@export var body_collider_path: NodePath  = NodePath("BodyCollider")
@export var death_timer_path: NodePath      = NodePath("DeathTimer")
@export var win_timer_path: NodePath        = NodePath("WinTimer")
@export var animated_sprite_path: NodePath  = NodePath("AnimatedSprite2D")
@export var jump_noise_path: NodePath       = NodePath("JumpNoise")
@export var death_noise_path: NodePath      = NodePath("DeathNoise")
@export var pipe_noise_path: NodePath       = NodePath("PipeNoise")
@export var pipe_timer_path: NodePath       = NodePath("PipeTimer")
@export var body_check_path: NodePath       = NodePath("Body Check")

# — Onready node references resolved via the exported paths —
@onready var body_collider:       CollisionShape2D     = get_node(body_collider_path)
@onready var death_timer:         Timer                = get_node(death_timer_path)
@onready var win_timer:           Timer                = get_node(win_timer_path)
@onready var animated_sprite:     AnimatedSprite2D     = get_node(animated_sprite_path)
@onready var jump_noise:          AudioStreamPlayer2D  = get_node(jump_noise_path)
@onready var death_noise:         AudioStreamPlayer2D  = get_node(death_noise_path)
@onready var pipe_noise:          AudioStreamPlayer2D  = get_node(pipe_noise_path)
@onready var pipe_timer:          Timer                = get_node(pipe_timer_path)
@onready var body_check:          Area2D               = get_node(body_check_path)


var exiting_pipe: bool = false

func _ready() -> void:
	# Register in the "player" group
	add_to_group("player")
	# Connect timers' timeout signals (if not wired in the editor)
	death_timer.timeout.connect(_on_death_timer_timeout)
	win_timer.timeout.connect(_on_win_timer_timeout)
	pipe_timer.timeout.connect(_on_pipe_timer_timeout)
	body_check.body_entered.connect(_on_body_check_body_entered)


func _physics_process(delta: float) -> void:
	# Apply gravity if airborne
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump input
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_noise.play()

	# Horizontal input
	var direction := Input.get_axis("move_left", "move_right")
	animated_sprite.flip_h = (direction < 0)

	# Play animations based on state
	if is_on_floor() and not exiting_pipe:
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	elif not exiting_pipe:
		animated_sprite.play("jumping")

	# Smooth horizontal movement
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func landed_on_enemy_slime() -> void:
	# Bounce on slime
	velocity.y = JUMP_VELOCITY * 0.75

func _on_body_check_body_entered(body) -> void:
	# Win, death, or pipe interactions
	if body.is_in_group("win"):
		set_physics_process(false)
		win_timer.start()
	elif body.is_in_group("enemy_slime"):
		GameManager.handle_player_death()
		death_noise.play()
		Engine.time_scale = 0
		death_timer.start()
	elif body.is_in_group("pipe"):
		set_physics_process(false)
		animated_sprite.play("pipe_up")
		pipe_noise.play()
		exiting_pipe = true
		pipe_timer.start()
		velocity.y = 0

func _on_death_timer_timeout() -> void:
	Engine.time_scale = 1
	SceneManager.reload_current()

func _on_win_timer_timeout() -> void:
	SceneManager.change_scene("res://scenes/main_menu.tscn")

func _on_pipe_timer_timeout() -> void:
	# After pipe animation, restore control
	animated_sprite.flip_h = false
	animated_sprite.play("pipe_right")
	await get_tree().create_timer(0.75).timeout
	set_physics_process(true)
	exiting_pipe = false
