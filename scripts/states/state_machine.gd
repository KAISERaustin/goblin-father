# res://scripts/states/state_machine.gd
extends Node
class_name StateMachine

var _player_node: Node
var _current_state_node: Node = null

func _init(player_node: Node, initial_state_scene: PackedScene) -> void:
	_player_node = player_node
	if initial_state_scene:
		enter_state(initial_state_scene)

func enter_state(state_scene: PackedScene) -> void:
	if _current_state_node:
		_current_state_node.exit(_player_node)
		_current_state_node.queue_free()
	_current_state_node = state_scene.instantiate()
	# ← enable input on the state node
	_current_state_node.set_process_input(true)
	_player_node.add_child(_current_state_node)
	_current_state_node.enter(_player_node)
	#print("StateMachine → entered ", _current_state_node.name)


func physics_process(delta: float) -> void:
	if _current_state_node:
		_current_state_node.physics_process(_player_node, delta)

func input(event: InputEvent) -> void:
	if not _current_state_node:
		return
	if event is InputEventAction:
		print("StateMachine: input(", event.action, ") forwarded to ", _current_state_node)
	_current_state_node.input(_player_node, event)
