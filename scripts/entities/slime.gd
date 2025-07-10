# res://scripts/entities/slime.gd
extends CharacterBody2D  # Inherit physics and movement behavior for a 2D character

const SPEED = 30  # Movement speed of the slime in pixels per second

@export var ray_cast_left_path: NodePath = NodePath("RayCastLeft")  # Path to left edge detection ray
@export var ray_cast_right_path: NodePath = NodePath("RayCastRight")  # Path to right edge detection ray
@export var head_hit_check_path: NodePath = NodePath("HeadHitCheck")  # Path to area detecting player stomps
@export var body_check_path: NodePath = NodePath("BodyCheck")  # Path to area for other collisions
@export var ground_check_path: NodePath = NodePath("GroundCheck")  # Path to ground collision shape
@export var animated_sprite_path: NodePath = NodePath("AnimatedSprite2D")  # Path to the sprite node
@export var slime_kill_path: NodePath = NodePath("SlimeKill")  # Path to death sound player
@export var death_timer_path: NodePath = NodePath("DeathTimer")  # Path to timer for respawn delay

@onready var ray_cast_left: RayCast2D           = get_node(ray_cast_left_path)  # Left edge ray node
@onready var ray_cast_right: RayCast2D          = get_node(ray_cast_right_path)  # Right edge ray node
@onready var head_hit_check: Area2D             = get_node(head_hit_check_path)  # Node that detects stomps
@onready var body_check: Area2D                 = get_node(body_check_path)  # Node for body collisions
@onready var ground_check: CollisionShape2D     = get_node(ground_check_path)  # Ground collision shape
@onready var animated_sprite: AnimatedSprite2D  = get_node(animated_sprite_path)  # Visual sprite
@onready var slime_kill: AudioStreamPlayer2D    = get_node(slime_kill_path)  # Sound to play on death
@onready var death_timer: Timer                 = get_node(death_timer_path)  # Timer controlling death sequence

@onready var game_manager: Node    = GameManager  # Reference to global game manager singleton
@onready var scene_manager: Node   = SceneManager  # Reference to global scene manager singleton

var slime_is_dead: bool = false  # Whether this slime has been killed
var direction: int = 1     # Current horizontal direction (-1 = left, 1 = right)

func _ready() -> void:
	head_hit_check.area_entered.connect(_on_head_hit_check_area_entered)  # Trigger when player stomps
	death_timer.timeout.connect(_on_death_timer_timeout)  # Handle respawn after delay

func _physics_process(delta: float) -> void:
	if slime_is_dead:
		return  # Do nothing if dead
	if not is_on_floor():
		velocity += get_gravity() * delta  # Apply gravity when airborne
	else:
		velocity.y = 0  # Reset vertical velocity on ground
	move_and_slide()  # Perform movement and collision

func _process(delta: float) -> void:
	if slime_is_dead:
		return  # Skip movement logic if dead
	if ray_cast_left.is_colliding():
		direction = -1  # Turn left at left edge
		animated_sprite.flip_h = true  # Flip sprite to face left
	elif ray_cast_right.is_colliding():
		direction = 1  # Turn right at right edge
		animated_sprite.flip_h = false  # Face right
	position.x += direction * SPEED * delta  # Move horizontally

func _on_head_hit_check_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		game_manager.make_player_jump()  # Bounce the player off the slime
		slime_kill.play()  # Play death sound
		slime_is_dead = true  # Mark slime as dead
		# Disable sensors and collisions for death animation
		head_hit_check.set_deferred("monitoring", false) # disables all of the slime’s collision and detection
		body_check.set_deferred("monitoring", false)
		ground_check.set_deferred("disabled", true)
		ray_cast_left.set_deferred("enabled", false)
		ray_cast_right.set_deferred("enabled", false)
		animated_sprite.play("Death")  # Play death animation
		death_timer.start()  # Begin respawn timer

func _on_death_timer_timeout() -> void:
	scene_manager.return_slime_to_pool(self)  # Return slime to pool for reuse
