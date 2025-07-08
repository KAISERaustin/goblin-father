# res://scripts/managers/scene_manager.gd
extends Node

signal scene_changing
signal scene_loaded

@export var fade_layer_path: NodePath = "FadeLayer"
@export var fade_rect_path:  NodePath = "FadeLayer/ColorRect"
@export var fade_duration:   float   = 0.5

@onready var _fade_layer := get_node(fade_layer_path) as CanvasLayer
@onready var _fade_rect  := get_node(fade_rect_path)  as ColorRect

var _next_scene: String = ""

func _ready() -> void:
	_fade_layer.visible = false

func change_scene(path: String) -> void:
	_next_scene = path
	emit_signal("scene_changing")
	_fade_layer.visible = true
	_fade_rect.modulate.a = 0.0
	var tw = create_tween().bind_node(self).set_ignore_time_scale(true)
	tw.tween_property(_fade_rect, "modulate:a", 1.0, fade_duration)
	tw.tween_callback(Callable(self, "_on_fade_out_done"))

func _on_fade_out_done() -> void:
	if get_tree().change_scene_to_file(_next_scene) != OK:
		push_error("Couldn’t load: " + _next_scene)
		return
	_fade_rect.modulate.a = 1.0
	var tw = create_tween().bind_node(self).set_ignore_time_scale(true)
	tw.tween_property(_fade_rect, "modulate:a", 0.0, fade_duration)
	tw.tween_callback(Callable(self, "_on_fade_in_done"))

func _on_fade_in_done() -> void:
	_fade_layer.visible = false
	emit_signal("scene_loaded")

func reload_current() -> void:
	var cur = get_tree().current_scene.scene_file_path
	Engine.time_scale = 1
	change_scene(cur)

# new: called by the Slime when its death timer runs out
func return_slime_to_pool(slime: CharacterBody2D) -> void:
	# disable it so it stops processing / colliding immediately
	slime.is_dead = false
	slime.visible = false
	slime.set_physics_process(false)
	slime.set_process(false)
	# hand it back to your PoolManager
	PoolManager.free_instance("Slime", slime)
