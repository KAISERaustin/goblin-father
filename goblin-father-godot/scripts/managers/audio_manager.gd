# res://scripts/managers/audio_manager.gd
extends Node

# Internal players for BGM and one-shot SFX
var _music_player: AudioStreamPlayer2D
var _sfx_player:   AudioStreamPlayer2D

func _ready() -> void:
	# Create and configure the background-music player
	_music_player = AudioStreamPlayer2D.new()
	_music_player.bus = "Music"      # Make sure you have a "Music" bus in Audio → Buses
	add_child(_music_player)
	# Create and configure the SFX player
	_sfx_player = AudioStreamPlayer2D.new()
	_sfx_player.bus = "SFX"          # And a "SFX" bus for sound effects
	add_child(_sfx_player)

func play_music(stream: AudioStream) -> void:
	"""
	Switch to (or start) a new music track.
	Pass in a preloaded AudioStream (OGG, WAV, etc.).
	"""
	_music_player.stream = stream
	_music_player.play()

func pause_music() -> void:
	_music_player.pause()

func resume_music() -> void:
	_music_player.play()

func stop_music() -> void:
	_music_player.stop()

func play_sfx(stream: AudioStream) -> void:
	"""
	Play a one-shot sound effect.
	Reuses the same player each time.
	"""
	_sfx_player.stream = stream
	_sfx_player.play()
