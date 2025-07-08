# res://scripts/triggers/killzone.gd
extends Area2D
class_name KillZone

@export var timer_path: NodePath
@onready var timer: Timer = get_node(timer_path)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	timer.timeout.connect(_on_timer_timeout)

func _on_body_entered(body: Node) -> void:
	Engine.time_scale = 0.5
	if body.has_node("CollisionShape2D"):
		body.get_node("CollisionShape2D").queue_free()
	timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	SceneManager.reload_current()
