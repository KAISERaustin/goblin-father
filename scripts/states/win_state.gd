# res://scripts/states/win_state.gd
extends PlayerState

@export var win_timer_path: NodePath          = NodePath("WinTimer")
@export var victory_fanfare_player: NodePath = NodePath("WinSound")

@onready var win_timer: Timer               = get_node(win_timer_path)
@onready var win_music: AudioStreamPlayer2D = get_node(victory_fanfare_player)

var _player

func _ready() -> void:
	win_timer.one_shot            = true
	win_timer.ignore_time_scale   = true
	win_timer.process_mode        = Node.PROCESS_MODE_ALWAYS
	win_timer.timeout.connect(_on_win_timer_timeout)

func enter(player_node) -> void:
	_player = player_node
	TimeManager.slow_motion()
	if win_music:
		win_music.play()
	_player.set_physics_process(false)
	_player.set_process_input(false)
	_player.set_process_unhandled_input(false)
	_player.velocity = Vector2.ZERO
	win_timer.start()  # now counts real seconds, not scaled by Engine.time_scale

func exit(_player_node) -> void:
	TimeManager.reset()
	_player_node.set_physics_process(true)
	_player_node.set_process_input(true)
	_player_node.set_process_unhandled_input(true)

func physics_process(_player_node, _delta) -> void:
	pass

func input(_player_node, _event) -> void:
	pass

func _on_win_timer_timeout() -> void:
	SceneManager.change_scene("res://scenes/main_menu.tscn")
