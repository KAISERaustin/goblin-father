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

# — Double-jump configuration —
@export var base_jumps           : int    = 1
@export var double_jump_enabled  : bool   = false
var jumps_remaining              : int

# — Dash configuration —
@export var dash_active          : bool   = false    # Power-up unlocked?
@export var dash_speed           : float  = 400.0
@export var dash_duration        : float  = 0.2      # seconds of actual dash
@export var dash_cooldown        : float  = 0.3      # seconds before next dash
@export var double_tap_time      : int    = 300      # ms window for double-tap

var is_dashing                   : bool   = false
var dash_ready                   : bool   = true     # true when allowed to dash
var last_left_tap                : int    = 0
var last_right_tap               : int    = 0

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
	# 1) While mid-dash: preserve dash velocity & gravity
	if is_dashing:
		velocity.y += get_gravity().y * delta
		move_and_slide()
		return

	# 2) Apply high-friction brake ONLY during dash cooldown (dash_ready == false)
	if dash_active and not dash_ready and is_on_floor() and abs(velocity.x) > 0:
		var brake_amount = DECELERATION * 3 * delta
		velocity.x = move_toward(velocity.x, 0, brake_amount)
		velocity.y += get_gravity().y * delta
		move_and_slide()
		return

	# 3) Otherwise defer to the state machine for normal movement
	state_machine.physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
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

# — Jump helpers —
func reset_jumps() -> void:
	var max_jumps = base_jumps + (1 if double_jump_enabled else 0)
	jumps_remaining = max_jumps

func perform_jump() -> void:
	if jumps_remaining > 0:
		velocity.y = JUMP_VELOCITY
		jumps_remaining -= 1

# — Dash helpers —
func _check_double_tap(direction: int) -> void:
	var now = Time.get_ticks_msec()
	if direction == -1:
		if now - last_left_tap <= double_tap_time and dash_active and dash_ready:
			_start_dash(direction)
		last_left_tap = now
	else:
		if now - last_right_tap <= double_tap_time and dash_active and dash_ready:
			_start_dash(direction)
		last_right_tap = now

func _start_dash(direction: int) -> void:
	if is_dashing:
		return
	# 1) Begin dash
	is_dashing = true
	dash_ready = false
	velocity.x = direction * dash_speed

	# 2) Wait out dash duration
	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false

	# 3) Then start cooldown timer before re-enabling dash
	await get_tree().create_timer(dash_cooldown).timeout
	dash_ready = true


func _on_body_check_area_entered(area: Area2D) -> void:
	if area.is_in_group("win"):
		state_machine.enter_state(win_state)
