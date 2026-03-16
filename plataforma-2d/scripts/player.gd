extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	fall,
	duck
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var SPEED = 75.0
@export var JUMP_VELOCITY = -150.0
@export var max_jump_count = 2

var jump_count = 0
var direction = 0
var status: PlayerState

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match status:
		PlayerState.idle:
			idle_state()
		PlayerState.walk:
			walk_state()
		PlayerState.jump:
			jump_state()
		PlayerState.fall:
			fall_state()
		PlayerState.duck:
			duck_state()
	
	move_and_slide()

func go_to_idle_state():
	status = PlayerState.idle
	anim.play("Idle")

func go_to_walk_state():
	status = PlayerState.walk
	anim.play("Walk")

func go_to_jump_state():
	status = PlayerState.jump
	anim.play("Jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1

func go_to_fall_state():
	status = PlayerState.fall
	anim.play("Fall")

func go_to_duck_state():
	status = PlayerState.duck
	anim.play("Duck")
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 12
	collision_shape.position.y = 9

func exit_from_duck_state():
	collision_shape.shape.radius = 7
	collision_shape.shape.height = 20
	collision_shape.position.y = 5.5
	
func idle_state():
	move()
	if velocity.x != 0:
		go_to_walk_state()
		return
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		go_to_jump_state()
		return
	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return

func walk_state():
	move()
	if velocity.x == 0:
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		go_to_jump_state()
		return
		
	if !is_on_floor():
		jump_count += 1
		go_to_fall_state()
		return

func jump_state():
	move()
	if Input.is_action_just_pressed("jump") and can_jump():
		go_to_jump_state()
	
	if velocity.y > 0:
		go_to_fall_state()
		return

func fall_state():
	move()
	if Input.is_action_just_pressed("jump") and can_jump():
		go_to_jump_state()
	
	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return

func duck_state():
	update_direction()
	if Input.is_action_just_released("duck"):
		exit_from_duck_state()
		go_to_idle_state()
		return

func move():
	update_direction()
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
func update_direction():
	direction = Input.get_axis("left", "right")
	
	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false

func can_jump() -> bool:
	return jump_count < max_jump_count
