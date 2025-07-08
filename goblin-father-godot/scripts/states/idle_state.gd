# res://scenes/idle_state.gd
extends Node
class_name IdleState

func enter(_player_node) -> void:
	pass

func exit(_player_node) -> void:
	pass

func physics_process(player_node, delta: float) -> void:
	var dir = Input.get_axis("move_left", "move_right")
	var target = 0.0
	var decel_rate = player_node.DECELERATION * delta
	player_node.velocity.x = move_toward(player_node.velocity.x, target, decel_rate)
	
	if not player_node.is_on_floor():
		player_node.velocity += player_node.get_gravity() * delta
	if dir != 0:
		player_node.state_machine.enter_state(player_node.run_state_scene)
	player_node.move_and_slide()

func input(_player_node, _event) -> void:
	if _event.is_action_pressed("jump") and _player_node.is_on_floor():
		_player_node.state_machine.enter_state(_player_node.jump_state_scene)
