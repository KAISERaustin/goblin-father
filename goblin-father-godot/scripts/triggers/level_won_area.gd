# res://scripts/triggers/level_won_area.gd
extends Area2D
class_name LevelWonArea

# — NodePath injection for child nodes —
@export var won_timer_path: NodePath
@export var audio_player_path: NodePath

@onready var won_timer: Timer                       = get_node(won_timer_path)
@onready var audio_player: AudioStreamPlayer2D      = get_node(audio_player_path)
@onready var game_manager: Node                     = GameManager

func _ready() -> void:
	Engine.time_scale = 1.0
	# Connect signals in code for clarity
	connect("area_entered", Callable(self, "_on_area_entered"))
	won_timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	# Restore normal time and go back to main menu
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_head"):
		# Pause music via GameManager and play win SFX
		game_manager.pause_music()
		audio_player.play()
		Engine.time_scale = 0.5
		won_timer.start()
