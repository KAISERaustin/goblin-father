extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_enable_mobile_controls_pressed() -> void:
	animation_player.play("enable_mobile_controls")
	await animation_player.animation_finished

func _on_main_menu_pressed() -> void:
	animation_player.play("enable_mobile_controls")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
