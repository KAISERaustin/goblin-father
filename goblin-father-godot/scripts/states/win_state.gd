extends PlayerState

@export var win_timer_path:          NodePath            = NodePath("WinTimer")
@export var victory_fanfare_player:  NodePath            = NodePath("WinSound")

@onready var win_timer:              Timer                 = get_node(win_timer_path)
@onready var win_music:              AudioStreamPlayer2D   = get_node(victory_fanfare_player)

var _player

func _ready() -> void:
	win_timer.one_shot = true
	win_timer.timeout.connect(_on_win_timer_timeout)

func enter(player_node):
	_player = player_node
	Engine.time_scale = 0.5
	if win_music:
		win_music.play()
	win_timer.one_shot = true
	win_timer.start()

func exit(_player_node):
	TimeManager.reset()

func physics_process(_player_node, _delta):
	pass

func input(_player_node, _event):
	pass

func _on_win_timer_timeout() -> void:
	SceneManager.change_scene("res://scenes/main_menu.tscn")
	_player.state_machine.change_state(_player.idle_state)
