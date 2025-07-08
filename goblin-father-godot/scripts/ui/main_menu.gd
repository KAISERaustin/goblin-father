# res://scripts/ui/main_menu.gd
extends Control

@export var start_button_path:   NodePath = NodePath("StartButton")
@export var options_button_path: NodePath = NodePath("OptionsButton")
@export var exit_button_path:    NodePath = NodePath("ExitButton")
@export var click_sound_path:    NodePath = NodePath("AudioStreamPlayer2D")
@export var background_path:     NodePath = NodePath("BackgroundImage")
@export var animation_player_path: NodePath = NodePath("AnimationPlayer")

@onready var animation_player: AnimationPlayer = get_node(animation_player_path)
@onready var _start_button   := get_node(start_button_path)   as Button
@onready var _options_button := get_node(options_button_path) as Button
@onready var _exit_button    := get_node(exit_button_path)    as Button
@onready var _click_sound    := get_node(click_sound_path)    as AudioStreamPlayer2D
@onready var _background     := get_node(background_path)     as Control

func _ready() -> void:
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_start_button.pressed.connect(_on_start_button_pressed)
	_options_button.pressed.connect(_on_options_button_pressed)
	_exit_button.pressed.connect(_on_exit_button_pressed)

func _on_start_button_pressed() -> void:
	print("▶ Start pressed")
	animation_player.play("enable_mobile_controls")
	_click_sound.play()
	SceneManager.change_scene("res://scenes/game.tscn")


func _on_options_button_pressed() -> void:
	print("▶ Options pressed")
	_click_sound.play()
	SceneManager.change_scene("res://scenes/option_menu.tscn")

func _on_exit_button_pressed() -> void:
	print("▶ Exit pressed")
	_click_sound.play()
	get_tree().quit()
