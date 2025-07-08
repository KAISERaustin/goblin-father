# res://scripts/managers/game_manager.gd
extends Node

@export var player_path: NodePath = NodePath("Player")
signal score_changed(new_score)
signal player_died

var score: int = 0

func _ready() -> void:
	PoolManager.reset_all_pools()
	if not PoolManager.has_pool("Coin"):
		PoolManager.register_pool("Coin", preload("res://scenes/coin.tscn"), 20)
	if not PoolManager.has_pool("Slime"):
		PoolManager.register_pool("Slime", preload("res://scenes/slime.tscn"), 10)

func add_point() -> void:
	score += 1
	emit_signal("score_changed", score)

func make_player_jump() -> void:
	var scene = get_tree().current_scene
	if scene and scene.has_node(player_path):
		var p = scene.get_node(player_path)
		if p is CharacterBody2D:
			p.landed_on_enemy_slime()
		else:
			push_error("GameManager: node at '%s' is not a CharacterBody2D" % player_path)
	else:
		push_error("GameManager: could not find Player at '%s' in current scene" % player_path)

func handle_player_death() -> void:
	emit_signal("player_died")
