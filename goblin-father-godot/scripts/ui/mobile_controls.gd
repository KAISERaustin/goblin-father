extends CanvasLayer

@export var btn_left_path:  NodePath = NodePath("BtnLeft")
@export var btn_right_path: NodePath = NodePath("BtnRight")
@export var btn_jump_path:  NodePath = NodePath("BtnJump")

@onready var btn_left:  TouchScreenButton = get_node(btn_left_path)
@onready var btn_right: TouchScreenButton = get_node(btn_right_path)
@onready var btn_jump:  TouchScreenButton = get_node(btn_jump_path)

func _on_mobile_controls_toggled(enabled: bool) -> void:
	print_debug("MobileControlsUI: got toggle → ", enabled)
	visible = enabled
