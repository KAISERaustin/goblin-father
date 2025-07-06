extends Area2D

@onready var won_timer: Timer = $"WON TIMER"
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var game_manager: Node = %GameManager

func _ready() -> void:
	Engine.time_scale = 1.0

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_head"):
		game_manager.pause_music()
		audio_stream_player_2d.play()
		Engine.time_scale = 0.5
		won_timer.start()
