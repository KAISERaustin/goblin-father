# res://scripts/managers/level_manager.gd
extends Node

@export_group("NodePaths")
@export var interface_path: NodePath
@export var game_path: NodePath

@onready var interface_node: Node = get_node(interface_path)
@onready var game_node: Node2D = get_node(game_path)

func _ready() -> void:
	game_node.visible = false

func set_mobile_controls_to_on(_on: bool) -> void:
	pass
