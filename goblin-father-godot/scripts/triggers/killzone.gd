# res://scripts/triggers/killzone.gd
extends Area2D
class_name KillZone

# — NodePath injection for the Timer node —
@export var timer_path: NodePath
@onready var timer: Timer = get_node(timer_path)

func _ready() -> void:
	# Ensure signals are connected (if not wired in the editor)
	body_entered.connect(_on_body_entered)
	timer.timeout.connect(_on_timer_timeout)

func _on_body_entered(body: Node) -> void:
	# Slow down time and remove the player's CollisionShape2D
	Engine.time_scale = 0.5
	if body.has_node("CollisionShape2D"):
		body.get_node("CollisionShape2D").queue_free()
	timer.start()

func _on_timer_timeout() -> void:
	# Restore time and reload the current scene
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
