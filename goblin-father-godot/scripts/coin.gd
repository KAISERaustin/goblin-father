extends Area2D

@onready var game_manager: Node = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var lblscore: Label = get_node("/root/Game/GUI/lblscore")

func _on_body_entered(_body: Node2D) -> void:
	game_manager.add_point()
	print(game_manager.score)
	lblscore.text = "COINS: " + str(game_manager.score)
	animation_player.play("pickup")
 
