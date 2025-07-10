# res://scripts/spawners/slime_spawner.gd
extends Spawner

@export var spawn_positions: Array[Vector2] = []

const SPAWN_DISTANCE = 200.0
const DESPAWN_BUFFER = 50.0

var _spawn_data: Array = []

func _ready() -> void:
	pool_name  = "Slime"
	perma_kill = true
	for pos in spawn_positions:
		_spawn_data.append({
			"position": pos,
			"spawned":  false,
			"instance": null,
			"callback": null,
			"killed":   false
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
				data.spawned  = false
				data.instance = null
				data.callback = null
			continue

		if not data.spawned and ppos.distance_to(data.position) <= SPAWN_DISTANCE:
			var slime = PoolManager.get_instance_and_add(pool_name, get_tree().current_scene)
			slime.visible              = true
			slime.set_physics_process(true)
			slime.set_process(true)
			slime.animated_sprite.flip_h = false
			slime.animated_sprite.play("default")
			slime.global_position      = data.position
			data.instance              = slime
			data.spawned               = true
			var cb = Callable(self, "_on_slime_killed").bind(i)
			# disconnect if that exact Callable is already hooked
			if slime.head_hit_check.is_connected("area_entered", cb):
				slime.head_hit_check.disconnect("area_entered", cb)
			# (re)connect it
			slime.head_hit_check.area_entered.connect(cb)
			data.callback = cb

func _on_slime_killed(_area: Area2D, index: int) -> void:
	var data = _spawn_data[index]
	data.killed = true
	if data.instance and data.callback:
		data.instance.head_hit_check.area_entered.disconnect(data.callback)
		data.callback = null
