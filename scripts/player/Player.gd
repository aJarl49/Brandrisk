extends CharacterBody2D


@export var movement_speed: float = 200
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.15
@export var double_tap_time: float = 0.25

var character_direction : Vector2 

var last_tap_direction: Vector2 = Vector2.ZERO
var tap_timer: float = 0.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO


func _process(delta: float) -> void:
	if tap_timer > 0:
		tap_timer -= delta

func _physics_process(delta: float) -> void:
	if is_dashing:
		velocity = dash_speed * dash_direction
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		move_and_slide()
		return
	
	#Check for double-tap inputs
	var tap_direction := Vector2.ZERO

	if Input.is_action_just_pressed("move_right"):
		tap_direction = Vector2.RIGHT
	elif Input.is_action_just_pressed("move_left"):
		tap_direction = Vector2.LEFT
	elif Input.is_action_just_pressed("move_up"):
			tap_direction = Vector2.UP
	elif Input.is_action_just_pressed("move_down"):
			tap_direction = Vector2.DOWN

	if tap_direction != Vector2.ZERO:
		if last_tap_direction == tap_direction and tap_timer > 0:
			start_dash(tap_direction)
		else:
			last_tap_direction = tap_direction
			tap_timer = double_tap_time

	# Normal movement
	character_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	velocity = character_direction * movement_speed

	# Mutually exclusive inputs: only one direction can be processed at a time
	if Input.is_action_pressed("move_right"):
		character_direction = Vector2.RIGHT
	elif Input.is_action_pressed("move_left"):
		character_direction = Vector2.LEFT
	elif Input.is_action_pressed("move_down"):
		character_direction = Vector2.DOWN
	elif Input.is_action_pressed("move_up"):
		character_direction = Vector2.UP
		
	move_and_slide()

func start_dash(dir: Vector2) -> void:
	is_dashing = true
	dash_direction = dir
	dash_timer = dash_duration
	tap_timer = 0.0
		
	#flip
	#if character_direction.x > 0: %sprite.flip_h = false
	#elif character_direction.x < 0: %sprite.flip_h = true
	
	#if character_direction:
	#	velocity = character_direction * movement_speed
	#	if %sprite.animation != "Walking": %sprite.animation = "Walking"
	#else:
	#	velocity = velocity.move_toward(Vector2.ZERO, movement_speed)
	#	if %sprite.animation != "Idle": %sprite.animation = "Idle"
		
	#move_and_slide()
