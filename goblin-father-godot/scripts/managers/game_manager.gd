# res://scripts/managers/game_manager.gd
extends Node
# (no class_name line!)

# Signal emitted whenever the score changes.
signal score_changed(new_score)

# Signal for requesting the player to bounce (optional).
signal jump_requested()

# Global score (coins collected)
var score: int = 0

func add_point() -> void:
	"""
	Increment the score and notify any listeners.
	"""
	score += 1
	emit_signal("score_changed", score)

func make_player_jump() -> void:
	"""
	Find the Player node in the current scene and call its bounce method.
	Logs an error if the Player cannot be found.
	"""
	var p = get_tree().get_current_scene().get_node("Player")
	if p and p is CharacterBody2D:
		p.landed_on_enemy_slime()
	else:
		push_error("GameManager: could not find Player to make it jump")

func _ready() -> void:
	# Nothing to initialize here yet.
	pass
