extends Area2D

# NodePath injection for the AnimationPlayer
@export var animation_player_path: NodePath = NodePath("AnimationPlayer")
@onready var animation_player: AnimationPlayer = get_node(animation_player_path)

func _ready() -> void:
	# Connect the overlap signal
	body_entered.connect(_on_body_entered)
	# When pickup animation finishes, return this coin to the pool
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		# Award point & play pickup animation
		GameManager.add_point()
		animation_player.play("pickup")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "pickup":
		# Return this coin to its pool rather than queue_free()
		PoolManager.free_instance("Coin", self)
