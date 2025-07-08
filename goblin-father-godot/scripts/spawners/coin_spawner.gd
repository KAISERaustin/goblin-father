# res://scripts/spawners/coin_spawner.gd
extends Node

# — NodePath to your Player instance (adjust as needed) —
@export var player_path: NodePath = NodePath("../Player")
@onready var player: CharacterBody2D = get_node(player_path)

# — World-space positions where coins can spawn —
@export var spawn_positions: Array[Vector2] = []

# — How close the player must be to a spawn point to spawn a coin —
const SPAWN_DISTANCE: float = 200.0
# — Additional buffer distance before despawning —
const DESPAWN_BUFFER: float = 50.0

# Internal tracking for each spawn point:
# { position: Vector2, spawned: bool, collected: bool, instance: Node, callback: Callable }
var _spawn_data: Array = []

func _ready() -> void:
	# Initialize spawn data from the exported positions
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
	var ppos: Vector2 = player.global_position
	for i in _spawn_data.size():
		var data = _spawn_data[i]
		# Skip if already collected
		if data.collected:
			continue
		# Despawn if spawned but player moved too far
		if data.spawned and data.instance:
			var dist = ppos.distance_to(data.position)
			if dist > SPAWN_DISTANCE + DESPAWN_BUFFER:
				# Disconnect the body_entered signal
				if data.callback:
					data.instance.body_entered.disconnect(data.callback)
				PoolManager.free_instance("Coin", data.instance)
				data.spawned = false
				data.instance = null
				data.callback = null
				continue
		# Spawn when in range
		if not data.spawned and ppos.distance_to(data.position) <= SPAWN_DISTANCE:
			var coin = PoolManager.get_instance_and_add("Coin", get_tree().get_current_scene())
			coin.show()
			var sprite = coin.get_node("AnimatedSprite2D") as AnimatedSprite2D
			sprite.play("default")
			coin.global_position = data.position
			data.instance = coin
			data.spawned = true
			# Prepare and store a bound Callable for pickup handling
			var cb: Callable = Callable(self, "_on_coin_body_entered").bind(i)
			data.callback = cb
			coin.body_entered.connect(cb)

func _on_coin_body_entered(body: Node, index: int) -> void:
	# Only mark collected if it's the player
	if body.is_in_group("player"):
		var data = _spawn_data[index]
		# Disconnect to avoid future callbacks on this instance
		if data.callback and data.instance:
			data.instance.body_entered.disconnect(data.callback)
		data.collected = true
		data.spawned = false
		data.instance = null
		data.callback = null
