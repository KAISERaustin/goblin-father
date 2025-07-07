extends Area2D
class_name pipe_point_a

@export var target_point: pipe_point_b

func _on_area_entered(area: Node) -> void:
	await get_tree().create_timer(0.75).timeout
	if target_point:
		var candidate: Node = area
		while candidate and not candidate.is_in_group("player"):
			candidate = candidate.get_parent()
		if candidate:
			if candidate is Node2D:
				(candidate as Node2D).global_position = target_point.global_position
			else:
				print("Candidate is not a Node2D!")
		else:
			print("Player root not found")
