# res://scripts/managers/ui_manager.gd
extends Node
# (autoload this script as “UIManager” in Project Settings → AutoLoad)

func _ready() -> void:
	# Bind to the GameManager.score_changed signal using the new API
	GameManager.score_changed.connect(self._on_score_changed)
	# —or— 
	# GameManager.connect("score_changed", Callable(self, "_on_score_changed"))

func _on_score_changed(new_score: int) -> void:
	# Grab the current scene’s GUI/lblscore label and update it.
	var scene = get_tree().get_current_scene()
	if not scene:
		return
	if scene.has_node("GUI/lblscore"):
		var lbl = scene.get_node("GUI/lblscore") as Label
		lbl.text = "COINS: " + str(new_score)
