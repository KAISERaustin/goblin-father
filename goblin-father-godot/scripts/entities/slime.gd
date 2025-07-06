extends CharacterBody2D

const SPEED = 30
var direction = 1
var is_dead = false

@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight

@onready var head_hit_check: Area2D = $HeadHitCheck
@onready var body_check: Area2D = $BodyCheck
@onready var ground_check: CollisionShape2D = $GroundCheck

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var slime_kill: AudioStreamPlayer2D = $SlimeKill

@onready var game_manager: Node = %GameManager
@onready var death_timer: Timer = $DeathTimer

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0
	move_and_slide()

func _process(delta) -> void:
	if is_dead:
		return
	if ray_cast_left.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_right.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	position.x += direction * SPEED * delta

func _on_head_hit_check_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_head"):
		game_manager.make_player_jump()
		slime_kill.play()
		is_dead = true
		head_hit_check.queue_free()
		body_check.queue_free()
		velocity.y = 0
		ground_check.queue_free()
		ray_cast_left.queue_free()
		ray_cast_right.queue_free()
		direction = 0
		animated_sprite.play("Death")
