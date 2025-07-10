# res://scripts/managers/TimeManager.gd
extends Node

@export var default_scale: float = 1.0

func set_scale(scale: float) -> void:
	Engine.time_scale = scale

func reset() -> void:
	Engine.time_scale = default_scale

func slow_motion(factor: float = 0.5) -> void:
	Engine.time_scale = factor

func restore() -> void:
	Engine.time_scale = default_scale
