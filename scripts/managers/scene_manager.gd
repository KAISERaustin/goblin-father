# res://scripts/managers/scene_manager.gd
extends Node  # Base class for non-visual nodes

signal scene_changing  # Emitted when a scene transition begins
signal scene_loaded    # Emitted after a new scene has finished loading

@export var fade_layer_path: NodePath = "FadeLayer"         # Path to the CanvasLayer used for fade effect
@export var fade_rect_path: NodePath  = "FadeLayer/ColorRect"  # Path to the ColorRect that actually fades
@export var fade_duration:   float   = 0.5                # Duration of fade in/out animations in seconds

@onready var _fade_layer := get_node(fade_layer_path) as CanvasLayer  # Cached reference to fade CanvasLayer
@onready var _fade_rect  := get_node(fade_rect_path)  as ColorRect    # Cached reference to fade ColorRect

var _next_scene: String = ""  # Stores the path of the next scene to load

func _ready() -> void:
	_fade_layer.visible = false  # Hide the fade layer when starting

func change_scene(path: String) -> void:
	_next_scene = path
	emit_signal("scene_changing")           # Notify listeners that a scene change is starting
	_fade_layer.visible = true              # Show the fade layer on top of everything
	_fade_rect.modulate.a = 0.0             # Start fully transparent
	var tw = create_tween().bind_node(self).set_ignore_time_scale(true)
	tw.tween_property(_fade_rect, "modulate:a", 1.0, fade_duration)      # Fade to opaque
	tw.tween_callback(Callable(self, "_on_fade_out_done"))               # Then call fade-out handler

func _on_fade_out_done() -> void:
	if get_tree().change_scene_to_file(_next_scene) != OK:  # Attempt to load the new scene
		push_error("Couldn’t load: " + _next_scene)         # Log error if load fails
		return
	_fade_rect.modulate.a = 1.0  # Ensure fade rect is fully opaque after load
	var tw = create_tween().bind_node(self).set_ignore_time_scale(true)
	tw.tween_property(_fade_rect, "modulate:a", 0.0, fade_duration)      # Fade back to transparent
	tw.tween_callback(Callable(self, "_on_fade_in_done"))                # Then call fade-in handler

func _on_fade_in_done() -> void:
	_fade_layer.visible = false    # Hide the fade layer entirely
	emit_signal("scene_loaded")    # Notify listeners that the new scene is ready

func reload_current() -> void:
	TimeManager.reset()  # Reset any altered time scale
	var cur = get_tree().current_scene.scene_file_path  # Get path of current scene
	change_scene(cur)     # Trigger a reload of the same scene

func return_slime_to_pool(slime: CharacterBody2D) -> void:
	slime.slime_is_dead       = false               # Clear death flag
	slime.visible             = false               # Hide until next spawn
	slime.velocity            = Vector2.ZERO        # Stop all movement
	slime.direction           = 1                   # Reset patrol direction
	slime.head_hit_check.set_deferred("monitoring", true)
	slime.body_check.set_deferred("monitoring", true)
	slime.ground_check.set_deferred("disabled", false)
	slime.ray_cast_left.set_deferred("enabled", true)
	slime.ray_cast_right.set_deferred("enabled", true)
	slime.death_timer.stop()                       # Cancel any running timer
	slime.slime_kill.stop()                        # Stop any death sound
	slime.animated_sprite.flip_h = false           # Reset sprite orientation
	slime.animated_sprite.play("default")
	slime.set_physics_process(false)               # Disable until respawned
	slime.set_process(false)
	PoolManager.free_instance("Slime", slime)      # Finally, return to the pool
