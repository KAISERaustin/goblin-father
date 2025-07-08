# res://scripts/spawners/slime_spawner.gd
extends Node

# — NodePath to your Player instance (adjust as needed) —
@export var player_path: NodePath = NodePath("../Player")
@onready var player: CharacterBody2D = get_node(player_path)

# — World-space positions where slimes can spawn —
@export var spawn_positions: Array[Vector2] = []

# — How close the player must be to a spawn point to spawn a slime —
const SPAWN_DISTANCE: float = 200.0
# — Additional buffer distance before despawning —
const DESPAWN_BUFFER: float = 50.0

# Internal tracking for each spawn point:
# {
#   position: Vector2,    # Next spawn position
#   spawned: bool,        # Is a slime currently spawned?
#   instance: Node,       # The active slime instance
#   killed: bool          # Was this spawn permanently killed by the player?
# }
var _spawn_data: Array = []

func _ready() -> void:
	# Initialize spawn data from the exported positions
	for pos in spawn_positions:
		_spawn_data.append({
			"position": pos,
			"spawned": false,
			"instance": null,
			"killed": false
		})
	set_process(true)

func _process(_delta: float) -> void:
	var ppos: Vector2 = player.global_position
	for i in _spawn_data.size():
		var data = _spawn_data[i]

		# Skip this point if the slime here has been killed
		if data.killed:
			continue

		# If already spawned...
		if data.spawned and data.instance:
			var dist = ppos.distance_to(data.position)

			# 1) Out-of-range despawn (only if not yet killed)
			if dist > SPAWN_DISTANCE + DESPAWN_BUFFER:
				data.position = data.instance.global_position
				PoolManager.free_instance("Slime", data.instance)
				data.spawned = false
				data.instance = null
				continue

			# 2) Slime died (returned to pool by its own logic)
			if not data.instance.get_parent():
				# Mark as killed so it won't respawn
				data.killed = true
				# Optionally preserve its last position if you want
				data.position = data.instance.global_position
				data.spawned = false
				data.instance = null
				continue

		# If not spawned, not killed, and within SPAWN_DISTANCE, spawn here
		if not data.spawned and not data.killed and ppos.distance_to(data.position) <= SPAWN_DISTANCE:
			var slime = PoolManager.get_instance_and_add("Slime", get_tree().get_current_scene())
			slime.global_position = data.position
			data.instance = slime
			data.spawned = true
