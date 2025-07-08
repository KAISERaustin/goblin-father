# res://scripts/managers/ui_manager.gd
extends Node
class_name UIManager

@export var score_label_path: NodePath = NodePath("GUI/lblscore")

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)

func _on_score_changed(new_score: int) -> void:
	var scene = get_tree().get_current_scene()
	if scene and scene.has_node(score_label_path):
		var lbl = scene.get_node(score_label_path) as Label
		lbl.text = "COINS: %d" % new_score
