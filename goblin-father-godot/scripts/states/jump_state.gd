# res://scenes/jump_state.gd
extends Node
class_name JumpState

@export var jump_noise_path:      NodePath = NodePath("JumpNoise")
@export var jump_cut_multiplier:  float   = 0.5
@export var max_jump_height:      float   = 240.0    # Maximum rise (in pixels) above jump start

@onready var jump_noise: AudioStreamPlayer2D = get_node(jump_noise_path)

var _start_y: float

func _ready() -> void:
	pass

func enter(player_node) -> void:
	# Record where we began the jump
	_start_y = player_node.global_position.y
	# Apply initial jump impulse
	player_node.velocity.y = player_node.JUMP_VELOCITY
	jump_noise.play()

func exit(_player_node) -> void:
	pass

func physics_process(player_node, delta: float) -> void:
	# --- Horizontal control in air ---
	var dir = Input.get_axis("move_left", "move_right")
	if dir != 0:
		var target = dir * player_node.SPEED
		# Using half your ground ACCELERATION for air steering
		var air_accel = player_node.ACCELERATION * delta
		player_node.velocity.x = move_toward(player_node.velocity.x, target, air_accel)
		player_node.animated_sprite.flip_h = dir < 0

	# --- Clamp max jump height ---
	if player_node.velocity.y < 0:
		var risen = _start_y - player_node.global_position.y
		if risen >= max_jump_height:
			# Stop any further upward motion
			player_node.velocity.y = 0

	# --- Gravity application ---
	player_node.velocity += player_node.get_gravity() * delta

	# --- Move & slide ---
	player_node.move_and_slide()

	# --- Landing detection (only once you’ve actually left and come back) ---
	if player_node.is_on_floor() and player_node.velocity.y >= 0:
		player_node.state_machine.enter_state(player_node.idle_state_scene)

func input(player_node, event) -> void:
	# Short hop: cut jump when you release early
	if event.is_action_released("jump") and player_node.velocity.y < 0.0:
		player_node.velocity.y *= jump_cut_multiplier
