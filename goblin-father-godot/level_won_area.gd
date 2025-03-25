extends Area2D

@onready var timer: Timer = $Timer

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("YOU WON!")
		Engine .time_scale = 0.5
		timer.start()
