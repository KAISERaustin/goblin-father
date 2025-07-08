# res://scripts/managers/AudioManager.gd
extends Node

@export var default_music: AudioStream

@onready var _music_player := AudioStreamPlayer.new()

func _ready() -> void:
	add_child(_music_player)
	_music_player.bus = "Music"
	_music_player.autoplay = false
	_music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	SceneManager.connect("scene_changing", Callable(self, "_on_scene_changing"))
	SceneManager.connect("scene_loaded",   Callable(self, "_on_scene_loaded"))
	GameManager.connect("player_died",     Callable(self, "_on_player_died"))
	_on_scene_loaded()

func _on_scene_changing() -> void:
	# continue playing across scenes
	pass

func _on_scene_loaded() -> void:
	if default_music:
		_music_player.stream = default_music
		_music_player.play()

func _on_player_died() -> void:
	_music_player.stop()

func play_sfx(stream: AudioStream) -> void:
	var sfx := AudioStreamPlayer2D.new()
	add_child(sfx)
	sfx.stream = stream
	sfx.play()
	sfx.call_deferred("queue_free")
