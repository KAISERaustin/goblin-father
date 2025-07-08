# res://scenes/death_state.gd
extends PlayerState

@export var death_timer_path: NodePath              = NodePath("DeathTimer")
@export var death_sound_player_path: NodePath       = NodePath("DeathSound")

@onready var death_timer: Timer                     = get_node(death_timer_path)
@onready var death_audio: AudioStreamPlayer2D       = get_node(death_sound_player_path)

var _player

func _ready() -> void:
	death_timer.one_shot = true
	death_timer.timeout.connect(_on_death_timer_timeout)
	death_timer.process_mode = Node.PROCESS_MODE_ALWAYS

func enter(player_node) -> void:
	_player = player_node
	TimeManager.slow_motion(0.0)
	death_audio.play()
	death_timer.start()

func exit(_player_node) -> void:
	TimeManager.reset()

func _on_death_timer_timeout() -> void:
	TimeManager.reset()
	SceneManager.reload_current()
