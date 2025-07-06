# res://scripts/entities/coin.gd
extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Connect the Area2D body_entered signal properly:
	# Option A: use the signal’s connect method directly
	body_entered.connect(self._on_body_entered)
	# Option B: use the generic connect() with a Callable
	# connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	# Only react to the player (optional if your level only has player overlaps)
	if body.is_in_group("player"):
		GameManager.add_point()
		animation_player.play("pickup")
