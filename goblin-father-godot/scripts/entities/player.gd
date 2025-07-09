extends CharacterBody2D

const SPEED         : float = 150.0
const JUMP_VELOCITY : float = -380.0
const ACCELERATION  : float = 800.0
const DECELERATION  : float = 600.0

@export var animated_sprite_path : NodePath   = NodePath("AnimatedSprite2D")
@export var body_check_path      : NodePath   = NodePath("Body Check")

@export var idle_state_scene     : PackedScene
@export var run_state_scene      : PackedScene
@export var jump_state_scene     : PackedScene
@export var death_state          : PackedScene
@export var win_state            : PackedScene

# — Double‐jump configuration — 
@export var base_jumps           : int        = 1    # how many jumps by default
@export var double_jump_enabled  : bool       = false
var jumps_remaining              : int

# — Dash configuration — 
@export var dash_active          : bool       = false
@export var dash_speed           : float      = 600.0
@export var dash_duration        : float      = 0.1    # seconds
@export var double_tap_time      : int        = 300    # milliseconds

var is_dashing                   : bool       = false
var last_left_tap                : int        = 0
var last_right_tap               : int        = 0

@onready var animated_sprite     : AnimatedSprite2D = get_node(animated_sprite_path)
@onready var body_check          : Area2D           = get_node(body_check_path)

var state_machine : StateMachine

func _ready() -> void:
	add_to_group("player")
	body_check.body_entered.connect(_on_body_check_body_entered)
	state_machine = StateMachine.new(self, idle_state_scene)
	add_child(state_machine)
	reset_jumps()

func _physics_process(delta: float) -> void:
	if is_dashing:
		# Maintain dash velocity (still apply gravity)
		velocity.y += get_gravity().y * delta
		move_and_slide()
		return
	state_machine.physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	# Double-tap detection using Time.get_ticks_msec()
	if event.is_action_pressed("move_left"):
		_check_double_tap(-1)
	elif event.is_action_pressed("move_right"):
		_check_double_tap(1)
	state_machine.input(event)

func _on_body_check_body_entered(_body) -> void:
	if _body.is_in_group("enemy_slime"):
		state_machine.enter_state(death_state)

func landed_on_enemy_slime() -> void:
	velocity.y = JUMP_VELOCITY * 0.75

# — Jump management helpers — 
func reset_jumps() -> void:
	var max_jumps = base_jumps + (1 if double_jump_enabled else 0)
	jumps_remaining = max_jumps

func perform_jump() -> void:
	if jumps_remaining > 0:
		velocity.y = JUMP_VELOCITY
		jumps_remaining -= 1

# — Dash helpers — 
func _check_double_tap(direction: int) -> void:
	var now = Time.get_ticks_msec()              # Godot 4: use Time singleton
	if direction == -1:
		if now - last_left_tap <= double_tap_time and dash_active:
			_start_dash(direction)
		last_left_tap = now
	else:
		if now - last_right_tap <= double_tap_time and dash_active:
			_start_dash(direction)
		last_right_tap = now

func _start_dash(direction: int) -> void:
	if is_dashing:
		return
	is_dashing = true
	velocity.x = direction * dash_speed
	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false
