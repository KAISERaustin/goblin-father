# res://scripts/entities/slime.gd
extends CharacterBody2D

const SPEED = 30

@export var ray_cast_left_path:   NodePath = NodePath("RayCastLeft")
@export var ray_cast_right_path:  NodePath = NodePath("RayCastRight")
@export var head_hit_check_path:  NodePath = NodePath("HeadHitCheck")
@export var body_check_path:      NodePath = NodePath("BodyCheck")
@export var ground_check_path:    NodePath = NodePath("GroundCheck")
@export var animated_sprite_path: NodePath = NodePath("AnimatedSprite2D")
@export var slime_kill_path:      NodePath = NodePath("SlimeKill")
@export var death_timer_path:     NodePath = NodePath("DeathTimer")

@onready var ray_cast_left:   RayCast2D           = get_node(ray_cast_left_path)
@onready var ray_cast_right:  RayCast2D           = get_node(ray_cast_right_path)
@onready var head_hit_check:  Area2D              = get_node(head_hit_check_path)
@onready var body_check:      Area2D              = get_node(body_check_path)
@onready var ground_check:    CollisionShape2D    = get_node(ground_check_path)
@onready var animated_sprite: AnimatedSprite2D    = get_node(animated_sprite_path)
@onready var slime_kill:      AudioStreamPlayer2D = get_node(slime_kill_path)
@onready var death_timer:     Timer               = get_node(death_timer_path)

@onready var game_manager:    Node                = GameManager
@onready var scene_manager:   Node                = SceneManager

var is_dead: bool = false
var direction: int = 1

func _ready() -> void:
	head_hit_check.area_entered.connect(_on_head_hit_check_area_entered)
	death_timer.timeout.connect(_on_death_timer_timeout)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0
	move_and_slide()

func _process(delta: float) -> void:
	if is_dead:
		return
	if ray_cast_left.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	elif ray_cast_right.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	position.x += direction * SPEED * delta

func _on_head_hit_check_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		game_manager.make_player_jump()
		slime_kill.play()
		is_dead = true
		head_hit_check.queue_free()
		body_check.queue_free()
		ground_check.queue_free()
		ray_cast_left.queue_free()
		ray_cast_right.queue_free()
		direction = 0
		animated_sprite.play("Death")
		death_timer.start()

func _on_death_timer_timeout() -> void:
	scene_manager.return_slime_to_pool(self)
