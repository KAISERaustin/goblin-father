# res://scripts/managers/level_won_area.gd
extends Area2D

@onready var won_timer:              Timer               = $WON_TIMER
@onready var victory_fanfare_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	TimeManager.reset()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_head"):
		AudioManager.stop_music()
		victory_fanfare_player.play()
		TimeManager.slow_motion(0.5)
		won_timer.start()

func _on_timer_timeout() -> void:
	TimeManager.reset()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
