extends Node

@onready var music: AudioStreamPlayer2D = $Music
@onready var interface: Node = $".."

var is_mobile_controls_enabled = false

func _ready() -> void:
	music.playing = true
	music.attenuation = 0.0
	music.max_distance = 10000.0

func pause_music() -> void:
	music.playing = false

func play_music() -> void:
	if !music.playing:
		music.playing = true

func _process(_delta: float) -> void:
	pass
