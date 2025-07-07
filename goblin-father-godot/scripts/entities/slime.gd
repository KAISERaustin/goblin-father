extends CharacterBody2D

const SPEED = 30

# NodePath injections
@export var head_hit_check_path: NodePath   = NodePath("HeadHitCheck")
@export var body_check_path:    NodePath   = NodePath("BodyCheck")
@export var ray_cast_left_path: NodePath   = NodePath("RayCastLeft")
@export var ray_cast_right_path:NodePath   = NodePath("RayCastRight")
@export var ground_check_path: NodePath    = NodePath("GroundCheck")
@export var animated_sprite_path: NodePath= NodePath("AnimatedSprite2D")
@export var slime_kill_path:    NodePath   = NodePath("SlimeKill")

# Onready references
@onready var head_hit_check:    Area2D               = get_node(head_hit_check_path)
@onready var body_check:        Area2D               = get_node(body_check_path)
@onready var ray_cast_left:     RayCast2D            = get_node(ray_cast_left_path)
@onready var ray_cast_right:    RayCast2D            = get_node(ray_cast_right_path)
@onready var ground_check:      CollisionShape2D     = get_node(ground_check_path)
@onready var animated_sprite:   AnimatedSprite2D     = get_node(animated_sprite_path)
@onready var slime_kill:        AudioStreamPlayer2D  = get_node(slime_kill_path)
@onready var game_manager:      Node                 = GameManager

# State
var is_dead: bool = false
var direction: int = 1

func _ready() -> void:
	# Stomp (head) overlap
	head_hit_check.area_entered.connect(_on_head_hit)
	# Body collision with player → reload scene
	body_check.body_entered.connect(_on_body_collision)
	# Debug
	print("[Slime] Ready. head_hit_check →", head_hit_check, ", body_check →", body_check)

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
	# Simple patrol
	if ray_cast_left.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	elif ray_cast_right.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	position.x += direction * SPEED * delta

func _on_head_hit(area: Area2D) -> void:
	if area.is_in_group("player_head"):
		# Bounce the player
		game_manager.make_player_jump()
		# Play kill SFX and death anim
		slime_kill.play()
		is_dead = true
		animated_sprite.play("Death")
		# Return this slime to its pool instead of freeing
		PoolManager.free_instance("Slime", self)

func _on_body_collision(body) -> void:
	if body.is_in_group("player"):
		# Player died → restart level
		get_tree().reload_current_scene()
