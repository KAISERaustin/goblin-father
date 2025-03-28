extends Node

@onready var music: AudioStreamPlayer2D = $Music
@onready var player: CharacterBody2D = $"../Player"


var score = 0

func add_point():
	score += 1

func make_player_jump() -> void:
	player.landed_on_enemy_slime()

func play_music() -> void:
	music.playing = true

func pause_music() -> void:
	music.playing = false

func _ready() -> void:
	music.playing = true
	music.attenuation = 0.0
	music.max_distance = 10000.0
