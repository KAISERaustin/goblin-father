# res://scripts/gui/main_menu.gd
extends Control

@export var start_button_path: NodePath = NodePath("StartButton")
@export var options_button_path: NodePath = NodePath("OptionsButton")
@export var exit_button_path: NodePath = NodePath("ExitButton")
@export var click_sound_path: NodePath = NodePath("AudioStreamPlayer2D")
@export var background_path: NodePath = NodePath("BackgroundImage")

@onready var _start_button := get_node(start_button_path) as Button
@onready var _options_button := get_node(options_button_path) as Button
@onready var _exit_button := get_node(exit_button_path) as Button
@onready var _click_sound := get_node(click_sound_path) as AudioStreamPlayer2D
@onready var _background := get_node(background_path) as Control

func _ready() -> void:
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	assert(_start_button, "Start button not found at " + str(start_button_path))
	assert(_options_button, "Options button not found at " + str(options_button_path))
	assert(_exit_button, "Exit button not found at " + str(exit_button_path))
	assert(_click_sound, "Click sound player not at " + str(click_sound_path))
	_start_button.pressed.connect(_on_start_button_pressed)
	_options_button.pressed.connect(_on_options_button_pressed)
	_exit_button.pressed.connect(_on_exit_button_pressed)

func _on_start_button_pressed() -> void:
	print("▶ Start pressed")
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

func _on_start_pressed() -> void:
	print("▶ Start pressed")
