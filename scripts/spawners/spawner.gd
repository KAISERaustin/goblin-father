# res://scripts/spawners/spawner.gd
extends Node
class_name Spawner

@export_group("Spawner Settings")
@export var player_path:   NodePath = NodePath("../Player")
@export var pool_name:     String   = ""
@export var has_collection: bool     = false
@export var perma_kill:     bool     = false

@onready var player = get_node(player_path)

func _ready() -> void:
	# (optional) any shared setup
	pass
