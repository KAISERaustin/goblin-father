# res://scripts/managers/coin.gd
extends Area2D

@export var animation_player_path: NodePath = NodePath("AnimationPlayer")
@onready var animation_player: AnimationPlayer = get_node(animation_player_path)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		GameManager.add_point()
		animation_player.play("pickup")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "pickup":
		PoolManager.free_instance("Coin", self)
