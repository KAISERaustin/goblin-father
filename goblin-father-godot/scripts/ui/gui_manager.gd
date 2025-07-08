# res://scripts/gui_manager.gd
extends Node
class_name GuiManager

@export var interface_path: NodePath = NodePath("..")
@onready var interface: Node = get_node(interface_path)

var is_mobile_controls_enabled: bool = false

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
