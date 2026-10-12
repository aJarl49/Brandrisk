extends Node

var pin_code: Array[int] = []
var is_playing: bool = false

var pin_code_sounds: Array[AudioStream] = [
	preload("res://assets/audio/sfx/button_pressed.Pitch 0.wav"),
	preload("res://assets/audio/sfx/button_pressed.Pitch 1.wav"),
	preload("res://assets/audio/sfx/button_pressed.Pitch 2.wav"),
	preload("res://assets/audio/sfx/button_pressed.Pitch 3.wav"),
	preload("res://assets/audio/sfx/button_pressed.Pitch 4.wav"),
	preload("res://assets/audio/sfx/button_pressed.Pitch 5.wav"),
	preload("res://assets/audio/sfx/button_pressed.Pitch 6.wav"),
	preload("res://assets/audio/sfx/button_pressed.Pitch 7.wav"),
	preload("res://assets/audio/sfx/button_pressed.Pitch 8.wav"),
	preload("res://assets/audio/sfx/button_pressed.Pitch 9.wav")
]

var timer: Timer
var code_lock_player: AudioStreamPlayer

func _ready() -> void:
	generate_pin_code()
	
	code_lock_player = AudioStreamPlayer.new()
	add_child(code_lock_player)
	
	timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	timer.timeout.connect(_on_waiting_timer_timeout)
	add_child(timer)

func _process(_delta: float) -> void:
	var in_main_level: bool = get_tree().get_first_node_in_group("player") != null
	
	if in_main_level:
		if timer.is_stopped() and not is_playing:
			timer.start(5.0)
	else:
		if not timer.is_stopped():
			timer.stop()

func generate_pin_code() -> Array[int]:
	var code: Array[int] = []
	for i in range(4):
		code.append(randi_range(0, 9))
	pin_code = code
	print("Genererad Kod: ", pin_code)
	return code

func _on_waiting_timer_timeout() -> void:
	await play_code_lock_sound()

func play_code_lock_sound() -> void:
	is_playing = true
	for digit in pin_code:
		if get_tree().get_first_node_in_group("player") == null:
			break
		if digit < pin_code_sounds.size() and pin_code_sounds[digit]:
			code_lock_player.stream = pin_code_sounds[digit]
			code_lock_player.play()
			await code_lock_player.finished
	is_playing = false
