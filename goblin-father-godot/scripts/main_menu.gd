extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var music: AudioStreamPlayer2D = $Music

func _on_start_pressed() -> void:
	animation_player.play("start_button_press")
	
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_options_pressed() -> void:
	print("Options")


func _on_exit_pressed() -> void:
	animation_player.play("exit_button_pressed")
	await animation_player.animation_finished

	print("Exit")
	get_tree().quit()
	
func _ready() -> void:
	music.playing = true
	music.attenuation = 0.0
	music.max_distance = 10000.0
