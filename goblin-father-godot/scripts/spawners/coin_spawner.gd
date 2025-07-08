# res://scripts/spawners/coin_spawner.gd
extends Spawner

@export var spawn_positions: Array[Vector2] = []

const SPAWN_DISTANCE = 200.0
const DESPAWN_BUFFER  = 50.0

var _spawn_data: Array = []

func _ready() -> void:
	pool_name     = "Coin"
	has_collection = true
	perma_kill     = false

	for pos in spawn_positions:
		_spawn_data.append({
			"position": pos,
			"spawned": false,
			"collected": false,
			"instance": null,
			"callback": null
		})
	set_process(true)

func _process(_delta: float) -> void:
	var ppos = get_node(player_path).global_position
	for i in _spawn_data.size():
		var data = _spawn_data[i]
		if data.collected:
			continue

		if data.spawned and data.instance:
			var dist = ppos.distance_to(data.position)
			if dist > SPAWN_DISTANCE + DESPAWN_BUFFER:
				if data.callback:
					data.instance.body_entered.disconnect(data.callback)
				PoolManager.free_instance(pool_name, data.instance)
				data.spawned = false
				data.instance = null
				data.callback = null
				continue

		if not data.spawned and ppos.distance_to(data.position) <= SPAWN_DISTANCE:
			var coin = PoolManager.get_instance_and_add(pool_name, get_tree().current_scene)
			coin.show()
			coin.global_position = data.position
			data.instance = coin
			data.spawned  = true
			var cb = Callable(self, "_on_coin_body_entered").bind(i)
			data.callback = cb
			coin.body_entered.connect(cb)

func _on_coin_body_entered(body: Node, index: int) -> void:
	if body.is_in_group("player"):
		var data = _spawn_data[index]
		if data.callback and data.instance:
			data.instance.body_entered.disconnect(data.callback)
		data.collected  = true
		data.spawned    = false
		data.instance   = null
		data.callback   = null
