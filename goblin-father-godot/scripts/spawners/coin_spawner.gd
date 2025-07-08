# res://scripts/spawners/coin_spawner.gd
extends Node

@export var player_path: NodePath = NodePath("../Player")
@onready var player: CharacterBody2D = get_node(player_path)

@export var spawn_positions: Array[Vector2] = []

const SPAWN_DISTANCE: float = 200.0
const DESPAWN_BUFFER: float = 50.0

var _spawn_data: Array = []

func _ready() -> void:
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
		if data.collected:
			continue
		if data.spawned and data.instance:
			var dist = ppos.distance_to(data.position)
			if dist > SPAWN_DISTANCE + DESPAWN_BUFFER:
				if data.callback:
					data.instance.body_entered.disconnect(data.callback)
				PoolManager.free_instance("Coin", data.instance)
				data.spawned = false
				data.instance = null
				data.callback = null
				continue
		if not data.spawned and ppos.distance_to(data.position) <= SPAWN_DISTANCE:
			var coin = PoolManager.get_instance_and_add("Coin", get_tree().get_current_scene())
			coin.show()
			var sprite = coin.get_node("AnimatedSprite2D") as AnimatedSprite2D
			sprite.play("default")
			coin.global_position = data.position
			data.instance = coin
			data.spawned = true
			var cb: Callable = Callable(self, "_on_coin_body_entered").bind(i)
			data.callback = cb
			coin.body_entered.connect(cb)

func _on_coin_body_entered(body: Node, index: int) -> void:
	if body.is_in_group("player"):
		var data = _spawn_data[index]
		if data.callback and data.instance:
			data.instance.body_entered.disconnect(data.callback)
		data.collected = true
		data.spawned = false
		data.instance = null
		data.callback = null
