extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var game_manager: Node = %GameManager
@onready var gui: CanvasLayer = $"../../GUI"

func _on_body_entered(_body: Node2D) -> void:
	game_manager.add_point()
	var lblscore = gui.get_node("lblscore")
	lblscore.text = "COINS: " + str(game_manager.score)
	animation_player.play("pickup")
 
