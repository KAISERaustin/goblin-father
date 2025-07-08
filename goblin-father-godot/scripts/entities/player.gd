# res://scripts/entities/player.gd
extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -380.0
const ACCELERATION = 800.0
const DECELERATION = 600.0

@export var animated_sprite_path:   NodePath      = NodePath("AnimatedSprite2D")
@export var body_check_path:        NodePath      = NodePath("Body Check")

@export() var idle_state_scene: PackedScene
@export() var run_state_scene:  PackedScene
@export() var jump_state_scene: PackedScene
@export() var death_state: PackedScene
@export() var win_state: PackedScene

@onready var animated_sprite: AnimatedSprite2D = get_node(animated_sprite_path)
@onready var body_check:      Area2D              = get_node(body_check_path)

var state_machine: StateMachine

func _ready() -> void:
	add_to_group("player")
	body_check.body_entered.connect(_on_body_check_body_entered)

	state_machine = StateMachine.new(self, idle_state_scene)
	add_child(state_machine)

func _physics_process(delta: float) -> void:
	state_machine.physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.input(event)

func _on_body_check_body_entered(_body) -> void:
	if _body.is_in_group("enemy_slime"):
		state_machine.enter_state(death_state)

func landed_on_enemy_slime() -> void:
	velocity.y = JUMP_VELOCITY * 0.75
