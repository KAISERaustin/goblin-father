extends Node

@onready var music: AudioStreamPlayer2D = $Music

var score = 0

func add_point():
	score += 1

func _ready() -> void:
	music.playing = true
	music.attenuation = 0.0
	music.max_distance = 10000.0
