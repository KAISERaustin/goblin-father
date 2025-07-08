# res://scripts/spawners/slime_spawner.gd
extends Spawner

@export var spawn_positions: Array[Vector2] = []

const SPAWN_DISTANCE = 200.0
const DESPAWN_BUFFER  = 50.0

var _spawn_data: Array = []

func _ready() -> void:
	pool_name     = "Slime"
	has_collection = false
	perma_kill     = true

	for pos in spawn_positions:
		_spawn_data.append({
			"position": pos,
			"spawned": false,
			"instance": null,
			"killed": false
		})
	set_process(true)

func _process(_delta: float) -> void:
	var ppos = get_node(player_path).global_position
	for i in _spawn_data.size():
		var data = _spawn_data[i]
		if data.killed:
			continue
		if data.spawned and data.instance:
			var dist = ppos.distance_to(data.position)
			if dist > SPAWN_DISTANCE + DESPAWN_BUFFER:
				data.position = data.instance.global_position
				PoolManager.free_instance(pool_name, data.instance)
				data.spawned = false
				data.instance = null
				continue
			if not data.instance.get_parent():
				data.killed  = true
				data.position = data.instance.global_position
				data.spawned  = false
				data.instance = null
				continue
		if not data.spawned and not data.killed and ppos.distance_to(data.position) <= SPAWN_DISTANCE:
			var slime = PoolManager.get_instance_and_add(pool_name, get_tree().current_scene)
			slime.global_position = data.position
			data.instance = slime
			data.spawned  = true
