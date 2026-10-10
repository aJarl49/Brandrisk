extends CharacterBody2D

@export var speed: float = 80.0
@export var patrol_points: Array[Node2D] = []
@export var pin_code_sounds: Array[AudioStreamWAV] = []
@export var player: Node2D


@onready var timer: Timer = $waiting_timer
@onready var footstep_player = $footstep_player
@onready var code_lock_player = $code_lock_player
var pin_code : Array[int] = []
var current_target_index: int = 0
var is_moving: bool = false
var waiting: bool = false
func generate_pin_code() -> Array[int]:
	var code: Array[int] = []
	for i in range(4):
		code.append(randi_range(0,9))
	print("Genererad Kod: ", code)

	return code
	
	

func _ready() -> void:
	if patrol_points.is_empty():
		return
		
	pin_code = generate_pin_code()
	
	player = get_tree().get_first_node_in_group("player")
	if not player:
		print("No player found in scene")
		return

	timer.timeout.connect(_on_waiting_timer_timeout)
	
	# Starta direkt på första punkten (index 0)
	is_moving = true

func _physics_process(delta: float) -> void:
	if not is_moving or waiting or patrol_points.is_empty():
		velocity = Vector2.ZERO
		move_and_slide()
		update_footsteps()
		return
		
	var target_node = patrol_points[current_target_index]
	var target_pos = target_node.global_position
	
	var distance = global_position.distance_to(target_pos)
	if distance > 10:
		var direction = global_position.direction_to(target_pos)
		velocity = direction * speed
		move_and_slide()
	else:
		# Framme! Stanna och starta timern (endast en gång)
		is_moving = false
		waiting = true
		velocity = Vector2.ZERO
		
		if current_target_index == 2:
			play_code_lock_sound()
		
		timer.start()
		
	update_footsteps()
	
func _input(event):
	if Input.is_action_pressed("ui_accept"):
		generate_pin_code()

func start_moving_to_next_point():
	# Gå till nästa punkt (loopar 0 -> 1 -> 2 -> 3 -> 0)
	current_target_index = (current_target_index + 1) % patrol_points.size()
	is_moving = true
	waiting = false

func _on_waiting_timer_timeout() -> void:
	start_moving_to_next_point()
	
func update_footsteps():
	if not player:
		return
	var dist_to_player = global_position.distance_to(player.global_position)
	
	if dist_to_player < 400.0:
		if not footstep_player.playing:
			footstep_player.play()
			
		var volume_linear = clamp(1.0 - (dist_to_player / 400.0), 0.05, 1.0)
		footstep_player.volume_db = linear_to_db(volume_linear)
	else:
		if footstep_player.playing:
			footstep_player.stop()
			
func play_code_lock_sound():
	for digit in pin_code:
		if digit < pin_code_sounds.size() and pin_code_sounds[digit]:
			code_lock_player.stream = pin_code_sounds[digit]
			code_lock_player.play()
			await code_lock_player.finished

		
		
