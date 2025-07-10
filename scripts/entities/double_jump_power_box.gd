extends Area2D

@export var animation_player_path : NodePath            = NodePath("PowerBoxAnimationPlayer")
@export var audio_player_path     : NodePath            = NodePath("pickup sound")

@onready var animation_player     : AnimationPlayer     = get_node(animation_player_path)
@onready var audio_player         : AudioStreamPlayer2D = get_node(audio_player_path)

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "pickup":
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		GameManager.enable_double_jump()
		audio_player.play()
		animation_player.play("pickup")
