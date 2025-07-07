# res://scripts/ui/main_menu.gd
extends Control
class_name MainMenu

# — NodePath injection for child nodes —
@export var animation_player_path: NodePath = NodePath("AnimationPlayer")
@export var music_path: NodePath            = NodePath("Music")

@onready var animation_player: AnimationPlayer   = get_node(animation_player_path)
@onready var music: AudioStreamPlayer2D         = get_node(music_path)

func _ready() -> void:
	# Start background music with default settings
	music.playing     = true
	music.attenuation = 0.0
	music.max_distance = 10000.0

func _on_start_pressed() -> void:
	animation_player.play("start_button_press")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_options_pressed() -> void:
	# TODO: wire up an options menu if needed
	print("Options")

func _on_exit_pressed() -> void:
	animation_player.play("exit_button_pressed")
	await animation_player.animation_finished
	get_tree().quit()
