# res://scripts/ui/option_menu.gd
extends Control
class_name OptionMenu

# — NodePath injection for the AnimationPlayer —
@export var animation_player_path: NodePath = NodePath("AnimationPlayer")
@onready var animation_player: AnimationPlayer = get_node(animation_player_path)

func _ready() -> void:
	# (Optional) any setup logic goes here
	pass

func _on_enable_mobile_controls_pressed() -> void:
	animation_player.play("enable_mobile_controls")
	await animation_player.animation_finished

func _on_main_menu_pressed() -> void:
	animation_player.play("enable_mobile_controls")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
