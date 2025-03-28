extends Node

@onready var interface: Node = $"../Interface"
@onready var game: Node2D = $"../Game"

func ready() -> void:
	game.visible = false

func set_mobile_controls_to_on(_is_mobile_controls_enabled: bool) -> void:
	pass
