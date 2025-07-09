extends Node
class_name JumpState

@export var jump_noise_path     : NodePath = NodePath("JumpNoise")
@export var jump_cut_multiplier : float    = 0.5
@export var max_jump_height     : float    = 240.0  # Max rise (pixels)

@onready var jump_noise         : AudioStreamPlayer2D = get_node(jump_noise_path)

var _start_y : float

func enter(player_node) -> void:
	# Record start height and trigger the jump  
	_start_y = player_node.global_position.y
	player_node.perform_jump()
	jump_noise.play()

func physics_process(player_node, delta: float) -> void:
	# 1) Horizontal air control (optional)
	var dir = Input.get_axis("move_left", "move_right")
	if dir != 0:
		var target = dir * player_node.SPEED
		var accel = player_node.ACCELERATION * delta
		player_node.velocity.x = move_toward(player_node.velocity.x, target, accel)
		player_node.animated_sprite.flip_h = dir < 0

	# 2) Clamp maximum jump height
	if player_node.velocity.y < 0:
		var risen = _start_y - player_node.global_position.y
		if risen >= max_jump_height:
			player_node.velocity.y = 0

	# 3) Apply gravity & move
	player_node.velocity += player_node.get_gravity() * delta
	player_node.move_and_slide()

	# 4) Landing detection: reset and go to Idle
	if player_node.is_on_floor() and player_node.velocity.y >= 0:
		player_node.reset_jumps()
		player_node.state_machine.enter_state(player_node.idle_state_scene)

func input(player_node, event) -> void:
	# a) Mid-air jump
	if event.is_action_pressed("jump") and player_node.jumps_remaining > 0:
		player_node.perform_jump()
		jump_noise.play()
		return

	# b) Short-hop cut
	if event.is_action_released("jump") and player_node.velocity.y < 0:
		player_node.velocity.y *= jump_cut_multiplier

func exit(_player_node) -> void:
	# Nothing special on exit
	pass
