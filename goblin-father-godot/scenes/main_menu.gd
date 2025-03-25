extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_start_pressed() -> void:
	animation_player.play("button_press")
	
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_options_pressed() -> void:
	print("Options")


func _on_exit_pressed() -> void:
	animation_player.play("button_press")
	
	await animation_player.animation_finished

	print("Exit")
	get_tree().quit()
